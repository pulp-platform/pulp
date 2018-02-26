/* 
 * uart_tb_rx.sv
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 *
 * Copyright (C) 2013-2018 ETH Zurich, University of Bologna.
 *
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 */

`define USE_DELAY

module i2s_vip_channel
#(
    parameter I2S_CHAN = 4'h1,
    parameter COUNT_WIDTH = 10,
    parameter FILENAME = "i2s_buffer.hex",
    parameter BUFFER_SIZE = 4096,
    parameter PACKET_SIZE = 32,
    parameter SCK_PERIOD  = 20
)
(
    input  logic                    rst,               

    input  logic                    enable_i,
    input  logic                    pdm_ddr_i,    //  Dual Edge / single edge
    input  logic                    pdm_en_i,     //  Enable
    input  logic                    lsb_first_i,  //  POP the LSB first
    input  logic [1:0]              transf_size_i,//  Master mode --> 00-> 8bit, 10->16 bit;   11->32bit
    input  logic                    i2s_snap_enable_i,

    input  logic                    mode_i,       // 0--> MASTER or 1--> SLAVE

    // SLAVE Interface
    input  logic                    sck_i,
    input  logic                    ws_i,
    output logic                    data_o,

    // Master Interface
    output  logic                   sck_o,
    output  logic                   ws_o
    //output logic                  data_o

);


localparam PACKET_LOG_2      = $clog2(PACKET_SIZE);
localparam ROW_SIZE          = $clog2(BUFFER_SIZE);
localparam DELAY_INT_MASTER  = SCK_PERIOD;
localparam DELAY_INT_SLAVE   = 375;


//---------------------------------------------------------------//
//DEBUG ONLY
//---------------------------------------------------------------//
localparam   NUM_TRANSFER = 128;
localparam   TRASF_ORDER  = "LSB_FIRST"; // MSB_FIRST | LSB_FIRST
localparam   TRASF_SIZE   = 16; 
localparam   DDR_MODE     = "FALSE"; // TRUE | FALSE 
logic [31:0] SIGNATURE_32;
logic [31:0] SIGNATURE_8;
logic [31:0] SIGNATURE_16;
logic [31:0] SIGNATURE_8_DDR;
logic [31:0] SIGNATURE_16_DDR;
//---------------------------------------------------------------//
//---------------------------------------------------------------//


int unsigned  index, i,j,k;


logic   [PACKET_SIZE-1:0] DATA_STD;
logic   [PACKET_SIZE-1:0] DATA_PDM;
logic   [PACKET_SIZE-1:0] DATA_SNAP;


logic   [PACKET_SIZE-1:0]   SHIFT_REG_STD;
logic   [PACKET_SIZE-1:0]   SHIFT_REG_PDM;
logic   [PACKET_SIZE-1:0]   SHIFT_REG_SNAP;


logic   [PACKET_LOG_2-1:0]  BIT_POINTER;
logic   WSQ, WSQQ, WSP;

logic   [ROW_SIZE-1:0]      COUNTER_ROW_STD;
logic   [ROW_SIZE-1:0]      COUNTER_ROW_PDM; 

logic   do_load;



logic   sck, ws;
logic   sck_int = 1'b0;
logic   ws_int;
// READ from external FILE
logic [PACKET_SIZE/8-1:0][7:0]  my_memory      [BUFFER_SIZE];
logic [1:0][15:0]               my_memory_16   [BUFFER_SIZE];
logic [3:0][7:0]                my_memory_8    [BUFFER_SIZE];


// FOR DDR ONLY
logic [31:0]  my_memory_32        [BUFFER_SIZE];
logic [PACKET_SIZE/8-1:0][7:0]  my_memory_ddr_L    [BUFFER_SIZE];
logic [PACKET_SIZE/8-1:0][7:0]  my_memory_ddr_R    [BUFFER_SIZE];

logic [15:0]               my_memory_16_ddr_L   [BUFFER_SIZE];
logic [15:0]               my_memory_16_ddr_R   [BUFFER_SIZE];
logic [31:0]               my_memory_Merged_16  [BUFFER_SIZE];

logic [7:0]               my_memory_8_ddr_L   [BUFFER_SIZE];
logic [7:0]               my_memory_8_ddr_R   [BUFFER_SIZE];
logic [31:0]              my_memory_Merged_8  [BUFFER_SIZE];



logic [3:0][7:0]           my_memory_8_ddr      [BUFFER_SIZE];


int unsigned COUNT_BIT_STD, COUNT_PACKET;




// ███████╗███╗   ██╗ █████╗ ██████╗ 
// ██╔════╝████╗  ██║██╔══██╗██╔══██╗
// ███████╗██╔██╗ ██║███████║██████╔╝
// ╚════██║██║╚██╗██║██╔══██║██╔═══╝ 
// ███████║██║ ╚████║██║  ██║██║     
// ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     
enum logic [2:0] {IDLE, WARMUP_0, WARMUP_1, TRANSFER, PAUSE} CS_SNAP, NS_SNAP;

int unsigned    COUNTER_SNAP_CS, COUNTER_SNAP_NS, COUNTER_ROW_SNAP_CS, COUNTER_ROW_SNAP_NS;
logic  ws_snap, clk_snap;
logic  data_snap_int;
logic  clk_gen, clk_snap_en;





//---------------------------------------------------------------//
//DEBUG ONLY
//---------------------------------------------------------------//
//Load hex file in three memories for PDM and STD operation
initial 
begin
    WSQ  = 0;
    WSQQ = '0;
    
    COUNTER_ROW_STD  = '0;
    COUNTER_ROW_PDM  = '0;

    SIGNATURE_32     = '0;
    SIGNATURE_16     = '0;
    SIGNATURE_16_DDR = '0;
    SIGNATURE_8      = '0;
    SIGNATURE_8_DDR  = '0;
    do_load          = '0;

    $readmemh(FILENAME, my_memory);
    my_memory_32 = my_memory;

    for(index=0; index<NUM_TRANSFER; index++)
    begin
        case(TRASF_SIZE)
        16: begin
            if(TRASF_ORDER == "MSB_FIRST")
            begin
                my_memory_16[index>>1][index[0]] = my_memory[index][3:2];
 
                my_memory_16_ddr_L[index  ] = { my_memory_32[2*index][31],     //1
                                                my_memory_32[2*index][29],     //2
                                                my_memory_32[2*index][27],     //3
                                                my_memory_32[2*index][25],     //4
                                                my_memory_32[2*index][23],     //5
                                                my_memory_32[2*index][21],     //6
                                                my_memory_32[2*index][19],     //7
                                                my_memory_32[2*index][17],     //8
                                                my_memory_32[2*index+1][31],   //9
                                                my_memory_32[2*index+1][29],   //10
                                                my_memory_32[2*index+1][27],   //11
                                                my_memory_32[2*index+1][25],   //12 
                                                my_memory_32[2*index+1][23],   //13 
                                                my_memory_32[2*index+1][21],   //14
                                                my_memory_32[2*index+1][19],   //15
                                                my_memory_32[2*index+1][17]};  //16

                my_memory_16_ddr_R[index  ] = { my_memory_32[2*index][30],     //1
                                                my_memory_32[2*index][28],     //2
                                                my_memory_32[2*index][26],     //3
                                                my_memory_32[2*index][24],     //4
                                                my_memory_32[2*index][22],     //5
                                                my_memory_32[2*index][20],     //6
                                                my_memory_32[2*index][18],     //7
                                                my_memory_32[2*index][16],     //8
                                                my_memory_32[2*index+1][30],   //9
                                                my_memory_32[2*index+1][28],   //10
                                                my_memory_32[2*index+1][26],   //11
                                                my_memory_32[2*index+1][24],   //12 
                                                my_memory_32[2*index+1][22],   //13 
                                                my_memory_32[2*index+1][20],   //14
                                                my_memory_32[2*index+1][18],   //15
                                                my_memory_32[2*index+1][16]};  //16   
            end
            else
                my_memory_16[index>>1][index[0]] = my_memory[index][1:0]; 

                my_memory_16_ddr_L[index  ] = { my_memory_32[2*index][15],    //1
                                                my_memory_32[2*index][13],    //2
                                                my_memory_32[2*index][11],    //3
                                                my_memory_32[2*index][9 ],    //4
                                                my_memory_32[2*index][7 ],    //5
                                                my_memory_32[2*index][5 ],    //6
                                                my_memory_32[2*index][3 ],    //7
                                                my_memory_32[2*index][1 ],    //8
                                                my_memory_32[2*index+1][15],  //9
                                                my_memory_32[2*index+1][13],  //10
                                                my_memory_32[2*index+1][11],  //11
                                                my_memory_32[2*index+1][9 ],  //12 
                                                my_memory_32[2*index+1][7 ],  //13 
                                                my_memory_32[2*index+1][5 ],  //14
                                                my_memory_32[2*index+1][3 ],  //15
                                                my_memory_32[2*index+1][1 ]};  //16

                my_memory_16_ddr_R[index  ] = { my_memory_32[2*index][14],    //1
                                                my_memory_32[2*index][12],    //2
                                                my_memory_32[2*index][10],    //3
                                                my_memory_32[2*index][8],    //4
                                                my_memory_32[2*index][6],    //5
                                                my_memory_32[2*index][4],    //6
                                                my_memory_32[2*index][2],    //7
                                                my_memory_32[2*index][0],    //8
                                                my_memory_32[2*index+1][14],  //9
                                                my_memory_32[2*index+1][12],  //10
                                                my_memory_32[2*index+1][10],  //11
                                                my_memory_32[2*index+1][8],   //12 
                                                my_memory_32[2*index+1][6],   //13 
                                                my_memory_32[2*index+1][4],   //14
                                                my_memory_32[2*index+1][2],   //15
                                                my_memory_32[2*index+1][0]};  //16
        end
        
        8: begin
            if(TRASF_ORDER == "MSB_FIRST")
            begin
                my_memory_8[index>>2][index[1:0]] = my_memory[index][3];

                my_memory_8_ddr_L[index  ] = {  my_memory_32[2*index][31 ],
                                                my_memory_32[2*index][29 ],
                                                my_memory_32[2*index][27 ],
                                                my_memory_32[2*index][25 ],
                                                my_memory_32[2*index+1][31],
                                                my_memory_32[2*index+1][29],
                                                my_memory_32[2*index+1][27],
                                                my_memory_32[2*index+1][25]};

                my_memory_8_ddr_R[index  ] = {  my_memory_32[2*index][30],    //5
                                                my_memory_32[2*index][28],    //6
                                                my_memory_32[2*index][26],    //7
                                                my_memory_32[2*index][24],    //8
                                                my_memory_32[2*index+1][30],   //13 
                                                my_memory_32[2*index+1][28],   //14
                                                my_memory_32[2*index+1][26],   //15
                                                my_memory_32[2*index+1][24]};  //16
            end
            else
            begin
                my_memory_8[index>>2][index[1:0]] = my_memory[index][0];

                my_memory_8_ddr_L[index  ] = {  my_memory_32[2*index][7 ],
                                                my_memory_32[2*index][5 ],
                                                my_memory_32[2*index][3 ],
                                                my_memory_32[2*index][1 ],
                                                my_memory_32[2*index+1][7 ],
                                                my_memory_32[2*index+1][5 ],
                                                my_memory_32[2*index+1][3 ],
                                                my_memory_32[2*index+1][1 ],
                                                my_memory_32[2*index+2][7 ]};

                my_memory_8_ddr_R[index  ] = {  my_memory_32[2*index][6],    //5
                                                my_memory_32[2*index][4],    //6
                                                my_memory_32[2*index][2],    //7
                                                my_memory_32[2*index][0],    //8
                                                my_memory_32[2*index+1][6],   //13 
                                                my_memory_32[2*index+1][4],   //14
                                                my_memory_32[2*index+1][2],   //15
                                                my_memory_32[2*index+1][0]};  //16
            end
        end

        default:
        begin
            // nothing to do
        end

        endcase // TRASF_SIZE
    end




    for(index=0; index<NUM_TRANSFER; index++)
    begin
        case(TRASF_SIZE)
        32: begin

        end

        16: begin
            if(TRASF_ORDER == "MSB_FIRST")
            begin
                my_memory_Merged_16[index][31:16] =  my_memory_16_ddr_R[index];
                my_memory_Merged_16[index][15:0]  =  my_memory_16_ddr_L[index];
            end
            else
            begin
                my_memory_Merged_16[index][31:16] =  my_memory_16_ddr_R[index];
                my_memory_Merged_16[index][15:0]  =  my_memory_16_ddr_L[index];
            end
        end

        8: begin
            if(TRASF_ORDER == "MSB_FIRST")
            begin
                my_memory_Merged_8[index][31:24] =  my_memory_8_ddr_R[2*index+1];
                my_memory_Merged_8[index][23:16] =  my_memory_8_ddr_L[2*index+1];
                my_memory_Merged_8[index][15:8]  =  my_memory_8_ddr_R[2*index];
                my_memory_Merged_8[index][7:0]   =  my_memory_8_ddr_L[2*index];
            end
            else
            begin
                my_memory_Merged_8[index][31:24] =  my_memory_8_ddr_R[2*index+1];
                my_memory_Merged_8[index][23:16] =  my_memory_8_ddr_L[2*index+1];
                my_memory_Merged_8[index][15:8]  =  my_memory_8_ddr_R[2*index];
                my_memory_Merged_8[index][7:0]   =  my_memory_8_ddr_L[2*index];
            end
        end

        endcase // TRASF_SIZE

    end







    

    case(TRASF_SIZE)
        16: begin
            for(index=1; index<NUM_TRANSFER/2; index++)
            begin
                    SIGNATURE_16_DDR = my_memory_Merged_16[index] ^ SIGNATURE_16_DDR;
                    SIGNATURE_16     = my_memory_16[index] ^ SIGNATURE_16; 
            end
        end
        
        8: begin
            
            for(index=1; index<NUM_TRANSFER/4; index++)
            begin
                    SIGNATURE_8_DDR = my_memory_Merged_8[index] ^ SIGNATURE_8_DDR; 
                    SIGNATURE_8     = my_memory_8[index] ^ SIGNATURE_8; 
            end
        end

        default:
        begin
            for(index=1; index<NUM_TRANSFER; index++)
            begin
                SIGNATURE_32 = my_memory[index] ^ SIGNATURE_32; 
            end
        end

    endcase

end
//---------------------------------------------------------------//
//---------------------------------------------------------------//







// MODE == 1 --> SLAVE
// MODE == 0 --> MASTER
 assign sck = mode_i ? sck_i : sck_int;
 assign ws  = mode_i ? ws_i  : ws_int;


// ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ 
// ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
// ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
// ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
// ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                    
// Internal CLock Generator, used only in MASTER_MODE
always
begin
        #(SCK_PERIOD/2);
        sck_int = (rst) ? 1'b0 : ~sck_int & ~mode_i & enable_i;
end


// Genrated and Delayed CLock SCK_o
always_comb
begin
    if(enable_i)
    begin
        if(i2s_snap_enable_i & ~pdm_en_i & ~mode_i)
        begin
            sck_o = clk_snap;
            ws_o  = ws_snap;
        end
        else if(mode_i) // slave
        begin
            sck_o = 1'bz;
            ws_o  = 1'bz;
        end
        else // master
        begin
            sck_o = sck_int;
            ws_o = ws_int;
        end
    end
end

always_comb 
begin
    case(transf_size_i)
        2'b00: begin COUNT_PACKET = 8;  end
        2'b10: begin COUNT_PACKET = 16; end 
        2'b11: begin COUNT_PACKET = 32; end
    endcase // transf_size_i
end





// Create the three maib memories for PDM and STD
assign DATA_STD   = (WSP) ?  my_memory[COUNTER_ROW_STD+1] : my_memory[COUNTER_ROW_STD];
assign DATA_PDM   = my_memory[COUNTER_ROW_PDM];




///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

always @(negedge sck, posedge rst)
begin
    if(rst)
    begin
        COUNTER_ROW_STD <=  0;
        COUNT_BIT_STD   <=  0;
        ws_int          <=  1'b0;
    end
    else
    begin
        case({mode_i,enable_i,pdm_en_i})
        
        3'b110: 
        begin
               ws_int <= 1'b0;
               if(WSP)
               begin
                    COUNT_BIT_STD   <= 0;
                    COUNTER_ROW_STD <= COUNTER_ROW_STD + 1;
               end
               else
               begin
                    COUNT_BIT_STD   <= COUNT_BIT_STD + 1;
               end 
        end


        3'b010: 
        begin
               ws_int <= 1'b0;

                if(COUNT_BIT_STD < COUNT_PACKET-1)
                begin
                    COUNT_BIT_STD <= COUNT_BIT_STD + 1;
                    if(COUNT_BIT_STD == COUNT_PACKET-2)
                        ws_int          <=  ~ws_int;
                    else
                        ws_int          <=  ws_int;
                end
                else if( COUNT_BIT_STD == COUNT_PACKET-1 )
                     begin
                        COUNT_BIT_STD   <= 0;
                        COUNTER_ROW_STD <= COUNTER_ROW_STD + 1;
                        ws_int          <=  ws_int;
                     end
        end

        endcase // {mode_i,enable_i,pdm_en_i
    end        
end









always @(negedge sck or posedge rst) 
begin : _COMPUTE_WSP_
    if( rst ) 
    begin 
         WSQ  <= 0;
         WSQQ <= 0;
    end 
    else 
    begin
         WSQ  <= ws;
         WSQQ <= WSQ;
    end
end
assign #(1) WSP = ws ^ WSQ; //WSQ ^ WSQQ; // Strobe used to sample new input
//                       // data in the  SR

logic rst_dly;
assign #(1.2) rst_dly = rst;

always @(negedge sck or posedge rst_dly) 
begin : _SHIFT_REG_STD_
    if( rst ) 
    begin : _RESET_SR_
        SHIFT_REG_STD <= DATA_STD;
    end 
    else 
    begin
        if(pdm_en_i == 1'b0)
        begin
                if(WSP)
                begin : _LOAD_SR_STD_
                    SHIFT_REG_STD <= DATA_STD;
                end
                else
                begin : _SHIFT_
                    if(lsb_first_i)
                    begin : _PUSH_LSB_FIRST_STD_
                        SHIFT_REG_STD[PACKET_SIZE-2:0] <= SHIFT_REG_STD[PACKET_SIZE-1:1] ;
                        SHIFT_REG_STD[PACKET_SIZE-1]   <= 0; // Fill with zeros
                    end
                    else
                    begin : _PUSH_MSB_FIRST_STD_
                        SHIFT_REG_STD[PACKET_SIZE-1:1] <= SHIFT_REG_STD[PACKET_SIZE-2:0] ;
                        SHIFT_REG_STD[0]               <= 0;  // Fill with zeros
                    end
                end

        end
        else
        begin
            SHIFT_REG_STD <= '0;
        end
    end
end
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////





//////////////////////////////////////////////////////
//           ONLY for DDR I2S version               //
//////////////////////////////////////////////////////
always @(posedge sck or posedge rst) 
begin : _SW_SR_   
    if( rst ) 
    begin : _RESET_BIT_CNT_
         BIT_POINTER  <= 0;
         COUNTER_ROW_PDM <= '0;
    end 
    else 
    begin
            if(pdm_en_i)
            begin
                    if(pdm_ddr_i)
                    begin
                            if(BIT_POINTER == COUNT_PACKET/2-1)
                            begin :  _CLEAR_BIT_CNT_DDR_
                                    BIT_POINTER     <= '0;
                            end
                            else if(BIT_POINTER == COUNT_PACKET/2-2)
                                 begin
                                        COUNTER_ROW_PDM <= COUNTER_ROW_PDM + 1'b1;
                                        BIT_POINTER  <= BIT_POINTER+1;
                                 end
                                 else
                                 begin : _INCR_BIT_CNT_DDR_
                                        BIT_POINTER  <= BIT_POINTER+1;
                                 end                            
                    end
                    else
                    begin
                            if(BIT_POINTER == COUNT_PACKET-1)
                            begin :  _CLEAR_BIT_CNT_
                                    BIT_POINTER     <= '0;
                                    COUNTER_ROW_PDM <= COUNTER_ROW_PDM + 1'b1;
                            end
                            else
                            begin : _INCR_BIT_CNT_
                                BIT_POINTER  <= BIT_POINTER+1;
                            end 
                    end


            end
            else
            begin
                    BIT_POINTER     <= '0;
                    COUNTER_ROW_PDM <= '0;
            end     
    end
end

always @(posedge sck or posedge rst) 
begin : proc_do_load
    if(rst) 
    begin
         do_load <= 0;
    end 
    else 
    begin
        if ( ((pdm_ddr_i == 1'b1) && (BIT_POINTER == (COUNT_PACKET/2-1))) || (((pdm_ddr_i == 1'b0) && (BIT_POINTER == (COUNT_PACKET-1) ))) )//On falling edge of the clock
        begin : _LOAD_SR_PDM_
                    do_load <= 1'b1; 
        end
        else
        begin
                    do_load <= 1'b0;
        end
    end
end



always @(negedge sck, posedge sck,  posedge rst) // Sensitive on both clock edges 
begin : _SHIFT_REG_PDM_
    if( rst ) 
    begin : _RESET_SR_PDM_
            begin : _SDR_LOAD_
                    SHIFT_REG_PDM[PACKET_SIZE-1:0]               <=  DATA_PDM;
            end
    end 
    else 
    begin
        
        if(do_load & ~sck)
        begin : _LOAD_PDM_
            SHIFT_REG_PDM   <=  DATA_PDM;
        end
        else
        begin : _SHIFT_PDM_
            if(pdm_ddr_i)
            begin : _PDM_DDR_
                    if(lsb_first_i)
                    begin : _PUSH_LSB_FIRST_
                        SHIFT_REG_PDM[PACKET_SIZE-2:0] <= SHIFT_REG_PDM[PACKET_SIZE-1:1] ;
                        SHIFT_REG_PDM[PACKET_SIZE-1]   <= 0; // Fill with zeros
                    end
                    else
                    begin : _PUSH_MSB_FIRST_
                        SHIFT_REG_PDM[PACKET_SIZE-1:1] <= SHIFT_REG_PDM[PACKET_SIZE-2:0] ;
                        SHIFT_REG_PDM[0]               <= 0;  // Fill with zeros
                    end
            end
            else
            begin : _PDM_SDR_
                    if(sck == 1'b0 )
                    begin
                            if(lsb_first_i)
                            begin : _PUSH_LSB_FIRST_
                                SHIFT_REG_PDM[PACKET_SIZE-2:0] <= SHIFT_REG_PDM[PACKET_SIZE-1:1] ;
                            end
                            else
                            begin : _PUSH_MSB_FIRST_
                                SHIFT_REG_PDM[PACKET_SIZE-1:1] <= SHIFT_REG_PDM[PACKET_SIZE-2:0] ;
                            end
                    end
            end
        end
    end
end






always @(*)
begin : proc_data_o
    if(pdm_en_i)
    begin
        if(pdm_ddr_i)
            if(mode_i == 1'b1) // slave
                `ifdef USE_DELAY #(DELAY_INT_SLAVE/4.0) `endif data_o = (lsb_first_i) ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE-1];
            else
                `ifdef USE_DELAY #(DELAY_INT_MASTER/4.0) `endif data_o = (lsb_first_i) ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE-1];
        else
          if(mode_i == 1'b1) // slave
            data_o = (lsb_first_i) ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE-1];
          else // master
            data_o = (lsb_first_i) ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE-1];
        end
    else
    begin
        if(mode_i == 1'b1) // slave
        begin
                data_o = (lsb_first_i) ? SHIFT_REG_STD[0] : SHIFT_REG_STD[PACKET_SIZE-1];
        end
        else
        begin
            if(i2s_snap_enable_i)
                data_o = data_snap_int;
            else
                data_o = (lsb_first_i) ? SHIFT_REG_STD[0] : SHIFT_REG_STD[PACKET_SIZE-1];
        end

    end
end











// ███████╗███╗   ██╗ █████╗ ██████╗ 
// ██╔════╝████╗  ██║██╔══██╗██╔══██╗
// ███████╗██╔██╗ ██║███████║██████╔╝
// ╚════██║██║╚██╗██║██╔══██║██╔═══╝ 
// ███████║██║ ╚████║██║  ██║██║     
// ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     
               
assign DATA_SNAP  = my_memory[COUNTER_ROW_SNAP_CS];

initial
begin
    clk_gen = 0;
end

always 
begin
    #(20) clk_gen = ~clk_gen;
end

assign clk_snap = (clk_snap_en) ? clk_gen : 1'b0;

// FSM for SNAP MODE:
always @(negedge clk_gen, posedge rst) 
begin
    if(rst) 
    begin
         CS_SNAP  <= IDLE;
         COUNTER_SNAP_CS <= '0;
         COUNTER_ROW_SNAP_CS <= '0;

    end 
    else 
    begin
         CS_SNAP <= NS_SNAP;
         COUNTER_SNAP_CS <= COUNTER_SNAP_NS;
         COUNTER_ROW_SNAP_CS <= COUNTER_ROW_SNAP_NS;
    end
end

always_comb
begin
    ws_snap             = 1'b1;
    COUNTER_ROW_SNAP_NS = COUNTER_ROW_SNAP_CS;
    data_snap_int       = '0;
    COUNTER_SNAP_NS     = COUNTER_SNAP_CS;
    NS_SNAP             = CS_SNAP;
    clk_snap_en         = 1'b0;

    
    
        case(CS_SNAP)
        IDLE: begin
            
            if(enable_i & ~mode_i & ~pdm_en_i & i2s_snap_enable_i)
            begin
                NS_SNAP = WARMUP_0;
            end
            else
            begin
                NS_SNAP = IDLE;
            end

            COUNTER_SNAP_NS = '0;
            ws_snap = 1'b1;
            COUNTER_ROW_SNAP_NS = '0;
            clk_snap_en         = 1'b0;
        end

        WARMUP_0 :
        begin
            NS_SNAP = WARMUP_1;
            COUNTER_SNAP_NS = '0;
            ws_snap = 1'b1;
            COUNTER_ROW_SNAP_NS = 0;
            clk_snap_en         = 1'b1;
        end

        WARMUP_1 :
        begin
            NS_SNAP = TRANSFER;
            COUNTER_SNAP_NS = '0;
            ws_snap = 1'b0;
            COUNTER_ROW_SNAP_NS = 0;
            clk_snap_en         = 1'b1;
        end


        TRANSFER:
        begin
            if(lsb_first_i)
                data_snap_int = DATA_SNAP[COUNTER_SNAP_CS];
            else
                data_snap_int = DATA_SNAP[PACKET_SIZE-COUNTER_SNAP_CS-1];

            clk_snap_en         = 1'b1;


            if(COUNTER_SNAP_NS == COUNT_PACKET-1)
            begin
                COUNTER_SNAP_NS = 0;
                NS_SNAP = PAUSE;
                ws_snap = 1'b1; 
            end
            else
            begin
                COUNTER_SNAP_NS = COUNTER_SNAP_CS + 1;
                ws_snap = 1'b0;
            end

        end

        PAUSE:
        begin
            clk_snap_en         = 1'b1;
            ws_snap             = 1'b0;
            NS_SNAP             = TRANSFER;
            COUNTER_ROW_SNAP_NS = COUNTER_ROW_SNAP_CS + 1;
        end


        default :
        begin
            NS_SNAP = IDLE;
        end

        endcase // CS_SNAP

end


endmodule // i2s_vip_new

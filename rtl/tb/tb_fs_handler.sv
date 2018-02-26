// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * tb_pulp.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 */

`define ADDR_STDOUT_PRINT 32'h1A10F000
`define ADDR_STDOUT_FS    32'h1A112000

`define ADDR_FOPEN  32'h1A112000
`define ADDR_RW     32'h1A113000
`define CMD_FOPEN   0
`define CMD_FCLOSE  1

module tb_fs_handler #(
   parameter  ADDR_WIDTH = 32,
   parameter  DATA_WIDTH = 64,
   parameter  NB_CORES   = 4
) (
   input  logic                      clk,
   input  logic                      rst_n,
   input  logic                      CSN,
   input  logic                      WEN,
   input  logic [ADDR_WIDTH-1:0]     ADDR,
   input  logic [DATA_WIDTH-1:0]     WDATA,
   input  logic [DATA_WIDTH/8-1:0]   BE,
   output logic [DATA_WIDTH-1:0]     RDATA
);

   //addr demux block
   logic      [11:0]                 add_fopen;
   logic      [31:0]                 dat_fopen;
   logic                             req_fopen;

   //addr demux block
   logic      [11:0]                 add_stdout;
   logic      [31:0]                 dat_stdout;
   logic                             req_stdout;

   integer     FILE_00;
   integer     FILE_TO_OPEN;
   string      file_name;
   integer     tmp;
   integer     single_char;

   logic req_rw;
   logic add_rw;
   logic dat_rw;

   event FOPEN_EVENT;
   event FCLOSE_EVENT;
   event READ_EVENT;
   event WRITE_EVENT;



   assign req_stdout = ( (CSN == 1'b0) && (WEN == 1'b0) && ({ADDR[31:12],12'h00} == `ADDR_STDOUT_PRINT) );
   assign req_fopen  = ( (CSN == 1'b0) && (WEN == 1'b0) && (ADDR == `ADDR_STDOUT_FS) );

   assign req_rw = (CSN == 1'b0) && (ADDR == `ADDR_RW);

   assign add_stdout = ADDR[11:0];
   assign add_fopen  = ADDR[11:0];
   assign add_rw     = ADDR[11:0];

   assign dat_stdout = WDATA[31:0];
   assign dat_fopen  = WDATA[31:0];
   assign dat_rw     = WDATA[31:0];

   tb_fs_handler_debug #(
      .ADDR_WIDTH   ( 9       ),
      .DATA_WIDTH   ( 32       ),
      .NB_CORES     ( NB_CORES ),
      .CLUSTER_ID   ( 0        ),
      .DEBUG_TYPE   ( "PE"     ),  // FS || PE
      .SILENT_MODE  ( "OFF"    ),  // ON || OFF
      .COLORED_MODE ( "OFF"    )   // ON || OFF
   )
   STDOUT_PRINTF_CLUSTER
      (
         .rst_ni ( rst_n              ),
         .clk_i  ( clk                ),
         .req_i  ( req_stdout         ),
         .add_i  ( ADDR[11:3]         ),
         .dat_i  ( WDATA[31:0]        )
      );

   tb_fs_handler_debug #(
      .ADDR_WIDTH   ( 14       ),
      .DATA_WIDTH   ( 32       ),
      .NB_CORES     ( NB_CORES ),
      .CLUSTER_ID   ( 0        ),
      .DEBUG_TYPE   ( "FS"     ),  // FS || PE
      .SILENT_MODE  ( "ON"     ),  // ON || OFF
      .COLORED_MODE ( "OFF"    )   // ON || OFF
   )
   FS_PRINTF_CLUSTER
      (
         .rst_ni ( rst_n              ),
         .clk_i  ( clk                ),
         .req_i  ( req_fopen          ),
         .add_i  ( ADDR[13:0]         ),
         .dat_i  ( WDATA[31:0]        )
      );

   tb_fs_handler_debug #(
      .ADDR_WIDTH   ( 9        ),
      .DATA_WIDTH   ( 32       ),
      .NB_CORES     ( NB_CORES ),
      .CLUSTER_ID   ( 31       ),
      .DEBUG_TYPE   ( "PE"     ),  // FS || PE
      .SILENT_MODE  ( "OFF"    ),  // ON || OFF
      .COLORED_MODE ( "OFF"    )   // ON || OFF
   )
   STDOUT_PRINTF_FC
      (
         .rst_ni ( rst_n              ),
         .clk_i  ( clk                ),
         .req_i  ( req_stdout         ),
         .add_i  ( ADDR[11:3]         ),
         .dat_i  ( WDATA[31:0]        )
      );

   tb_fs_handler_debug #(
      .ADDR_WIDTH   ( 14       ),
      .DATA_WIDTH   ( 32       ),
      .NB_CORES     ( 1        ),
      .CLUSTER_ID   ( 31       ),
      .DEBUG_TYPE   ( "FS"     ),  // FS || PE
      .SILENT_MODE  ( "ON"     ),  // ON || OFF
      .COLORED_MODE ( "OFF"    )   // ON || OFF
   )
   FS_PRINTF_FC
      (
         .rst_ni ( rst_n              ),
         .clk_i  ( clk                ),
         .req_i  ( req_fopen          ),
         .add_i  ( ADDR[13:0]         ),
         .dat_i  ( WDATA[31:0]        )
      );


   always @(FOPEN_EVENT)
      begin
         FOPEN();
      end

   always @(FCLOSE_EVENT)
      begin
         FCLOSE();
      end


   always @(READ_EVENT)
      begin
         F_READ();
      end

   always @(WRITE_EVENT)
      begin
         F_WRITE();
      end


   always_ff @(posedge clk, negedge rst_n)
      begin
         if(rst_n == 1'b0)
            begin
               RDATA <= '0;
            end
         else
            begin
               RDATA <= single_char;

               if((ADDR == `ADDR_FOPEN ) && ( CSN == 1'b0 ) && (WEN == 1'b0) && (WDATA == `CMD_FOPEN) )
                  -> FOPEN_EVENT;

               if((ADDR == `ADDR_FOPEN ) && ( CSN == 1'b0 ) && (WEN == 1'b0) && (WDATA == `CMD_FCLOSE) )
                  -> FCLOSE_EVENT;


               if((ADDR == `ADDR_RW ) && ( CSN == 1'b0 ) && (WEN == 1'b1))
                  -> READ_EVENT;

               if((ADDR == `ADDR_RW ) && ( CSN == 1'b0 ) && (WEN == 1'b0))
                  -> WRITE_EVENT;
            end
      end


   task FOPEN;
      FILE_00      = $fopen("fs/file_00.txt", "r");
      tmp          = $fgets(file_name, FILE_00);
      $fclose(FILE_00);
      $display("Opening Binary file %s",file_name);
      file_name = file_name.substr(0,file_name.len()-2);
      FILE_TO_OPEN = $fopen(file_name, "r+b");
      if (!FILE_TO_OPEN)
         $error("Error opening the file %s", file_name);
   endtask


   task FCLOSE;
      FILE_00      = $fopen("fs/file_00.txt","r");
      tmp          = $fgets(file_name, FILE_00);
      $fclose(FILE_00);
      $display("Closing Binary file %s",file_name);
      $fclose(FILE_TO_OPEN);
   endtask


   task F_READ;
      single_char = $fgetc(FILE_TO_OPEN);
   endtask

   task F_WRITE;
      $fwrite(FILE_TO_OPEN, "%c", WDATA);
   endtask

endmodule

module tb_fs_handler_debug #(
   parameter ADDR_WIDTH   = 12,
   parameter DATA_WIDTH   = 32,
   parameter NB_CORES     = 4,
   parameter CLUSTER_ID   = 0,
   parameter DEBUG_TYPE   = "FS",  // FS || PE
   parameter SILENT_MODE  = "OFF", // ON || OFF
   parameter FULL_LINE    = "ON",  // ON || OFF  Print only full lines of fake stdout
   parameter COLORED_MODE = "ON"   // ON || OFF
) (
   input  logic                      rst_ni,        //: in  std_logic;
   input  logic                      clk_i,         //: in  std_logic;
   input  logic                      req_i,         //: in  std_logic;
   input  logic [ADDR_WIDTH-1:0]     add_i,         //: in  std_logic_vector(11 downto 0);
   input  logic [DATA_WIDTH-1:0]     dat_i          //: in  std_logic_vector(31 downto 0));
);

   integer                 IOFILE[NB_CORES];
   string                  FILENAME[NB_CORES];
   string                  FILE_ID;
   string                  CLUSTER_ID_STR;
   int unsigned            core_index, index;

   string                  LINE_BUFFER[NB_CORES];

   initial
      begin
         for(core_index = 0; core_index < NB_CORES; core_index++)
            begin : _CREATE_IO_FILES_
               FILE_ID.itoa(core_index);
               CLUSTER_ID_STR.itoa(CLUSTER_ID);

               case(DEBUG_TYPE)
                  "FS" : FILENAME[core_index] = { "fs/file_", CLUSTER_ID_STR, "_" , FILE_ID, ".txt" };
                  "PE" : FILENAME[core_index] = { "stdout/stdout_fake_pe", CLUSTER_ID_STR, "_" ,FILE_ID     };
               endcase
               IOFILE[core_index] = $fopen(FILENAME[core_index],"w");

               LINE_BUFFER[core_index] = "";
            end
      end

   always @(posedge clk_i)
      begin
         if(rst_ni == 1'b1)
            begin
               if( (req_i == 1'b1) && (CLUSTER_ID == add_i[ADDR_WIDTH-1:4]))
                  begin

                     if(NB_CORES > 1 )
                        core_index = add_i[3:0];
                     else
                        core_index = 0;

                     $fwrite(IOFILE[core_index],"%s",dat_i[7:0]);

                     if(SILENT_MODE == "OFF")
                        begin
                           if(COLORED_MODE == "ON")
                              begin
                                 case(core_index)
                                    0:  begin  $write("%c[1;30m",27); end
                                    1:  begin  $write("%c[1;31m",27); end
                                    2:  begin  $write("%c[1;32m",27); end
                                    3:  begin  $write("%c[1;33m",27); end
                                    4:  begin  $write("%c[1;34m",27); end
                                    5:  begin  $write("%c[1;35m",27); end
                                    6:  begin  $write("%c[1;36m",27); end
                                    7:  begin  $write("%c[4;30m",27); end
                                    8:  begin  $write("%c[4;31m",27); end
                                    9:  begin  $write("%c[4;32m",27); end
                                    10: begin  $write("%c[4;33m",27); end
                                    11: begin  $write("%c[4;34m",27); end
                                    12: begin  $write("%c[4;35m",27); end
                                    13: begin  $write("%c[4;36m",27); end
                                    14: begin  $write("%c[5;30m",27); end
                                    15: begin  $write("%c[5;31m",27); end
                                 endcase
                              end

                           if (FULL_LINE == "ON")
                              begin
                                 LINE_BUFFER[core_index] = {LINE_BUFFER[core_index], string'(dat_i[7:0])};
                              end else begin
                              $write("Cluster_%d_PE_%0d Required Putchar: %s", CLUSTER_ID, core_index, dat_i[7:0]);

                              if(COLORED_MODE == "ON")
                                 $write("%c[0m\n",27);
                              else
                                 $write("\n");
                           end
                        end

                     if((dat_i[7:0] == 10) || (dat_i == 0))
                        begin
                           $fflush(IOFILE[core_index]);

                           if(SILENT_MODE == "OFF")
                              begin
                                 if (FULL_LINE == "ON")
                                    begin
                                       $display("[STDOUT-CL%0d_PE%0d] %s", CLUSTER_ID, core_index, LINE_BUFFER[core_index].substr(0, LINE_BUFFER[core_index].len()-2));
                                       LINE_BUFFER[core_index] = "";
                                    end
                                 else
                                    begin
                                       $display("CL%0d_PE%0d Writing line", CLUSTER_ID, core_index);
                                    end
                              end
                        end

                  end
            end
      end

endmodule

// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define SPI_STD_TX  2'b00
`define SPI_STD_RX  2'b01
`define SPI_QUAD_TX 2'b10
`define SPI_QUAD_RX 2'b11

module pad_control #(
    parameter int unsigned N_UART = 1,
    parameter int unsigned N_SPI = 1,
    parameter int unsigned N_I2C = 2
) (

        //********************************************************************//
        //*** PERIPHERALS SIGNALS ********************************************//
        //********************************************************************//

        // PAD CONTROL REGISTER
        // input  logic [63:0][1:0] pad_mux_i        ,
        input  logic [63:0][5:0] pad_cfg_i        ,
        output logic [72:0][5:0] pad_cfg_o        , //39+2+32

        input  logic             sdio_clk_i       ,
        input  logic             sdio_cmd_i       ,
        output logic             sdio_cmd_o       ,
        input  logic             sdio_cmd_oen_i   ,
        input  logic [3:0]       sdio_data_i      ,
        output logic [3:0]       sdio_data_o      ,
        input  logic [3:0]       sdio_data_oen_i  ,

        // GPIOS
        input  logic [31:0]      gpio_out_i       ,
        output logic [31:0]      gpio_in_o        ,
        input  logic [31:0]      gpio_dir_i       ,
        input  logic [31:0][5:0] gpio_cfg_i       ,

        // UART
        input  logic             uart_tx_i        ,
        output logic             uart_rx_o        ,

        // I2C
        input  logic [N_I2C-1:0] i2c_scl_out_i    ,
        output logic [N_I2C-1:0] i2c_scl_in_o     ,
        input  logic [N_I2C-1:0] i2c_scl_oe_i     ,
        input  logic [N_I2C-1:0] i2c_sda_out_i    ,
        output logic [N_I2C-1:0] i2c_sda_in_o     ,
        input  logic [N_I2C-1:0] i2c_sda_oe_i     ,

        // I2S
        output logic             i2s_slave_sd0_o  ,
        output logic             i2s_slave_sd1_o  ,
        output logic             i2s_slave_ws_o   ,
        input  logic             i2s_slave_ws_i   ,
        input  logic             i2s_slave_ws_oe  ,
        output logic             i2s_slave_sck_o  ,
        input  logic             i2s_slave_sck_i  ,
        input  logic             i2s_slave_sck_oe ,

        // SPI MASTER
        input  logic [N_SPI-1:0]      spi_clk_i   ,
        input  logic [N_SPI-1:0][3:0] spi_csn_i   ,
        input  logic [N_SPI-1:0][3:0] spi_oen_i   ,
        input  logic [N_SPI-1:0][3:0] spi_sdo_i   ,
        output logic [N_SPI-1:0][3:0] spi_sdi_o   ,

        // CAMERA INTERFACE
        output logic             cam_pclk_o       ,
        output logic [7:0]       cam_data_o       ,
        output logic             cam_hsync_o      ,
        output logic             cam_vsync_o      ,

        // TIMER
        input  logic [3:0]       timer0_i         ,
        input  logic [3:0]       timer1_i         ,
        input  logic [3:0]       timer2_i         ,
        input  logic [3:0]       timer3_i         ,

        // HYPERBUS
        input  logic  [1:0]       hyper_cs_ni        ,
        input  logic              hyper_ck_i         ,
        input  logic              hyper_ck_ni        ,
        input  logic  [1:0]       hyper_rwds_i       ,
        output logic              hyper_rwds_o       ,
        input  logic  [1:0]       hyper_rwds_oe_i    ,
        output logic  [15:0]      hyper_dq_o         ,
        input  logic  [15:0]      hyper_dq_i         ,
        input  logic  [1:0]       hyper_dq_oe_o      ,
        input  logic              hyper_reset_no     , 


        //********************************************************************//
        //*** PAD FRAME SIGNALS **********************************************//
        //********************************************************************//

        // PADS OUTPUTS
        output logic             out_spim_sdio0_o ,
        output logic             out_spim_sdio1_o ,
        output logic             out_spim_sdio2_o ,
        output logic             out_spim_sdio3_o ,
        output logic             out_spim_csn0_o  ,
        output logic             out_spim_csn1_o  ,
        output logic             out_spim_sck_o   ,
        output logic             out_sdio_clk_o   ,
        output logic             out_sdio_cmd_o   ,
        output logic             out_sdio_data0_o ,
        output logic             out_sdio_data1_o ,
        output logic             out_sdio_data2_o ,
        output logic             out_sdio_data3_o ,
        output logic             out_uart_rx_o    ,
        output logic             out_uart_tx_o    ,
        output logic             out_cam_pclk_o   ,
        output logic             out_cam_hsync_o  ,
        output logic             out_cam_data0_o  ,
        output logic             out_cam_data1_o  ,
        output logic             out_cam_data2_o  ,
        output logic             out_cam_data3_o  ,
        output logic             out_cam_data4_o  ,
        output logic             out_cam_data5_o  ,
        output logic             out_cam_data6_o  ,
        output logic             out_cam_data7_o  ,
        output logic             out_cam_vsync_o  ,
        output logic             out_i2c0_sda_o   ,
        output logic             out_i2c0_scl_o   ,
        output logic             out_i2s0_sck_o   ,
        output logic             out_i2s0_ws_o    ,
        output logic             out_i2s0_sdi_o   ,
        output logic             out_i2s1_sdi_o   ,
        
        output logic[31:0]       out_gpios_o      ,
        output logic             out_i2c1_sda_o   ,
        output logic             out_i2c1_scl_o   ,

        output logic             out_hyper_cs0n_o     ,
        output logic             out_hyper_cs1n_o     ,
        output logic             out_hyper_ck_o       ,
        output logic             out_hyper_ckn_o      ,
        output logic             out_hyper_rwds0_o    ,
        output logic             out_hyper_rwds1_o    ,
        output logic  [7:0]      out_hyper_dq0_o      ,
        output logic  [7:0]      out_hyper_dq1_o      ,
        output logic             out_hyper_resetn_o   ,

        // PAD INPUTS
        input logic              in_spim_sdio0_i  ,
        input logic              in_spim_sdio1_i  ,
        input logic              in_spim_sdio2_i  ,
        input logic              in_spim_sdio3_i  ,
        input logic              in_spim_csn0_i   ,
        input logic              in_spim_csn1_i   ,
        input logic              in_spim_sck_i    ,
        input logic              in_sdio_clk_i    ,
        input logic              in_sdio_cmd_i    ,
        input logic              in_sdio_data0_i  ,
        input logic              in_sdio_data1_i  ,
        input logic              in_sdio_data2_i  ,
        input logic              in_sdio_data3_i  ,
        input logic              in_uart_rx_i     ,
        input logic              in_uart_tx_i     ,
        input logic              in_cam_pclk_i    ,
        input logic              in_cam_hsync_i   ,
        input logic              in_cam_data0_i   ,
        input logic              in_cam_data1_i   ,
        input logic              in_cam_data2_i   ,
        input logic              in_cam_data3_i   ,
        input logic              in_cam_data4_i   ,
        input logic              in_cam_data5_i   ,
        input logic              in_cam_data6_i   ,
        input logic              in_cam_data7_i   ,
        input logic              in_cam_vsync_i   ,
        input logic              in_i2c0_sda_i    ,
        input logic              in_i2c0_scl_i    ,
        input logic              in_i2s0_sck_i    ,
        input logic              in_i2s0_ws_i     ,
        input logic              in_i2s0_sdi_i    ,
        input logic              in_i2s1_sdi_i    ,
        
        input logic[31:0]        in_gpios_i       ,
        input logic              in_i2c1_sda_i    ,
        input logic              in_i2c1_scl_i    ,

        input logic              in_hyper_cs0n_i     ,
        input logic              in_hyper_cs1n_i     ,
        input logic              in_hyper_ck_i       ,
        input logic              in_hyper_ckn_i      ,
        input logic              in_hyper_rwds0_i    ,
        input logic              in_hyper_rwds1_i    ,
        input logic  [7:0]       in_hyper_dq0_i      ,
        input logic  [7:0]       in_hyper_dq1_i      ,
        input logic              in_hyper_resetn_i   ,

        // OUTPUT ENABLE
        output logic             oe_spim_sdio0_o  ,
        output logic             oe_spim_sdio1_o  ,
        output logic             oe_spim_sdio2_o  ,
        output logic             oe_spim_sdio3_o  ,
        output logic             oe_spim_csn0_o   ,
        output logic             oe_spim_csn1_o   ,
        output logic             oe_spim_sck_o    ,
        output logic             oe_sdio_clk_o    ,
        output logic             oe_sdio_cmd_o    ,
        output logic             oe_sdio_data0_o  ,
        output logic             oe_sdio_data1_o  ,
        output logic             oe_sdio_data2_o  ,
        output logic             oe_sdio_data3_o  ,
        output logic             oe_uart_rx_o     ,
        output logic             oe_uart_tx_o     ,
        output logic             oe_cam_pclk_o    ,
        output logic             oe_cam_hsync_o   ,
        output logic             oe_cam_data0_o   ,
        output logic             oe_cam_data1_o   ,
        output logic             oe_cam_data2_o   ,
        output logic             oe_cam_data3_o   ,
        output logic             oe_cam_data4_o   ,
        output logic             oe_cam_data5_o   ,
        output logic             oe_cam_data6_o   ,
        output logic             oe_cam_data7_o   ,
        output logic             oe_cam_vsync_o   ,
        output logic             oe_i2c0_sda_o    ,
        output logic             oe_i2c0_scl_o    ,
        output logic             oe_i2s0_sck_o    ,
        output logic             oe_i2s0_ws_o     ,
        output logic             oe_i2s0_sdi_o    ,
        output logic             oe_i2s1_sdi_o    ,
        
        output logic[31:0]       oe_gpios_o       ,
        output logic             oe_i2c1_sda_o    ,
        output logic             oe_i2c1_scl_o    ,

        output logic             oe_hyper_cs0n_o      ,
        output logic             oe_hyper_cs1n_o      ,
        output logic             oe_hyper_ck_o        ,
        output logic             oe_hyper_ckn_o       ,
        output logic             oe_hyper_rwds0_o     ,
        output logic             oe_hyper_rwds1_o     ,
        output logic             oe_hyper_dq0_o       ,
        output logic             oe_hyper_dq1_o       ,
        output logic             oe_hyper_resetn_o    

    );

   logic s_alt0,s_alt1,s_alt2,s_alt3;

   // check invariants
   if (N_SPI  <  1 || N_SPI  >  2) $error("The current verion of Pad control supports only 1 or 2 SPI peripherals");
   if (N_I2C  != 2) $error("The current version of Pad control only supports exactly 2 I2C peripherals");
   if (N_UART != 1) $error("The current version of Pad control only supports exactly 1 UART peripherals");

   // DEFINE DEFAULT FOR NOT USED ALTERNATIVES
   assign s_alt0 = 1'b0;
   assign s_alt1 = 1'b0;
   assign s_alt2 = 1'b0;
   assign s_alt3 = 1'b0;

   /////////////////////////////////////////////////////////////////////////////////////////////
   // OUTPUT ENABLE 
   /////////////////////////////////////////////////////////////////////////////////////////////
   assign oe_spim_sdio0_o  = ~spi_oen_i[0][0]    ;
   assign oe_spim_sdio1_o  = ~spi_oen_i[0][1]    ;
   assign oe_spim_sdio2_o  = ~spi_oen_i[0][2]    ;
   assign oe_spim_sdio3_o  = ~spi_oen_i[0][3]    ;
   assign oe_spim_csn0_o   = 1'b1                ;
   assign oe_spim_csn1_o   = 1'b1                ;
   assign oe_spim_sck_o    = 1'b1                ;
   assign oe_uart_rx_o     = 1'b0                ;
   assign oe_uart_tx_o     = 1'b1                ;
   assign oe_cam_pclk_o    = 1'b0                ;
   assign oe_cam_hsync_o   = 1'b0                ;
   assign oe_cam_data0_o   = 1'b0                ;
   assign oe_cam_data1_o   = 1'b0                ;
   assign oe_cam_data2_o   = 1'b0                ;
   assign oe_cam_data3_o   = 1'b0                ;
   assign oe_cam_data4_o   = 1'b0                ;
   assign oe_cam_data5_o   = 1'b0                ;
   assign oe_cam_data6_o   = 1'b0                ;
   assign oe_cam_data7_o   = 1'b0                ;
   assign oe_cam_vsync_o   = 1'b0                ;
   assign oe_sdio_clk_o    = 1'b1                ;
   assign oe_sdio_cmd_o    = ~sdio_cmd_oen_i     ;
   assign oe_sdio_data0_o  = ~sdio_data_oen_i[0] ;
   assign oe_sdio_data1_o  = ~sdio_data_oen_i[1] ;
   assign oe_sdio_data2_o  = ~sdio_data_oen_i[2] ;
   assign oe_sdio_data3_o  = ~sdio_data_oen_i[3] ;
   assign oe_i2c0_sda_o    = i2c_sda_oe_i[0]     ;
   assign oe_i2c0_scl_o    = i2c_scl_oe_i[0]     ;
   assign oe_i2s0_sck_o    = i2s_slave_sck_oe    ;
   assign oe_i2s0_ws_o     = i2s_slave_ws_oe     ;
   assign oe_i2s0_sdi_o    = 1'b0                ;
   assign oe_i2s1_sdi_o    = 1'b0                ;
   
   assign oe_gpios_o[31:0] = gpio_dir_i[31:0]    ;
   assign oe_i2c1_sda_o    = i2c_sda_oe_i[1]     ;
   assign oe_i2c1_scl_o    = i2c_scl_oe_i[1]     ;

   assign oe_hyper_cs0n_o   = 1'b1               ;
   assign oe_hyper_cs1n_o   = 1'b1               ;
   assign oe_hyper_ck_o     = 1'b1               ;
   assign oe_hyper_ckn_o    = 1'b1               ;
   assign oe_hyper_rwds0_o  = hyper_rwds_oe_i[0] ;
   assign oe_hyper_rwds1_o  = hyper_rwds_oe_i[1] ;
   assign oe_hyper_dq0_o    = hyper_dq_oe_o[0]   ;
   assign oe_hyper_dq1_o    = hyper_dq_oe_o[1]   ;
   assign oe_hyper_resetn_o = 1'b1               ;

   ////////////////////////////////////////////////////////////////
   // DATA OUTPUT
   ////////////////////////////////////////////////////////////////
   assign out_spim_sdio0_o = spi_sdo_i[0][0]    ;
   assign out_spim_sdio1_o = spi_sdo_i[0][1]    ;
   assign out_spim_sdio2_o = spi_sdo_i[0][2]    ;
   assign out_spim_sdio3_o = spi_sdo_i[0][3]    ;
   assign out_spim_csn0_o  = spi_csn_i[0][0]    ;
   assign out_spim_csn1_o  = spi_csn_i[0][1]    ;
   assign out_spim_sck_o   = spi_clk_i[0]       ;
   assign out_uart_rx_o    = 1'b0               ;
   assign out_uart_tx_o    = uart_tx_i          ;
   assign out_cam_pclk_o   = 1'b0               ;
   assign out_cam_hsync_o  = 1'b0               ;
   assign out_cam_data0_o  = 1'b0               ;
   assign out_cam_data1_o  = 1'b0               ;
   assign out_cam_data2_o  = 1'b0               ;
   assign out_cam_data3_o  = 1'b0               ;
   assign out_cam_data4_o  = 1'b0               ;
   assign out_cam_data5_o  = 1'b0               ;
   assign out_cam_data6_o  = 1'b0               ;
   assign out_cam_data7_o  = 1'b0               ;
   assign out_cam_vsync_o  = 1'b0               ;
   assign out_sdio_clk_o   = sdio_clk_i         ;
   assign out_sdio_cmd_o   = sdio_cmd_i         ;
   assign out_sdio_data0_o = sdio_data_i[0]     ;
   assign out_sdio_data1_o = sdio_data_i[1]     ;
   assign out_sdio_data2_o = sdio_data_i[2]     ;
   assign out_sdio_data3_o = sdio_data_i[3]     ;
   assign out_i2c0_sda_o   = i2c_sda_out_i[0]   ;
   assign out_i2c0_scl_o   = i2c_scl_out_i[0]   ;
   assign out_i2s0_sck_o   = i2s_slave_sck_i    ;
   assign out_i2s0_ws_o    = i2s_slave_ws_i     ;
   assign out_i2s0_sdi_o   = 1'b0               ;
   assign out_i2s1_sdi_o   = 1'b0               ;
   
   assign out_gpios_o[31:0]= gpio_out_i[31:0]   ;
   assign out_i2c1_sda_o   = i2c_sda_out_i[1]   ;
   assign out_i2c1_scl_o   = i2c_scl_out_i[1]   ;

   assign out_hyper_cs0n_o   = hyper_cs_ni[0]    ;
   assign out_hyper_cs1n_o   = hyper_cs_ni[1]    ;
   assign out_hyper_ck_o     = hyper_ck_i        ;
   assign out_hyper_ckn_o    = hyper_ck_ni       ;
   assign out_hyper_rwds0_o  = hyper_rwds_i[0]   ;
   assign out_hyper_rwds1_o  = hyper_rwds_i[1]   ;
   assign out_hyper_dq0_o    = hyper_dq_i[7:0]   ;
   assign out_hyper_dq1_o    = hyper_dq_i[15:8]  ;
   assign out_hyper_resetn_o = hyper_reset_no    ; 

   ////////////////////////////////////////////////////////////////
   // DATA INPUT
   ////////////////////////////////////////////////////////////////

   // SPI
   assign sdio_cmd_o      = in_sdio_cmd_i    ;
   assign sdio_data_o[0]  = in_sdio_data0_i  ;
   assign sdio_data_o[1]  = in_sdio_data1_i  ;
   assign sdio_data_o[2]  = in_sdio_data2_i  ;
   assign sdio_data_o[3]  = in_sdio_data3_i  ;

   // CAMERA
   assign cam_pclk_o      = in_cam_pclk_i    ;
   assign cam_hsync_o     = in_cam_hsync_i   ;
   assign cam_data_o[0]   = in_cam_data0_i   ;
   assign cam_data_o[1]   = in_cam_data1_i   ;
   assign cam_data_o[2]   = in_cam_data2_i   ;
   assign cam_data_o[3]   = in_cam_data3_i   ;
   assign cam_data_o[4]   = in_cam_data4_i   ;
   assign cam_data_o[5]   = in_cam_data5_i   ;
   assign cam_data_o[6]   = in_cam_data6_i   ;
   assign cam_data_o[7]   = in_cam_data7_i   ;
   assign cam_vsync_o     = in_cam_vsync_i   ;

   // I2C1
   assign i2c_sda_in_o[1] = in_i2c1_sda_i;
   assign i2c_scl_in_o[1] = in_i2c1_scl_i;

   assign i2s_slave_sd1_o = in_i2s1_sdi_i    ;

   // UART
   assign uart_rx_o       = in_uart_rx_i     ;

   // SPI
   assign spi_sdi_o[0][0] = in_spim_sdio0_i  ;
   assign spi_sdi_o[0][1] = in_spim_sdio1_i  ;
   assign spi_sdi_o[0][2] = in_spim_sdio2_i  ;
   assign spi_sdi_o[0][3] = in_spim_sdio3_i  ;

   
   // I2C0
   assign i2c_sda_in_o[0] = in_i2c0_sda_i    ;
   assign i2c_scl_in_o[0] = in_i2c0_scl_i    ;
   assign i2s_slave_sck_o = in_i2s0_sck_i    ;
   assign i2s_slave_ws_o  = in_i2s0_ws_i     ;
   assign i2s_slave_sd0_o = in_i2s0_sdi_i    ;

   // GPIO
   assign gpio_in_o[31:0] = in_gpios_i[31:0] ;

   // HYPER
   assign hyper_dq_o[7:0]  = in_hyper_dq0_i   ;
   assign hyper_dq_o[15:8] = in_hyper_dq1_i   ;
   assign hyper_rwds_o     = in_hyper_rwds0_i ;

   // PAD CFG mux between default and GPIO
   assign pad_cfg_o[40:0]  = pad_cfg_i[40:0]  ;
   for(genvar i=0; i<32; i++)  begin
        assign pad_cfg_o[i+41] = { 2'b00 , gpio_cfg_i[i][3:0] } ;
   end

endmodule

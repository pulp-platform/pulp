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
        input  logic [63:0][1:0] pad_mux_i        ,
        input  logic [63:0][5:0] pad_cfg_i        ,
        output logic [47:0][5:0] pad_cfg_o        ,

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
        output logic             oe_i2s1_sdi_o
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
   assign oe_spim_sdio0_o  = (pad_mux_i[0 ] == 2'b00) ? ~spi_oen_i[0][0]    : ((pad_mux_i[0 ] == 2'b01) ? gpio_dir_i[0 ] : ((pad_mux_i[0 ] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_spim_sdio1_o  = (pad_mux_i[1 ] == 2'b00) ? ~spi_oen_i[0][1]    : ((pad_mux_i[1 ] == 2'b01) ? gpio_dir_i[1 ] : ((pad_mux_i[1 ] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_spim_sdio2_o  = (pad_mux_i[2 ] == 2'b00) ? ~spi_oen_i[0][2]    : ((pad_mux_i[2 ] == 2'b01) ? gpio_dir_i[2 ] : ((pad_mux_i[2 ] == 2'b10) ? i2c_sda_oe_i[1] : s_alt3 ));
   assign oe_spim_sdio3_o  = (pad_mux_i[3 ] == 2'b00) ? ~spi_oen_i[0][3]    : ((pad_mux_i[3 ] == 2'b01) ? gpio_dir_i[3 ] : ((pad_mux_i[3 ] == 2'b10) ? i2c_scl_oe_i[1] : s_alt3 ));
   assign oe_spim_csn0_o   = (pad_mux_i[4 ] == 2'b00) ? 1'b1                : ((pad_mux_i[4 ] == 2'b01) ? gpio_dir_i[4 ] : ((pad_mux_i[4 ] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_spim_csn1_o   = (pad_mux_i[5 ] == 2'b00) ? 1'b1                : ((pad_mux_i[5 ] == 2'b01) ? gpio_dir_i[5 ] : ((pad_mux_i[5 ] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_spim_sck_o    = (pad_mux_i[6 ] == 2'b00) ? 1'b1                : ((pad_mux_i[6 ] == 2'b01) ? gpio_dir_i[6 ] : ((pad_mux_i[6 ] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_uart_rx_o     = (pad_mux_i[7 ] == 2'b00) ? 1'b0                : ((pad_mux_i[7 ] == 2'b01) ? gpio_dir_i[7 ] : ((pad_mux_i[7 ] == 2'b10) ? i2c_sda_oe_i[1] : s_alt3 ));
   assign oe_uart_tx_o     = (pad_mux_i[8 ] == 2'b00) ? 1'b1                : ((pad_mux_i[8 ] == 2'b01) ? gpio_dir_i[8 ] : ((pad_mux_i[8 ] == 2'b10) ? i2c_scl_oe_i[1] : s_alt3 ));
   assign oe_cam_pclk_o    = (pad_mux_i[9 ] == 2'b00) ? 1'b0                : ((pad_mux_i[9 ] == 2'b01) ? gpio_dir_i[9 ] : ((pad_mux_i[9 ] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_hsync_o   = (pad_mux_i[10] == 2'b00) ? 1'b0                : ((pad_mux_i[10] == 2'b01) ? gpio_dir_i[10] : ((pad_mux_i[10] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data0_o   = (pad_mux_i[11] == 2'b00) ? 1'b0                : ((pad_mux_i[11] == 2'b01) ? gpio_dir_i[11] : ((pad_mux_i[11] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data1_o   = (pad_mux_i[12] == 2'b00) ? 1'b0                : ((pad_mux_i[12] == 2'b01) ? gpio_dir_i[12] : ((pad_mux_i[12] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data2_o   = (pad_mux_i[13] == 2'b00) ? 1'b0                : ((pad_mux_i[13] == 2'b01) ? gpio_dir_i[13] : ((pad_mux_i[13] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data3_o   = (pad_mux_i[14] == 2'b00) ? 1'b0                : ((pad_mux_i[14] == 2'b01) ? gpio_dir_i[14] : ((pad_mux_i[14] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data4_o   = (pad_mux_i[15] == 2'b00) ? 1'b0                : ((pad_mux_i[15] == 2'b01) ? gpio_dir_i[15] : ((pad_mux_i[15] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data5_o   = (pad_mux_i[16] == 2'b00) ? 1'b0                : ((pad_mux_i[16] == 2'b01) ? gpio_dir_i[16] : ((pad_mux_i[16] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data6_o   = (pad_mux_i[17] == 2'b00) ? 1'b0                : ((pad_mux_i[17] == 2'b01) ? gpio_dir_i[17] : ((pad_mux_i[17] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_data7_o   = (pad_mux_i[18] == 2'b00) ? 1'b0                : ((pad_mux_i[18] == 2'b01) ? gpio_dir_i[18] : ((pad_mux_i[18] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_cam_vsync_o   = (pad_mux_i[19] == 2'b00) ? 1'b0                : ((pad_mux_i[19] == 2'b01) ? gpio_dir_i[19] : ((pad_mux_i[19] == 2'b10) ? 1'b1            : s_alt3 ));
   assign oe_sdio_clk_o    = (pad_mux_i[20] == 2'b00) ? 1'b1                : ((pad_mux_i[20] == 2'b01) ? gpio_dir_i[20] : ((pad_mux_i[20] == 2'b10) ? 1'b0            : s_alt3 ));
   assign oe_sdio_cmd_o    = (pad_mux_i[21] == 2'b00) ? ~sdio_cmd_oen_i     : ((pad_mux_i[21] == 2'b01) ? gpio_dir_i[21] : ((pad_mux_i[21] == 2'b10) ? 1'b0            : s_alt3 ));
   assign oe_sdio_data0_o  = (pad_mux_i[22] == 2'b00) ? ~sdio_data_oen_i[0] : ((pad_mux_i[22] == 2'b01) ? gpio_dir_i[22] : ((pad_mux_i[22] == 2'b10) ? 1'b0            : s_alt3 ));
   assign oe_sdio_data1_o  = (pad_mux_i[23] == 2'b00) ? ~sdio_data_oen_i[1] : ((pad_mux_i[23] == 2'b01) ? gpio_dir_i[23] : ((pad_mux_i[23] == 2'b10) ? 1'b0            : s_alt3 ));
   assign oe_sdio_data2_o  = (pad_mux_i[24] == 2'b00) ? ~sdio_data_oen_i[2] : ((pad_mux_i[24] == 2'b01) ? gpio_dir_i[24] : ((pad_mux_i[24] == 2'b10) ? i2c_sda_oe_i[1] : s_alt3 ));
   assign oe_sdio_data3_o  = (pad_mux_i[25] == 2'b00) ? ~sdio_data_oen_i[3] : ((pad_mux_i[25] == 2'b01) ? gpio_dir_i[25] : ((pad_mux_i[25] == 2'b10) ? i2c_scl_oe_i[1] : s_alt3 ));
   assign oe_i2c0_sda_o    = (pad_mux_i[33] == 2'b00) ? i2c_sda_oe_i[0]     : ((pad_mux_i[33] == 2'b01) ? gpio_dir_i[26] : ((pad_mux_i[33] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_i2c0_scl_o    = (pad_mux_i[34] == 2'b00) ? i2c_scl_oe_i[0]     : ((pad_mux_i[34] == 2'b01) ? gpio_dir_i[27] : ((pad_mux_i[34] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_i2s0_sck_o    = (pad_mux_i[35] == 2'b00) ? i2s_slave_sck_oe    : ((pad_mux_i[35] == 2'b01) ? gpio_dir_i[28] : ((pad_mux_i[35] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_i2s0_ws_o     = (pad_mux_i[36] == 2'b00) ? i2s_slave_ws_oe     : ((pad_mux_i[36] == 2'b01) ? gpio_dir_i[29] : ((pad_mux_i[36] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_i2s0_sdi_o    = (pad_mux_i[37] == 2'b00) ? 1'b0                : ((pad_mux_i[37] == 2'b01) ? gpio_dir_i[30] : ((pad_mux_i[37] == 2'b10) ? s_alt2          : s_alt3 ));
   assign oe_i2s1_sdi_o    = (pad_mux_i[38] == 2'b00) ? 1'b0                : ((pad_mux_i[38] == 2'b01) ? gpio_dir_i[31] : ((pad_mux_i[38] == 2'b10) ? s_alt2          : s_alt3 ));

   /////////////////////////////////////////////////////////////////////////////////////////////
   // DATA OUTPUT
   /////////////////////////////////////////////////////////////////////////////////////////////
   assign out_spim_sdio0_o = (pad_mux_i[0 ] == 2'b00) ? spi_sdo_i[0][0]    : ((pad_mux_i[0 ] == 2'b01) ? gpio_out_i[0 ] : ((pad_mux_i[0 ] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_spim_sdio1_o = (pad_mux_i[1 ] == 2'b00) ? spi_sdo_i[0][1]    : ((pad_mux_i[1 ] == 2'b01) ? gpio_out_i[1 ] : ((pad_mux_i[1 ] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_spim_sdio2_o = (pad_mux_i[2 ] == 2'b00) ? spi_sdo_i[0][2]    : ((pad_mux_i[2 ] == 2'b01) ? gpio_out_i[2 ] : ((pad_mux_i[2 ] == 2'b10) ? i2c_sda_out_i[1] : s_alt3 ));
   assign out_spim_sdio3_o = (pad_mux_i[3 ] == 2'b00) ? spi_sdo_i[0][3]    : ((pad_mux_i[3 ] == 2'b01) ? gpio_out_i[3 ] : ((pad_mux_i[3 ] == 2'b10) ? i2c_scl_out_i[1] : s_alt3 ));
   assign out_spim_csn0_o  = (pad_mux_i[4 ] == 2'b00) ? spi_csn_i[0][0]    : ((pad_mux_i[4 ] == 2'b01) ? gpio_out_i[4 ] : ((pad_mux_i[4 ] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_spim_csn1_o  = (pad_mux_i[5 ] == 2'b00) ? spi_csn_i[0][1]    : ((pad_mux_i[5 ] == 2'b01) ? gpio_out_i[5 ] : ((pad_mux_i[5 ] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_spim_sck_o   = (pad_mux_i[6 ] == 2'b00) ? spi_clk_i[0]       : ((pad_mux_i[6 ] == 2'b01) ? gpio_out_i[6 ] : ((pad_mux_i[6 ] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_uart_rx_o    = (pad_mux_i[7 ] == 2'b00) ? 1'b0               : ((pad_mux_i[7 ] == 2'b01) ? gpio_out_i[7 ] : ((pad_mux_i[7 ] == 2'b10) ? i2c_sda_out_i[1] : s_alt3 ));
   assign out_uart_tx_o    = (pad_mux_i[8 ] == 2'b00) ? uart_tx_i          : ((pad_mux_i[8 ] == 2'b01) ? gpio_out_i[8 ] : ((pad_mux_i[8 ] == 2'b10) ? i2c_scl_out_i[1] : s_alt3 ));
   assign out_cam_pclk_o   = (pad_mux_i[9 ] == 2'b00) ? 1'b0               : ((pad_mux_i[9 ] == 2'b01) ? gpio_out_i[9 ] : ((pad_mux_i[9 ] == 2'b10) ? timer1_i[0]      : s_alt3 ));
   assign out_cam_hsync_o  = (pad_mux_i[10] == 2'b00) ? 1'b0               : ((pad_mux_i[10] == 2'b01) ? gpio_out_i[10] : ((pad_mux_i[10] == 2'b10) ? timer1_i[1]      : s_alt3 ));
   assign out_cam_data0_o  = (pad_mux_i[11] == 2'b00) ? 1'b0               : ((pad_mux_i[11] == 2'b01) ? gpio_out_i[11] : ((pad_mux_i[11] == 2'b10) ? timer1_i[2]      : s_alt3 ));
   assign out_cam_data1_o  = (pad_mux_i[12] == 2'b00) ? 1'b0               : ((pad_mux_i[12] == 2'b01) ? gpio_out_i[12] : ((pad_mux_i[12] == 2'b10) ? timer1_i[3]      : s_alt3 ));
   assign out_cam_data2_o  = (pad_mux_i[13] == 2'b00) ? 1'b0               : ((pad_mux_i[13] == 2'b01) ? gpio_out_i[13] : ((pad_mux_i[13] == 2'b10) ? timer2_i[0]      : s_alt3 ));
   assign out_cam_data3_o  = (pad_mux_i[14] == 2'b00) ? 1'b0               : ((pad_mux_i[14] == 2'b01) ? gpio_out_i[14] : ((pad_mux_i[14] == 2'b10) ? timer2_i[1]      : s_alt3 ));
   assign out_cam_data4_o  = (pad_mux_i[15] == 2'b00) ? 1'b0               : ((pad_mux_i[15] == 2'b01) ? gpio_out_i[15] : ((pad_mux_i[15] == 2'b10) ? timer2_i[2]      : s_alt3 ));
   assign out_cam_data5_o  = (pad_mux_i[16] == 2'b00) ? 1'b0               : ((pad_mux_i[16] == 2'b01) ? gpio_out_i[16] : ((pad_mux_i[16] == 2'b10) ? timer2_i[3]      : s_alt3 ));
   assign out_cam_data6_o  = (pad_mux_i[17] == 2'b00) ? 1'b0               : ((pad_mux_i[17] == 2'b01) ? gpio_out_i[17] : ((pad_mux_i[17] == 2'b10) ? timer3_i[0]      : s_alt3 ));
   assign out_cam_data7_o  = (pad_mux_i[18] == 2'b00) ? 1'b0               : ((pad_mux_i[18] == 2'b01) ? gpio_out_i[18] : ((pad_mux_i[18] == 2'b10) ? timer3_i[1]      : s_alt3 ));
   assign out_cam_vsync_o  = (pad_mux_i[19] == 2'b00) ? 1'b0               : ((pad_mux_i[19] == 2'b01) ? gpio_out_i[19] : ((pad_mux_i[19] == 2'b10) ? timer3_i[2]      : s_alt3 ));
   assign out_sdio_clk_o   = (pad_mux_i[20] == 2'b00) ? sdio_clk_i         : ((pad_mux_i[20] == 2'b01) ? gpio_out_i[20] : ((pad_mux_i[20] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_sdio_cmd_o   = (pad_mux_i[21] == 2'b00) ? sdio_cmd_i         : ((pad_mux_i[21] == 2'b01) ? gpio_out_i[21] : ((pad_mux_i[21] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_sdio_data0_o = (pad_mux_i[22] == 2'b00) ? sdio_data_i[0]     : ((pad_mux_i[22] == 2'b01) ? gpio_out_i[22] : ((pad_mux_i[22] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_sdio_data1_o = (pad_mux_i[23] == 2'b00) ? sdio_data_i[1]     : ((pad_mux_i[23] == 2'b01) ? gpio_out_i[23] : ((pad_mux_i[23] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_sdio_data2_o = (pad_mux_i[24] == 2'b00) ? sdio_data_i[2]     : ((pad_mux_i[24] == 2'b01) ? gpio_out_i[24] : ((pad_mux_i[24] == 2'b10) ? i2c_sda_out_i[1] : s_alt3 ));
   assign out_sdio_data3_o = (pad_mux_i[25] == 2'b00) ? sdio_data_i[3]     : ((pad_mux_i[25] == 2'b01) ? gpio_out_i[25] : ((pad_mux_i[25] == 2'b10) ? i2c_scl_out_i[1] : s_alt3 ));
   assign out_i2c0_sda_o   = (pad_mux_i[33] == 2'b00) ? i2c_sda_out_i[0]   : ((pad_mux_i[33] == 2'b01) ? gpio_out_i[26] : ((pad_mux_i[33] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_i2c0_scl_o   = (pad_mux_i[34] == 2'b00) ? i2c_scl_out_i[0]   : ((pad_mux_i[34] == 2'b01) ? gpio_out_i[27] : ((pad_mux_i[34] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_i2s0_sck_o   = (pad_mux_i[35] == 2'b00) ? i2s_slave_sck_i    : ((pad_mux_i[35] == 2'b01) ? gpio_out_i[28] : ((pad_mux_i[35] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_i2s0_ws_o    = (pad_mux_i[36] == 2'b00) ? i2s_slave_ws_i     : ((pad_mux_i[36] == 2'b01) ? gpio_out_i[29] : ((pad_mux_i[36] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_i2s0_sdi_o   = (pad_mux_i[37] == 2'b00) ? 1'b0               : ((pad_mux_i[37] == 2'b01) ? gpio_out_i[30] : ((pad_mux_i[37] == 2'b10) ? s_alt2           : s_alt3 ));
   assign out_i2s1_sdi_o   = (pad_mux_i[38] == 2'b00) ? 1'b0               : ((pad_mux_i[38] == 2'b01) ? gpio_out_i[31] : ((pad_mux_i[38] == 2'b10) ? s_alt2           : s_alt3 ));

   /////////////////////////////////////////////////////////////////////////////////////////////
   // DATA INPUT
   /////////////////////////////////////////////////////////////////////////////////////////////
   //    SPI MASTER1
   // assign spi_master1_sdi_o = (pad_mux_i[0]  == 2'b00) ? in_rf_miso_i: (pad_mux_i[40] == 2'b00) ? in_spim1_miso_i : 1'b0;

   assign sdio_cmd_o      = (pad_mux_i[21] == 2'b00) ? in_sdio_cmd_i    : 1'b0;
   assign sdio_data_o[0]  = (pad_mux_i[22] == 2'b00) ? in_sdio_data0_i  : 1'b0;
   assign sdio_data_o[1]  = (pad_mux_i[23] == 2'b00) ? in_sdio_data1_i  : 1'b0;
   assign sdio_data_o[2]  = (pad_mux_i[24] == 2'b00) ? in_sdio_data2_i  : 1'b0;
   assign sdio_data_o[3]  = (pad_mux_i[25] == 2'b00) ? in_sdio_data3_i  : 1'b0;

   //    CAMERA
   assign cam_pclk_o      = (pad_mux_i[ 9] == 2'b00) ? in_cam_pclk_i    : 1'b0;
   assign cam_hsync_o     = (pad_mux_i[10] == 2'b00) ? in_cam_hsync_i   : 1'b0;
   assign cam_data_o[0]   = (pad_mux_i[11] == 2'b00) ? in_cam_data0_i   : 1'b0;
   assign cam_data_o[1]   = (pad_mux_i[12] == 2'b00) ? in_cam_data1_i   : 1'b0;
   assign cam_data_o[2]   = (pad_mux_i[13] == 2'b00) ? in_cam_data2_i   : 1'b0;
   assign cam_data_o[3]   = (pad_mux_i[14] == 2'b00) ? in_cam_data3_i   : 1'b0;
   assign cam_data_o[4]   = (pad_mux_i[15] == 2'b00) ? in_cam_data4_i   : 1'b0;
   assign cam_data_o[5]   = (pad_mux_i[16] == 2'b00) ? in_cam_data5_i   : 1'b0;
   assign cam_data_o[6]   = (pad_mux_i[17] == 2'b00) ? in_cam_data6_i   : 1'b0;
   assign cam_data_o[7]   = (pad_mux_i[18] == 2'b00) ? in_cam_data7_i   : 1'b0;
   assign cam_vsync_o     = (pad_mux_i[19] == 2'b00) ? in_cam_vsync_i   : 1'b0;

   //    I2C1
   assign i2c_sda_in_o[1] = (pad_mux_i[2]  == 2'b10) ? in_spim_sdio2_i  : (pad_mux_i[7] == 2'b10)  ? in_uart_rx_i  : (pad_mux_i[24] == 2'b10) ? in_sdio_data2_i : 1'b1 ;
   assign i2c_scl_in_o[1] = (pad_mux_i[3]  == 2'b10) ? in_spim_sdio3_i  : (pad_mux_i[8] == 2'b10)  ? in_uart_tx_i  : (pad_mux_i[25] == 2'b10) ? in_sdio_data3_i : 1'b1 ;

   assign i2s_slave_sd1_o = (pad_mux_i[29] == 2'b00) ? in_i2s1_sdi_i    : (pad_mux_i[27] == 2'b11) ? in_i2s1_sdi_i : 1'b0;

   //    UART
   assign uart_rx_o       = (pad_mux_i[38] == 2'b00) ? in_uart_rx_i     : 1'b1;

   //    SPI
   assign spi_sdi_o[0][0] = (pad_mux_i[33] == 2'b00) ? in_spim_sdio0_i  : 1'b0;
   assign spi_sdi_o[0][1] = (pad_mux_i[34] == 2'b00) ? in_spim_sdio1_i  : 1'b0;
   assign spi_sdi_o[0][2] = (pad_mux_i[35] == 2'b00) ? in_spim_sdio2_i  : 1'b0;
   assign spi_sdi_o[0][3] = (pad_mux_i[36] == 2'b00) ? in_spim_sdio3_i  : 1'b0;

   //    I2C0
   assign i2c_sda_in_o[0] = (pad_mux_i[43] == 2'b00) ? in_i2c0_sda_i    : 1'b1;
   assign i2c_scl_in_o[0] = (pad_mux_i[44] == 2'b00) ? in_i2c0_scl_i    : 1'b1;


   assign i2s_slave_sck_o = (pad_mux_i[45] == 2'b00) ? in_i2s0_sck_i    : 1'b0;
   assign i2s_slave_ws_o  = (pad_mux_i[46] == 2'b00) ? in_i2s0_ws_i     : 1'b0;
   assign i2s_slave_sd0_o = (pad_mux_i[47] == 2'b00) ? in_i2s0_sdi_i    : 1'b0;

   //    GPIO
   assign gpio_in_o[0]  = (pad_mux_i[0]  == 2'b01) ? in_spim_sdio0_i : 1'b0 ;
   assign gpio_in_o[1]  = (pad_mux_i[1]  == 2'b01) ? in_spim_sdio1_i : 1'b0 ;
   assign gpio_in_o[2]  = (pad_mux_i[2]  == 2'b01) ? in_spim_sdio2_i : 1'b0 ;
   assign gpio_in_o[3]  = (pad_mux_i[3]  == 2'b01) ? in_spim_sdio3_i : 1'b0 ;
   assign gpio_in_o[4]  = (pad_mux_i[4]  == 2'b01) ? in_spim_csn0_i  : 1'b0 ;
   assign gpio_in_o[5]  = (pad_mux_i[5]  == 2'b01) ? in_spim_csn1_i  : 1'b0 ;
   assign gpio_in_o[6]  = (pad_mux_i[6]  == 2'b01) ? in_spim_sck_i   : 1'b0 ;
   assign gpio_in_o[7]  = (pad_mux_i[7]  == 2'b01) ? in_uart_rx_i    : 1'b0 ;
   assign gpio_in_o[8]  = (pad_mux_i[8]  == 2'b01) ? in_uart_tx_i    : 1'b0 ;
   assign gpio_in_o[9]  = (pad_mux_i[9]  == 2'b01) ? in_cam_pclk_i   : 1'b0 ;
   assign gpio_in_o[10] = (pad_mux_i[10] == 2'b01) ? in_cam_hsync_i  : 1'b0 ;
   assign gpio_in_o[11] = (pad_mux_i[11] == 2'b01) ? in_cam_data0_i  : 1'b0 ;
   assign gpio_in_o[12] = (pad_mux_i[12] == 2'b01) ? in_cam_data1_i  : 1'b0 ;
   assign gpio_in_o[13] = (pad_mux_i[13] == 2'b01) ? in_cam_data2_i  : 1'b0 ;
   assign gpio_in_o[14] = (pad_mux_i[14] == 2'b01) ? in_cam_data3_i  : 1'b0 ;
   assign gpio_in_o[15] = (pad_mux_i[15] == 2'b01) ? in_cam_data4_i  : 1'b0 ;
   assign gpio_in_o[16] = (pad_mux_i[16] == 2'b01) ? in_cam_data5_i  : 1'b0 ;
   assign gpio_in_o[17] = (pad_mux_i[17] == 2'b01) ? in_cam_data6_i  : 1'b0 ;
   assign gpio_in_o[18] = (pad_mux_i[18] == 2'b01) ? in_cam_data7_i  : 1'b0 ;
   assign gpio_in_o[19] = (pad_mux_i[19] == 2'b01) ? in_cam_vsync_i  : 1'b0 ;
   assign gpio_in_o[20] = (pad_mux_i[20] == 2'b01) ? in_sdio_clk_i   : 1'b0 ;
   assign gpio_in_o[21] = (pad_mux_i[21] == 2'b01) ? in_sdio_cmd_i   : 1'b0 ;
   assign gpio_in_o[22] = (pad_mux_i[22] == 2'b01) ? in_sdio_data0_i : 1'b0 ;
   assign gpio_in_o[23] = (pad_mux_i[23] == 2'b01) ? in_sdio_data1_i : 1'b0 ;
   assign gpio_in_o[24] = (pad_mux_i[24] == 2'b01) ? in_sdio_data2_i : 1'b0 ;
   assign gpio_in_o[25] = (pad_mux_i[25] == 2'b01) ? in_sdio_data3_i : 1'b0 ;
   assign gpio_in_o[26] = (pad_mux_i[33] == 2'b01) ? in_i2c0_sda_i   : 1'b0 ;
   assign gpio_in_o[27] = (pad_mux_i[34] == 2'b01) ? in_i2c0_scl_i   : 1'b0 ;
   assign gpio_in_o[28] = (pad_mux_i[35] == 2'b01) ? in_i2s0_sck_i   : 1'b0 ;
   assign gpio_in_o[29] = (pad_mux_i[36] == 2'b01) ? in_i2s0_ws_i    : 1'b0 ;
   assign gpio_in_o[30] = (pad_mux_i[37] == 2'b01) ? in_i2s0_sdi_i   : 1'b0 ;
   assign gpio_in_o[31] = (pad_mux_i[38] == 2'b01) ? in_i2s1_sdi_i   : 1'b0 ;

   // PAD CFG mux between default and GPIO
   assign pad_cfg_o[0]  = (pad_mux_i[0]  == 2'b01) ? gpio_cfg_i[0]  : pad_cfg_i[0];
   assign pad_cfg_o[1]  = (pad_mux_i[1]  == 2'b01) ? gpio_cfg_i[1]  : pad_cfg_i[1];
   assign pad_cfg_o[2]  = (pad_mux_i[2]  == 2'b01) ? gpio_cfg_i[2]  : pad_cfg_i[2];
   assign pad_cfg_o[3]  = (pad_mux_i[3]  == 2'b01) ? gpio_cfg_i[3]  : pad_cfg_i[3];
   assign pad_cfg_o[4]  = (pad_mux_i[4]  == 2'b01) ? gpio_cfg_i[4]  : pad_cfg_i[4];
   assign pad_cfg_o[5]  = (pad_mux_i[5]  == 2'b01) ? gpio_cfg_i[5]  : pad_cfg_i[5];
   assign pad_cfg_o[6]  = (pad_mux_i[6]  == 2'b01) ? gpio_cfg_i[6]  : pad_cfg_i[6];
   assign pad_cfg_o[7]  = (pad_mux_i[7]  == 2'b01) ? gpio_cfg_i[7]  : pad_cfg_i[7];
   assign pad_cfg_o[8]  = (pad_mux_i[8]  == 2'b01) ? gpio_cfg_i[8]  : pad_cfg_i[8];
   assign pad_cfg_o[9]  = (pad_mux_i[9]  == 2'b01) ? gpio_cfg_i[9]  : pad_cfg_i[9];
   assign pad_cfg_o[10] = (pad_mux_i[10] == 2'b01) ? gpio_cfg_i[10] : pad_cfg_i[10];
   assign pad_cfg_o[11] = (pad_mux_i[11] == 2'b01) ? gpio_cfg_i[11] : pad_cfg_i[11];
   assign pad_cfg_o[12] = (pad_mux_i[12] == 2'b01) ? gpio_cfg_i[12] : pad_cfg_i[12];
   assign pad_cfg_o[13] = (pad_mux_i[13] == 2'b01) ? gpio_cfg_i[13] : pad_cfg_i[13];
   assign pad_cfg_o[14] = (pad_mux_i[14] == 2'b01) ? gpio_cfg_i[14] : pad_cfg_i[14];
   assign pad_cfg_o[15] = (pad_mux_i[15] == 2'b01) ? gpio_cfg_i[15] : pad_cfg_i[15];
   assign pad_cfg_o[16] = (pad_mux_i[16] == 2'b01) ? gpio_cfg_i[16] : pad_cfg_i[16];
   assign pad_cfg_o[17] = (pad_mux_i[17] == 2'b01) ? gpio_cfg_i[17] : pad_cfg_i[17];
   assign pad_cfg_o[18] = (pad_mux_i[18] == 2'b01) ? gpio_cfg_i[18] : pad_cfg_i[18];
   assign pad_cfg_o[19] = (pad_mux_i[19] == 2'b01) ? gpio_cfg_i[19] : pad_cfg_i[19];
   assign pad_cfg_o[20] = (pad_mux_i[20] == 2'b01) ? gpio_cfg_i[20] : pad_cfg_i[20];
   assign pad_cfg_o[21] = (pad_mux_i[21] == 2'b01) ? gpio_cfg_i[21] : pad_cfg_i[21];
   assign pad_cfg_o[22] = (pad_mux_i[22] == 2'b01) ? gpio_cfg_i[22] : pad_cfg_i[22];
   assign pad_cfg_o[23] = (pad_mux_i[23] == 2'b01) ? gpio_cfg_i[23] : pad_cfg_i[23];
   assign pad_cfg_o[24] = (pad_mux_i[24] == 2'b01) ? gpio_cfg_i[24] : pad_cfg_i[24];
   assign pad_cfg_o[25] = (pad_mux_i[25] == 2'b01) ? gpio_cfg_i[25] : pad_cfg_i[25];
   assign pad_cfg_o[26] =                                             pad_cfg_i[26];
   assign pad_cfg_o[27] =                                             pad_cfg_i[27];
   assign pad_cfg_o[28] =                                             pad_cfg_i[28];
   assign pad_cfg_o[29] =                                             pad_cfg_i[29];
   assign pad_cfg_o[30] =                                             pad_cfg_i[30];
   assign pad_cfg_o[31] =                                             pad_cfg_i[31];
   assign pad_cfg_o[32] =                                             pad_cfg_i[32];
   assign pad_cfg_o[33] = (pad_mux_i[33] == 2'b01) ? gpio_cfg_i[26] : pad_cfg_i[33];
   assign pad_cfg_o[34] = (pad_mux_i[34] == 2'b01) ? gpio_cfg_i[27] : pad_cfg_i[34];
   assign pad_cfg_o[35] = (pad_mux_i[35] == 2'b01) ? gpio_cfg_i[28] : pad_cfg_i[35];
   assign pad_cfg_o[36] = (pad_mux_i[36] == 2'b01) ? gpio_cfg_i[29] : pad_cfg_i[36];
   assign pad_cfg_o[37] = (pad_mux_i[37] == 2'b01) ? gpio_cfg_i[30] : pad_cfg_i[37];
   assign pad_cfg_o[38] = (pad_mux_i[38] == 2'b01) ? gpio_cfg_i[31] : pad_cfg_i[38];

endmodule

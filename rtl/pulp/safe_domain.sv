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
 * cluster_domain.sv
 * Davide Rossi <davide.rossi@unibo.it>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Pasquale Davide Schiavone <pschiavo@iss.ee.ethz.ch>
 */

`include "pulp_soc_defines.sv"

module safe_domain
    #(
        parameter FLL_DATA_WIDTH = 32,
        parameter FLL_ADDR_WIDTH = 32
    )
    (
        input logic 		 ref_clk_i ,
        output logic 		 slow_clk_o ,
        input logic 		 rst_ni ,
        output logic 		 rst_no ,

        output logic 		 test_clk_o ,
        output logic 		 test_mode_o ,
        output logic 		 mode_select_o ,
        output logic 		 dft_cg_enable_o ,

        output logic 		 sel_fll_clk_o,

        input logic 		 jtag_tck_i ,
        input logic 		 jtag_trst_ni ,
        input logic 		 jtag_tms_i ,
        input logic 		 jtag_tdi_i ,
        output logic 		 jtag_tdo_o ,

        output logic 		 soc_tck_o ,
        output logic 		 soc_trstn_o ,

        output logic 		 jtag_shift_dr_o ,
        output logic 		 jtag_update_dr_o ,
        output logic 		 jtag_capture_dr_o ,

        output logic 		 axireg_sel_o ,
        output logic 		 axireg_tdi_o ,
        input logic 		 axireg_tdo_i ,

        input logic [7:0] 	 soc_jtag_reg_i ,
        output logic [7:0] 	 soc_jtag_reg_o ,

        //**********************************************************
        //*** PERIPHERALS SIGNALS **********************************
        //**********************************************************

        // PAD CONTROL REGISTER
        input logic [127:0] 	 pad_mux_i ,
        input logic [383:0] 	 pad_cfg_i ,

        output logic [47:0][5:0] pad_cfg_o ,

`ifdef HYPER_RAM
        // Hyper interface
        input logic 		 hyper_clk_i ,
        input logic 		 hyper_clkn_i ,
        input logic 		 hyper_csn0_i ,
        input logic 		 hyper_csn1_i ,
        input logic 		 hyper_rwds_i ,
        input logic 		 hyper_rwds_oen_i ,
        output logic 		 hyper_rwds_o ,
        input logic 		 hyper_dq_oen_i ,
        input logic [7:0] 	 hyper_dq_i ,
        output logic [7:0] 	 hyper_dq_o ,
`endif
        // GPIOS
        input logic [31:0] 	 gpio_out_i ,
        output logic [31:0] 	 gpio_in_o ,
        input logic [31:0] 	 gpio_dir_i ,
        input logic [191:0] 	 gpio_cfg_i ,

        // UART
        input logic 		 uart_tx_i ,
        output logic 		 uart_rx_o ,

        // I2C0
        input logic 		 i2c0_scl_out_i ,
        output logic 		 i2c0_scl_in_o ,
        input logic 		 i2c0_scl_oe_i ,
        input logic 		 i2c0_sda_out_i ,
        output logic 		 i2c0_sda_in_o ,
        input logic 		 i2c0_sda_oe_i ,

        // I2C1
        input logic 		 i2c1_scl_out_i ,
        output logic 		 i2c1_scl_in_o ,
        input logic 		 i2c1_scl_oe_i ,
        input logic 		 i2c1_sda_out_i ,
        output logic 		 i2c1_sda_in_o ,
        input logic 		 i2c1_sda_oe_i ,

        // I2S
        output logic 		 i2s_sd0_in_o ,
        output logic 		 i2s_sd1_in_o ,
        output logic 		 i2s_sck_in_o ,
        output logic 		 i2s_ws_in_o ,
        input logic 		 i2s_sck0_out_i ,
        input logic 		 i2s_ws0_out_i ,
        input logic [1:0] 	 i2s_mode0_out_i ,
        input logic 		 i2s_sck1_out_i ,
        input logic 		 i2s_ws1_out_i ,
        input logic [1:0] 	 i2s_mode1_out_i ,

        // SPI MASTER
        input logic 		 spi_master0_csn0_i ,
        input logic 		 spi_master0_csn1_i ,
        input logic 		 spi_master0_sck_i ,
        output logic 		 spi_master0_sdi0_o ,
        output logic 		 spi_master0_sdi1_o ,
        output logic 		 spi_master0_sdi2_o ,
        output logic 		 spi_master0_sdi3_o ,
        input logic 		 spi_master0_sdo0_i ,
        input logic 		 spi_master0_sdo1_i ,
        input logic 		 spi_master0_sdo2_i ,
        input logic 		 spi_master0_sdo3_i ,
        input logic [1:0] 	 spi_master0_mode_i,

        input logic 		 spi_master1_csn0_i ,
        input logic 		 spi_master1_csn1_i ,
        input logic 		 spi_master1_sck_i ,
        output logic 		 spi_master1_sdi_o ,
        input logic 		 spi_master1_sdo_i ,
        input logic [1:0] 	 spi_master1_mode_i ,
        
        input logic 		 sdio_clk_i ,
        input logic 		 sdio_cmd_i ,
        output logic 		 sdio_cmd_o ,
        input logic 		 sdio_cmd_oen_i ,
        input logic [3:0] 	 sdio_data_i ,
        output logic [3:0] 	 sdio_data_o ,
        input logic [3:0] 	 sdio_data_oen_i ,
     
        // CAMERA INTERFACE
        output logic 		 cam_pclk_o ,
        output logic [7:0] 	 cam_data_o ,
        output logic 		 cam_hsync_o ,
        output logic 		 cam_vsync_o ,

        // TIMER
        input logic [3:0] 	 timer0_i ,
        input logic [3:0] 	 timer1_i ,
        input logic [3:0] 	 timer2_i ,
        input logic [3:0] 	 timer3_i ,

        //**********************************************************
        //*** PAD FRAME SIGNALS ************************************
        //**********************************************************

        // PADS OUTPUTS
        output logic 		 out_spim_sdio0_o ,
        output logic 		 out_spim_sdio1_o ,
        output logic 		 out_spim_sdio2_o ,
        output logic 		 out_spim_sdio3_o ,
        output logic 		 out_spim_csn0_o ,
        output logic 		 out_spim_csn1_o ,
        output logic 		 out_spim_sck_o ,
        output logic 		 out_sdio_clk_o ,
        output logic 		 out_sdio_cmd_o ,
        output logic 		 out_sdio_data0_o ,
        output logic 		 out_sdio_data1_o ,
        output logic 		 out_sdio_data2_o ,
        output logic 		 out_sdio_data3_o ,
        output logic 		 out_uart_rx_o ,
        output logic 		 out_uart_tx_o ,
        output logic 		 out_cam_pclk_o ,
        output logic 		 out_cam_hsync_o ,
        output logic 		 out_cam_data0_o ,
        output logic 		 out_cam_data1_o ,
        output logic 		 out_cam_data2_o ,
        output logic 		 out_cam_data3_o ,
        output logic 		 out_cam_data4_o ,
        output logic 		 out_cam_data5_o ,
        output logic 		 out_cam_data6_o ,
        output logic 		 out_cam_data7_o ,
        output logic 		 out_cam_vsync_o ,
        output logic 		 out_i2c0_sda_o ,
        output logic 		 out_i2c0_scl_o ,
        output logic 		 out_i2s0_sck_o ,
        output logic 		 out_i2s0_ws_o ,
        output logic 		 out_i2s0_sdi_o ,
        output logic 		 out_i2s1_sdi_o ,


        // PAD INPUTS
        input logic 		 in_spim_sdio0_i ,
        input logic 		 in_spim_sdio1_i ,
        input logic 		 in_spim_sdio2_i ,
        input logic 		 in_spim_sdio3_i ,
        input logic 		 in_spim_csn0_i ,
        input logic 		 in_spim_csn1_i ,
        input logic 		 in_spim_sck_i ,
        input logic 		 in_sdio_clk_i ,
        input logic 		 in_sdio_cmd_i ,
        input logic 		 in_sdio_data0_i ,
        input logic 		 in_sdio_data1_i ,
        input logic 		 in_sdio_data2_i ,
        input logic 		 in_sdio_data3_i ,
        input logic 		 in_uart_rx_i ,
        input logic 		 in_uart_tx_i ,
        input logic 		 in_cam_pclk_i ,
        input logic 		 in_cam_hsync_i ,
        input logic 		 in_cam_data0_i ,
        input logic 		 in_cam_data1_i ,
        input logic 		 in_cam_data2_i ,
        input logic 		 in_cam_data3_i ,
        input logic 		 in_cam_data4_i ,
        input logic 		 in_cam_data5_i ,
        input logic 		 in_cam_data6_i ,
        input logic 		 in_cam_data7_i ,
        input logic 		 in_cam_vsync_i ,
`ifdef HYPER_RAM
        input logic 		 in_hyper_ckn_i ,
        input logic 		 in_hyper_ck_i ,
        input logic 		 in_hyper_dq0_i ,
        input logic 		 in_hyper_dq1_i ,
        input logic 		 in_hyper_dq2_i ,
        input logic 		 in_hyper_dq3_i ,
        input logic 		 in_hyper_dq4_i ,
        input logic 		 in_hyper_dq5_i ,
        input logic 		 in_hyper_dq6_i ,
        input logic 		 in_hyper_dq7_i ,
        input logic 		 in_hyper_csn0_i ,
        input logic 		 in_hyper_csn1_i ,
        input logic 		 in_hyper_rwds_i ,
`endif
        input logic 		 in_i2c0_sda_i ,
        input logic 		 in_i2c0_scl_i ,
        input logic 		 in_i2s0_sck_i ,
        input logic 		 in_i2s0_ws_i ,
        input logic 		 in_i2s0_sdi_i ,
        input logic 		 in_i2s1_sdi_i ,

        // OUTPUT ENABLE
        output logic 		 oe_spim_sdio0_o ,
        output logic 		 oe_spim_sdio1_o ,
        output logic 		 oe_spim_sdio2_o ,
        output logic 		 oe_spim_sdio3_o ,
        output logic 		 oe_spim_csn0_o ,
        output logic 		 oe_spim_csn1_o ,
        output logic 		 oe_spim_sck_o ,
        output logic             oe_sdio_clk_o        ,
        output logic             oe_sdio_cmd_o        ,
        output logic             oe_sdio_data0_o      ,
        output logic             oe_sdio_data1_o      ,
        output logic             oe_sdio_data2_o      ,
        output logic             oe_sdio_data3_o      ,
        output logic 		 oe_uart_rx_o ,
        output logic 		 oe_uart_tx_o ,
        output logic 		 oe_cam_pclk_o ,
        output logic 		 oe_cam_hsync_o ,
        output logic 		 oe_cam_data0_o ,
        output logic 		 oe_cam_data1_o ,
        output logic 		 oe_cam_data2_o ,
        output logic 		 oe_cam_data3_o ,
        output logic 		 oe_cam_data4_o ,
        output logic 		 oe_cam_data5_o ,
        output logic 		 oe_cam_data6_o ,
        output logic 		 oe_cam_data7_o ,
        output logic 		 oe_cam_vsync_o ,
        output logic 		 oe_i2c0_sda_o ,
        output logic 		 oe_i2c0_scl_o ,
        output logic 		 oe_i2s0_sck_o ,
        output logic 		 oe_i2s0_ws_o ,
        output logic 		 oe_i2s0_sdi_o ,
        output logic 		 oe_i2s1_sdi_o ,

        output logic 		 boot_l2_o
    );

    logic        s_test_clk;

    logic        s_rtc_int;
    logic        s_gpio_wake;
    logic        s_jtag_rstn;
    logic        s_rstn_sync;
    logic        s_rstn;

    //**********************************************************
    //*** GPIO CONFIGURATIONS **********************************
    //**********************************************************

   logic [31:0][5:0] s_gpio_cfg;

   genvar i,j;

    pad_control pad_control_i
    (

        //********************************************************************//
        //*** PERIPHERALS SIGNALS ********************************************//
        //********************************************************************//
        .pad_mux_i             ( pad_mux_i             ),
        .pad_cfg_i             ( pad_cfg_i             ),
        .pad_cfg_o             ( pad_cfg_o             ),
`ifdef HYPER_RAM
        .hyper_clk_i           ( hyper_clk_i           ),
        .hyper_clkn_i          ( hyper_clkn_i          ),
        .hyper_csn0_i          ( hyper_csn0_i          ),
        .hyper_csn1_i          ( hyper_csn1_i          ),
        .hyper_rwds_i          ( hyper_rwds_i          ),
        .hyper_rwds_oen_i      ( hyper_rwds_oen_i      ),
        .hyper_rwds_o          ( hyper_rwds_o          ),
        .hyper_dq_oen_i        ( hyper_dq_oen_i        ),
        .hyper_dq_i            ( hyper_dq_i            ),
        .hyper_dq_o            ( hyper_dq_o            ),
`endif
        .gpio_out_i            ( gpio_out_i            ),
        .gpio_in_o             ( gpio_in_o             ),
        .gpio_dir_i            ( gpio_dir_i            ),
        .gpio_cfg_i            ( s_gpio_cfg            ),

        .uart_tx_i             ( uart_tx_i             ),
        .uart_rx_o             ( uart_rx_o             ),

        .i2c0_scl_out_i        ( i2c0_scl_out_i        ),
        .i2c0_scl_in_o         ( i2c0_scl_in_o         ),
        .i2c0_scl_oe_i         ( i2c0_scl_oe_i         ),
        .i2c0_sda_out_i        ( i2c0_sda_out_i        ),
        .i2c0_sda_in_o         ( i2c0_sda_in_o         ),
        .i2c0_sda_oe_i         ( i2c0_sda_oe_i         ),

        .i2c1_scl_out_i        ( i2c1_scl_out_i        ),
        .i2c1_scl_in_o         ( i2c1_scl_in_o         ),
        .i2c1_scl_oe_i         ( i2c1_scl_oe_i         ),
        .i2c1_sda_out_i        ( i2c1_sda_out_i        ),
        .i2c1_sda_in_o         ( i2c1_sda_in_o         ),
        .i2c1_sda_oe_i         ( i2c1_sda_oe_i         ),

        .i2s_sd0_in_o          ( i2s_sd0_in_o          ),
        .i2s_sd1_in_o          ( i2s_sd1_in_o          ),
        .i2s_sck_in_o          ( i2s_sck_in_o          ),
        .i2s_ws_in_o           ( i2s_ws_in_o           ),
        .i2s_sck0_out_i        ( i2s_sck0_out_i        ),
        .i2s_ws0_out_i         ( i2s_ws0_out_i         ),
        .i2s_mode0_out_i       ( i2s_mode0_out_i       ),
        .i2s_sck1_out_i        ( i2s_sck1_out_i        ),
        .i2s_ws1_out_i         ( i2s_ws1_out_i         ),
        .i2s_mode1_out_i       ( i2s_mode1_out_i       ),

        .spi_master0_csn0_i    ( spi_master0_csn0_i    ),
        .spi_master0_csn1_i    ( spi_master0_csn1_i    ),
        .spi_master0_sck_i     ( spi_master0_sck_i     ),
        .spi_master0_sdi0_o    ( spi_master0_sdi0_o    ),
        .spi_master0_sdi1_o    ( spi_master0_sdi1_o    ),
        .spi_master0_sdi2_o    ( spi_master0_sdi2_o    ),
        .spi_master0_sdi3_o    ( spi_master0_sdi3_o    ),
        .spi_master0_sdo0_i    ( spi_master0_sdo0_i    ),
        .spi_master0_sdo1_i    ( spi_master0_sdo1_i    ),
        .spi_master0_sdo2_i    ( spi_master0_sdo2_i    ),
        .spi_master0_sdo3_i    ( spi_master0_sdo3_i    ),
        .spi_master0_mode_i    ( spi_master0_mode_i    ),
        
        .sdio_clk_i            ( sdio_clk_i            ),
        .sdio_cmd_i            ( sdio_cmd_i            ),
        .sdio_cmd_o            ( sdio_cmd_o            ),
        .sdio_cmd_oen_i        ( sdio_cmd_oen_i        ),
        .sdio_data_i           ( sdio_data_i           ),
        .sdio_data_o           ( sdio_data_o           ),
        .sdio_data_oen_i       ( sdio_data_oen_i       ),
        
        .spi_master1_csn0_i    ( spi_master1_csn0_i    ),
        .spi_master1_csn1_i    ( spi_master1_csn1_i    ),
        .spi_master1_sck_i     ( spi_master1_sck_i     ),
        .spi_master1_sdi_o     ( spi_master1_sdi_o     ),
        .spi_master1_sdo_i     ( spi_master1_sdo_i     ),
        .spi_master1_mode_i    ( spi_master1_mode_i    ),

        .cam_pclk_o            ( cam_pclk_o            ),
        .cam_data_o            ( cam_data_o            ),
        .cam_hsync_o           ( cam_hsync_o           ),
        .cam_vsync_o           ( cam_vsync_o           ),

        .timer0_i              ( timer0_i              ),
        .timer1_i              ( timer1_i              ),
        .timer2_i              ( timer2_i              ),
        .timer3_i              ( timer3_i              ),

        .out_spim_sdio0_o      ( out_spim_sdio0_o      ),
        .out_spim_sdio1_o      ( out_spim_sdio1_o      ),
        .out_spim_sdio2_o      ( out_spim_sdio2_o      ),
        .out_spim_sdio3_o      ( out_spim_sdio3_o      ),
        .out_spim_csn0_o       ( out_spim_csn0_o       ),
        .out_spim_csn1_o       ( out_spim_csn1_o       ),
        .out_spim_sck_o        ( out_spim_sck_o        ),
        .out_sdio_clk_o        ( out_sdio_clk_o        ),
        .out_sdio_cmd_o        ( out_sdio_cmd_o        ),
        .out_sdio_data0_o      ( out_sdio_data0_o      ),
        .out_sdio_data1_o      ( out_sdio_data1_o      ),
        .out_sdio_data2_o      ( out_sdio_data2_o      ),
        .out_sdio_data3_o      ( out_sdio_data3_o      ),
        .out_uart_rx_o         ( out_uart_rx_o         ),
        .out_uart_tx_o         ( out_uart_tx_o         ),
        .out_cam_pclk_o        ( out_cam_pclk_o        ),
        .out_cam_hsync_o       ( out_cam_hsync_o       ),
        .out_cam_data0_o       ( out_cam_data0_o       ),
        .out_cam_data1_o       ( out_cam_data1_o       ),
        .out_cam_data2_o       ( out_cam_data2_o       ),
        .out_cam_data3_o       ( out_cam_data3_o       ),
        .out_cam_data4_o       ( out_cam_data4_o       ),
        .out_cam_data5_o       ( out_cam_data5_o       ),
        .out_cam_data6_o       ( out_cam_data6_o       ),
        .out_cam_data7_o       ( out_cam_data7_o       ),
        .out_cam_vsync_o       ( out_cam_vsync_o       ),
        .out_i2c0_sda_o        ( out_i2c0_sda_o        ),
        .out_i2c0_scl_o        ( out_i2c0_scl_o        ),
        .out_i2s0_sck_o        ( out_i2s0_sck_o        ),
        .out_i2s0_ws_o         ( out_i2s0_ws_o         ),
        .out_i2s0_sdi_o        ( out_i2s0_sdi_o        ),
        .out_i2s1_sdi_o        ( out_i2s1_sdi_o        ),

        .in_spim_sdio0_i       ( in_spim_sdio0_i       ),
        .in_spim_sdio1_i       ( in_spim_sdio1_i       ),
        .in_spim_sdio2_i       ( in_spim_sdio2_i       ),
        .in_spim_sdio3_i       ( in_spim_sdio3_i       ),
        .in_spim_csn0_i        ( in_spim_csn0_i        ),
        .in_spim_csn1_i        ( in_spim_csn1_i        ),
        .in_spim_sck_i         ( in_spim_sck_i         ),
        .in_sdio_clk_i         ( in_sdio_clk_i         ),
        .in_sdio_cmd_i         ( in_sdio_cmd_i         ),
        .in_sdio_data0_i       ( in_sdio_data0_i       ),
        .in_sdio_data1_i       ( in_sdio_data1_i       ),
        .in_sdio_data2_i       ( in_sdio_data2_i       ),
        .in_sdio_data3_i       ( in_sdio_data3_i       ),
        .in_uart_rx_i          ( in_uart_rx_i          ),
        .in_uart_tx_i          ( in_uart_tx_i          ),
        .in_cam_pclk_i         ( in_cam_pclk_i         ),
        .in_cam_hsync_i        ( in_cam_hsync_i        ),
        .in_cam_data0_i        ( in_cam_data0_i        ),
        .in_cam_data1_i        ( in_cam_data1_i        ),
        .in_cam_data2_i        ( in_cam_data2_i        ),
        .in_cam_data3_i        ( in_cam_data3_i        ),
        .in_cam_data4_i        ( in_cam_data4_i        ),
        .in_cam_data5_i        ( in_cam_data5_i        ),
        .in_cam_data6_i        ( in_cam_data6_i        ),
        .in_cam_data7_i        ( in_cam_data7_i        ),
        .in_cam_vsync_i        ( in_cam_vsync_i        ),
        .in_i2c0_sda_i         ( in_i2c0_sda_i         ),
        .in_i2c0_scl_i         ( in_i2c0_scl_i         ),
        .in_i2s0_sck_i         ( in_i2s0_sck_i         ),
        .in_i2s0_ws_i          ( in_i2s0_ws_i          ),
        .in_i2s0_sdi_i         ( in_i2s0_sdi_i         ),
        .in_i2s1_sdi_i         ( in_i2s1_sdi_i         ),

        .oe_spim_sdio0_o       ( oe_spim_sdio0_o       ),
        .oe_spim_sdio1_o       ( oe_spim_sdio1_o       ),
        .oe_spim_sdio2_o       ( oe_spim_sdio2_o       ),
        .oe_spim_sdio3_o       ( oe_spim_sdio3_o       ),
        .oe_spim_csn0_o        ( oe_spim_csn0_o        ),
        .oe_spim_csn1_o        ( oe_spim_csn1_o        ),
        .oe_spim_sck_o         ( oe_spim_sck_o         ),
        .oe_sdio_clk_o         ( oe_sdio_clk_o         ),
        .oe_sdio_cmd_o         ( oe_sdio_cmd_o         ),
        .oe_sdio_data0_o       ( oe_sdio_data0_o       ),
        .oe_sdio_data1_o       ( oe_sdio_data1_o       ),
        .oe_sdio_data2_o       ( oe_sdio_data2_o       ),
        .oe_sdio_data3_o       ( oe_sdio_data3_o       ),
        .oe_uart_rx_o          ( oe_uart_rx_o          ),
        .oe_uart_tx_o          ( oe_uart_tx_o          ),
        .oe_cam_pclk_o         ( oe_cam_pclk_o         ),
        .oe_cam_hsync_o        ( oe_cam_hsync_o        ),
        .oe_cam_data0_o        ( oe_cam_data0_o        ),
        .oe_cam_data1_o        ( oe_cam_data1_o        ),
        .oe_cam_data2_o        ( oe_cam_data2_o        ),
        .oe_cam_data3_o        ( oe_cam_data3_o        ),
        .oe_cam_data4_o        ( oe_cam_data4_o        ),
        .oe_cam_data5_o        ( oe_cam_data5_o        ),
        .oe_cam_data6_o        ( oe_cam_data6_o        ),
        .oe_cam_data7_o        ( oe_cam_data7_o        ),
        .oe_cam_vsync_o        ( oe_cam_vsync_o        ),
        .oe_i2c0_sda_o         ( oe_i2c0_sda_o         ),
        .oe_i2c0_scl_o         ( oe_i2c0_scl_o         ),
        .oe_i2s0_sck_o         ( oe_i2s0_sck_o         ),
        .oe_i2s0_ws_o          ( oe_i2s0_ws_o          ),
        .oe_i2s0_sdi_o         ( oe_i2s0_sdi_o         ),
        .oe_i2s1_sdi_o         ( oe_i2s1_sdi_o         ),

        .*
    );

    jtag_tap_top jtag_tap_top_i
    (
        .tck_i                   ( jtag_tck_i             ),
        .trst_ni                 ( s_jtag_rstn            ),
        .tms_i                   ( jtag_tms_i             ),
        .td_i                    ( jtag_tdi_i             ),
        .td_o                    ( jtag_tdo_o             ),

        .soc_tck_o               ( soc_tck_o              ),
        .soc_trstn_o             ( soc_trstn_o            ),

        .test_clk_i              ( s_test_clk             ),
        .test_rstn_i             ( s_rstn_sync            ),

        .jtag_shift_dr_o         ( jtag_shift_dr_o        ),
        .jtag_update_dr_o        ( jtag_update_dr_o       ),
        .jtag_capture_dr_o       ( jtag_capture_dr_o      ),

        .axireg_sel_o            ( axireg_sel_o           ),
        .dbg_axi_scan_in_o       ( axireg_tdi_o           ),
        .dbg_axi_scan_out_i      ( axireg_tdo_i           ),
        .soc_jtag_reg_i          ( soc_jtag_reg_i         ),
        .soc_jtag_reg_o          ( soc_jtag_reg_o         ),
        .sel_fll_clk_o           ( sel_fll_clk_o          )
    );

`ifndef PULP_FPGA_EMUL
    rstgen i_rstgen
    (
        .clk_i       ( ref_clk_i   ),
        .rst_ni      ( s_rstn      ),
        .test_mode_i ( test_mode_o ),
        .rst_no      ( s_rstn_sync ),  //to be used by logic clocked with ref clock in AO domain
        .init_no     (             )  //not used
    );
`else
    assign s_rstn_sync = s_rstn;
`endif

`ifndef PULP_FPGA_EMUL

        logic ref_clk_div8;
        logic ref_clk_0;
        logic ref_clk_1;
        logic ref_clk_2;

        always_ff @(posedge ref_clk_i or negedge rst_ni) begin
            if(~rst_ni) begin
                ref_clk_0 <= 1'b0;
                ref_clk_1 <= 1'b0;
                ref_clk_2 <= 1'b0;
            end else begin
                ref_clk_0 <= ~ref_clk_2;
                ref_clk_1 <= ref_clk_0;
                ref_clk_2 <= ref_clk_1;
            end
        end

        assign ref_clk_div8 = ref_clk_2;

        pulp_clock_mux2 slow_clk_mux_i
        (
            .clk0_i    ( ref_clk_i      ),
            .clk1_i    ( ref_clk_div8   ),
            .clk_sel_i ( sel_fll_clk_o  ),
            .clk_o     ( slow_clk_o     )
        );

        /*
            The slow_clk_o is ref_clk_i / 8
            It is used in case the FLL is broken,
            ref_clk_i replaces the FLL clock and
            slow_clk_o replaces the ref_clk_i for
            timer, and time unit generators
            (as the clock must be slower)
        */

`else
        assign slow_clk_o = ref_clk_i;
`endif

    assign s_rstn          = rst_ni;
    assign s_jtag_rstn     = jtag_trst_ni;
    assign rst_no          = s_rstn;

    assign test_clk_o      = 1'b0;
    assign dft_cg_enable_o = 1'b0;
    assign test_mode_o     = 1'b0;
    assign mode_select_o   = 1'b0;

    //********************************************************
    //*** PAD AND GPIO CONFIGURATION SIGNALS PACK ************
    //********************************************************

    generate
       for (i=0; i<32; i++)
	 begin
	    for (j=0; j<6; j++)
	      begin
		 assign s_gpio_cfg[i][j] = gpio_cfg_i[j+6*i];
	      end
	 end
    endgenerate

endmodule // safe_domain

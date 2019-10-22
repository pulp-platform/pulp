/*
 * Copyright (C) 2013-2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */

`include "ulpsoc_defines.sv"

`ifndef PULP_FPGA_SIM
 `define PULP_FPGA_NETLIST
`endif

module pulpemu
  (
   // LED for VERIFY
   output       LED,
   // FMC pins
   inout        FMC_csi2_clkp,
   inout        FMC_csi2_clkn,
   inout        FMC_csi2_datap0,
   inout        FMC_csi2_datan0,
   inout        FMC_csi2_datap1,
   inout        FMC_csi2_datan1,
   inout        FMC_pwm0,
   inout        FMC_pwm1,
   inout        FMC_pwm2,
   inout        FMC_pwm3,
   inout        FMC_qspi_sdio0,
   inout        FMC_qspi_sdio1,
   inout        FMC_qspi_sdio2,
   inout        FMC_qspi_sdio3,
   inout        FMC_qspi_cs0,
   inout        FMC_qspi_sck,
   inout        FMC_spim0_sck,
   inout        FMC_spim0_cs0,
   inout        FMC_spim0_miso,
   inout        FMC_spim0_mosi,
   inout        FMC_i3c0_sda,
   inout        FMC_i3c0_scl,
   inout        FMC_uart0_rx,
   inout        FMC_uart0_tx,
   inout        FMC_uart1_rx,
   inout        FMC_uart1_tx,
   inout        FMC_spim1_sck,
   inout        FMC_spim1_cs0,
   inout        FMC_spim1_miso,
   inout        FMC_spim1_mosi,
   inout        FMC_i3c1_sda,
   inout        FMC_i3c1_scl,
   inout        FMC_i2s_mst_sck,
   inout        FMC_i2s_mst_ws,
   inout        FMC_i2s_mst_sdo0,
   inout        FMC_i2s_mst_sdo1,
   inout        FMC_i2s_slv_sck,
   inout        FMC_i2s_slv_ws,
   inout        FMC_i2s_slv_sdi0,
   inout        FMC_i2s_slv_sdi1,
   inout        FMC_spim2_sck,
   inout        FMC_spim2_cs0,
   inout        FMC_spim2_miso,
   inout        FMC_spim2_mosi,
   inout        FMC_i3c2_sda,
   inout        FMC_i3c2_scl,
   inout        FMC_cam_pclk,
   inout        FMC_cam_hsync,
   inout        FMC_cam_data0,
   inout        FMC_cam_data1,
   inout        FMC_cam_data2,
   inout        FMC_cam_data3,
   inout        FMC_cam_data4,
   inout        FMC_cam_data5,
   inout        FMC_cam_data6,
   inout        FMC_cam_data7,
   inout        FMC_cam_vsync,
   inout        FMC_hyper_ckn,
   inout        FMC_hyper_ck,
   inout        FMC_hyper_dq0,
   inout        FMC_hyper_dq1,
   inout        FMC_hyper_dq2,
   inout        FMC_hyper_dq3,
   inout        FMC_hyper_dq4,
   inout        FMC_hyper_dq5,
   inout        FMC_hyper_dq6,
   inout        FMC_hyper_dq7,
   inout        FMC_hyper_csn0,
   inout        FMC_hyper_csn1,
   inout        FMC_hyper_rwds,
   inout        FMC_jtag_tck,
   inout        FMC_jtag_tdi,
   inout        FMC_jtag_tdo,
   inout        FMC_jtag_tms,
   inout        FMC_jtag_trst,
   inout        FMC_bootmode,
   inout        FMC_reset_n
   );

   // pulpemu top signals
   logic        zynq_clk;
   logic        zynq_rst_n;
   logic        pulp_soc_clk;
   logic        pulp_cluster_clk;

   // reference 32768 Hz clock
   wire         ref_clk;


   pulpemu_ref_clk_div
     #(
       .DIVISOR           ( 256  )
       )
   ref_clk_div (
                .clk_i            ( zynq_clk                      ), // FPGA inner clock,  8.388608 MHz
                .rstn_i           ( zynq_rst_n                    ), // FPGA inner reset
                .ref_clk_o        ( ref_clk                       )  // REF clock out
                );

  // 1 socond blink LED
  pulpemu_ref_clk_div
    #(
      .DIVISOR            ( 32768 )
      )
   led_clk_div (
                .clk_i            ( ref_clk                       ),
                .rstn_i           ( zynq_rst_n                    ),
                .ref_clk_o        ( LED                           )
                );


   //  ██████╗ ██╗   ██╗██╗     ██████╗     ██████╗██╗  ██╗██╗██████╗
   //  ██╔══██╗██║   ██║██║     ██╔══██╗   ██╔════╝██║  ██║██║██╔══██╗
   //  ██████╔╝██║   ██║██║     ██████╔╝   ██║     ███████║██║██████╔╝
   //  ██╔═══╝ ██║   ██║██║     ██╔═══╝    ██║     ██╔══██║██║██╔═══╝
   //  ██║     ╚██████╔╝███████╗██║███████╗╚██████╗██║  ██║██║██║
   //  ╚═╝      ╚═════╝ ╚══════╝╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝

   pulpissimo
     #(.CORE_TYPE(CORE_TYPE),
       .USE_FPU(USE_FPU),
       .USE_HWPE(USE_HWPE)
       ) i_pulpissimo
       (
        .pad_spim_sdio0(pad_pmod0_4),
        .pad_spim_sdio1(pad_pmod0_5),
        .pad_spim_sdio2(pad_pmod0_6),
        .pad_spim_sdio3(pad_pmod0_7),
        // .pad_spim_csn0(pad_uart_rts),
        .pad_spim_csn1(led0_o),
        // .pad_spim_sck(pad_uart_cts),
        .pad_uart_rx(pad_uart_rx),
        .pad_uart_tx(pad_uart_tx),
        .pad_cam_pclk(led1_o),
        .pad_cam_hsync(led2_o),
        .pad_cam_data0(led3_o),
        .pad_cam_data1(switch0_i),
        .pad_cam_data2(switch1_i),
        .pad_cam_data3(btn0_i),
        .pad_cam_data4(btn1_i),
        .pad_cam_data5(btn2_i),
        .pad_cam_data6(btn3_i),
        .pad_cam_data7(switch2_i),
        .pad_cam_vsync(switch3_i),
        // .pad_sdio_clk(pad_hdmi_scl),
        // .pad_sdio_cmd(pad_hdmi_sda),
        // .pad_sdio_data0(pad_pmod1_0),
        // .pad_sdio_data1(pad_pmod1_1),
        // .pad_sdio_data2(pad_pmod1_2),
        // .pad_sdio_data3(pad_pmod1_3),
        // .pad_i2c0_sda(pad_i2c0_sda),
        // .pad_i2c0_scl(pad_i2c0_scl),
        // .pad_i2s0_sck(pad_pmod1_4),
        // .pad_i2s0_ws(pad_pmod1_5),
        // .pad_i2s0_sdi(pad_pmod1_6),
        // .pad_i2s1_sdi(pad_pmod1_7),
        .pad_reset_n(~pad_reset),
        .pad_jtag_tck(pad_jtag_tck),
        .pad_jtag_tdi(pad_jtag_tdi),
        .pad_jtag_tdo(pad_jtag_tdo),
        .pad_jtag_tms(pad_jtag_tms),
        .pad_jtag_trst(1'b1),
        .pad_xtal_in(ref_clk),
        .pad_bootsel()
        );

   pulp_chip pulp_chip_i (
                          .zynq_clk_i            ( ref_clk                       ), // FPGA inner clock, 50 MHz
                          .zynq_soc_clk_i        ( pulp_soc_clk                  ), // FPGA inner clock, 50 MHz
                          .zynq_cluster_clk_i    ( pulp_cluster_clk              ), // FPGA inner clock, 50 MHz
                          .zynq_per_clk_i        ( pulp_per_clk                  ), // FPGA inner clock, 50 MHz

                          .pad_csi2_clkp         ( FMC_csi2_clkp                 ),
                          .pad_csi2_clkn         ( FMC_csi2_clkn                 ),
                          .pad_csi2_datap0       ( FMC_csi2_datap0               ),
                          .pad_csi2_datan0       ( FMC_csi2_datan0               ),
                          .pad_csi2_datap1       ( FMC_csi2_datap1               ),
                          .pad_csi2_datan1       ( FMC_csi2_datan1               ),
                          .pad_pwm0              ( FMC_pwm0                      ),
                          .pad_pwm1              ( FMC_pwm1                      ),
                          .pad_pwm2              ( FMC_pwm2                      ),
                          .pad_pwm3              ( FMC_pwm3                      ),
                          .pad_qspi_sdio0        ( FMC_qspi_sdio0                ),
                          .pad_qspi_sdio1        ( FMC_qspi_sdio1                ),
                          .pad_qspi_sdio2        ( FMC_qspi_sdio2                ),
                          .pad_qspi_sdio3        ( FMC_qspi_sdio3                ),
                          .pad_qspi_cs0          ( FMC_qspi_cs0                  ),
                          .pad_qspi_sck          ( FMC_qspi_sck                  ),
                          .pad_spim0_sck         ( FMC_spim0_sck                 ),
                          .pad_spim0_cs0         ( FMC_spim0_cs0                 ),
                          .pad_spim0_miso        ( FMC_spim0_miso                ),
                          .pad_spim0_mosi        ( FMC_spim0_mosi                ),
                          .pad_i3c0_sda          ( FMC_i3c0_sda                  ),
                          .pad_i3c0_scl          ( FMC_i3c0_scl                  ),
                          .pad_uart0_rx          ( FMC_uart0_rx                   ),
                          .pad_uart0_tx          ( FMC_uart0_tx                   ),
                          .pad_uart1_rx          ( FMC_uart1_rx                   ),
                          .pad_uart1_tx          ( FMC_uart1_tx                   ),
                          .pad_spim1_sck         ( FMC_spim1_sck                 ),
                          .pad_spim1_cs0         ( FMC_spim1_cs0                 ),
                          .pad_spim1_miso        ( FMC_spim1_miso                ),
                          .pad_spim1_mosi        ( FMC_spim1_mosi                ),
                          .pad_i3c1_sda          ( FMC_i3c1_sda                  ),
                          .pad_i3c1_scl          ( FMC_i3c1_scl                  ),
                          .pad_i2s_mst_sck       ( FMC_i2s_mst_sck               ),
                          .pad_i2s_mst_ws        ( FMC_i2s_mst_ws                ),
                          .pad_i2s_mst_sdo0      ( FMC_i2s_mst_sdo0              ),
                          .pad_i2s_mst_sdo1      ( FMC_i2s_mst_sdo1              ),
                          .pad_i2s_slv_sck       ( FMC_i2s_slv_sck               ),
                          .pad_i2s_slv_ws        ( FMC_i2s_slv_ws                ),
                          .pad_i2s_slv_sdi0      ( FMC_i2s_slv_sdi0              ),
                          .pad_i2s_slv_sdi1      ( FMC_i2s_slv_sdi1              ),
                          .pad_spim2_sck         ( FMC_spim2_sck                 ),
                          .pad_spim2_cs0         ( FMC_spim2_cs0                 ),
                          .pad_spim2_miso        ( FMC_spim2_miso                ),
                          .pad_spim2_mosi        ( FMC_spim2_mosi                ),
                          .pad_i3c2_sda          ( FMC_i3c2_sda                  ),
                          .pad_i3c2_scl          ( FMC_i3c2_scl                  ),
                          .pad_cam_pclk          ( FMC_cam_pclk                  ),
                          .pad_cam_hsync         ( FMC_cam_hsync                 ),
                          .pad_cam_data0         ( FMC_cam_data0                 ),
                          .pad_cam_data1         ( FMC_cam_data1                 ),
                          .pad_cam_data2         ( FMC_cam_data2                 ),
                          .pad_cam_data3         ( FMC_cam_data3                 ),
                          .pad_cam_data4         ( FMC_cam_data4                 ),
                          .pad_cam_data5         ( FMC_cam_data5                 ),
                          .pad_cam_data6         ( FMC_cam_data6                 ),
                          .pad_cam_data7         ( FMC_cam_data7                 ),
                          .pad_cam_vsync         ( FMC_cam_vsync                 ),
                          .pad_hyper_ckn         ( FMC_hyper_ckn                 ),
                          .pad_hyper_ck          ( FMC_hyper_ck                  ),
                          .pad_hyper_dq0         ( FMC_hyper_dq0                 ),
                          .pad_hyper_dq1         ( FMC_hyper_dq1                 ),
                          .pad_hyper_dq2         ( FMC_hyper_dq2                 ),
                          .pad_hyper_dq3         ( FMC_hyper_dq3                 ),
                          .pad_hyper_dq4         ( FMC_hyper_dq4                 ),
                          .pad_hyper_dq5         ( FMC_hyper_dq5                 ),
                          .pad_hyper_dq6         ( FMC_hyper_dq6                 ),
                          .pad_hyper_dq7         ( FMC_hyper_dq7                 ),

                           // Pay attention, the Chip select of Pulp FMC Sensor Board is inverted
                          .pad_hyper_csn0        ( FMC_hyper_csn0                ),
                          .pad_hyper_csn1        ( FMC_hyper_csn1                ),

                          .pad_hyper_rwds        ( FMC_hyper_rwds                ),
                          .pad_jtag_tdi          ( FMC_jtag_tdi                  ), // inout  wire
                          .pad_jtag_tdo          ( FMC_jtag_tdo                  ), // inout  wire
                          .pad_jtag_tms          ( FMC_jtag_tms                  ), // inout  wire
                          .pad_jtag_trst         ( FMC_jtag_trst                 ), // inout  wire
                          .pad_jtag_tck          ( FMC_jtag_tck                  ), // inout  wire
                          .pad_bootmode          ( FMC_bootmode                  ),  // Boot mode = 0; boot from flash; Boot mode = 1; boot from jtag
                          .pad_reset_n           ( FMC_reset_n                   ) // inout  wire

                          );


endmodule // pulpemu

//-----------------------------------------------------------------------------
// Title         : PULPissimo Verilog Wrapper
//-----------------------------------------------------------------------------
// File          : xilinx_pulpissimo.v
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 21.05.2019
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of PULPissimo to use the module within Xilinx IP integrator.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

module pulpemu
  (
   input wire  ref_clk_p,
   input wire  ref_clk_n,

   inout wire  pad_uart_rx,
   inout wire  pad_uart_tx,
  
   inout       FMC_sdio_data0,
   inout       FMC_sdio_data1,
   inout       FMC_sdio_data2,
   inout       FMC_sdio_data3,
   inout       FMC_sdio_cmd,
   inout       FMC_sdio_sck,
  

   inout       FMC_qspi_sdio0,
   inout       FMC_qspi_sdio1,
   inout       FMC_qspi_sdio2,
   inout       FMC_qspi_sdio3,
   inout       FMC_qspi_csn0,
   inout       FMC_qspi_csn1,
   inout       FMC_qspi_sck,

   inout       FMC_i2c0_sda,
   inout       FMC_i2c0_scl,

   inout       FMC_i2s0_sck,
   inout       FMC_i2s0_ws,
   inout       FMC_i2s0_sdi,
   inout       FMC_i2s1_sdi,
  
  
   inout       FMC_cam_pclk,
   inout       FMC_cam_hsync,
   inout       FMC_cam_data0,
   inout       FMC_cam_data1,
   inout       FMC_cam_data2,
   inout       FMC_cam_data3,
   inout       FMC_cam_data4,
   inout       FMC_cam_data5,
   inout       FMC_cam_data6,
   inout       FMC_cam_data7,
   inout       FMC_cam_vsync,

   input wire  pad_reset,

   input wire  pad_jtag_tck,
   input wire  pad_jtag_tdi,
   output wire pad_jtag_tdo,
   input wire  pad_jtag_tms
 );

   localparam CORE_TYPE = 0; // 0 for RISCY, 1 for ZERORISCY, 2 for MICRORISCY
   localparam USE_FPU   = 1;
   localparam USE_HWPE = 1;

   wire        ref_clk;

   logic       reset_n;

   assign reset_n = ~pad_reset & pad_jtag_trst;


   //Differential to single ended clock conversion
   IBUFGDS
     #(
       .IOSTANDARD("LVDS"),
       .DIFF_TERM("FALSE"),
       .IBUF_LOW_PWR("FALSE"))
   i_sysclk_iobuf
     (
      .I(ref_clk_p),
      .IB(ref_clk_n),
      .O(ref_clk)
      );

   pulp
     #(.CORE_TYPE(CORE_TYPE),
       .USE_FPU(USE_FPU),
       .USE_HWPE(USE_HWPE)
       ) i_pulp
       (

        .pad_spim_sdio0(FMC_qspi_sdio0),
        .pad_spim_sdio1(FMC_qspi_sdio1),
        .pad_spim_sdio2(FMC_qspi_sdio2),
        .pad_spim_sdio3(FMC_qspi_sdio3),
        .pad_spim_csn0(FMC_qspi_csn0),
        .pad_spim_csn1(FMC_qspi_csn1),
        .pad_spim_sck(FMC_qspi_sck),
        
        .pad_uart_rx(pad_uart_rx),   //keep
        .pad_uart_tx(pad_uart_tx),   //keep
        
        .pad_cam_pclk(FMC_cam_pclk),
        .pad_cam_hsync(FMC_cam_hsync),
        .pad_cam_data0(FMC_cam_data0),
        .pad_cam_data1(FMC_cam_data1),
        .pad_cam_data2(FMC_cam_data2),
        .pad_cam_data3(FMC_cam_data3),
        .pad_cam_data4(FMC_cam_data4),
        .pad_cam_data5(FMC_cam_data5),
        .pad_cam_data6(FMC_cam_data6),
        .pad_cam_data7(FMC_cam_data7),
        .pad_cam_vsync(FMC_cam_vsync),
        
        
        .pad_sdio_clk(FMC_sdio_sck),
        .pad_sdio_cmd(FMC_sdio_cmd),
        .pad_sdio_data0(FMC_sdio_data0),
        .pad_sdio_data1(FMC_sdio_data1),
        .pad_sdio_data2(FMC_sdio_data2),
        .pad_sdio_data3(FMC_sdio_data3),
        
        .pad_i2c0_sda(FMC_i2c0_sda),
        .pad_i2c0_scl(FMC_i2c0_scl),
        .pad_i2s0_sck(FMC_i2s0_sck),
        .pad_i2s0_ws(FMC_i2s0_ws),
        .pad_i2s0_sdi(FMC_i2s0_sdi),
        .pad_i2s1_sdi(FMC_i2s1_sdi),
        
        .pad_reset_n(reset_n),
        
        .pad_jtag_tck(pad_jtag_tck), //keep
        .pad_jtag_tdi(pad_jtag_tdi), //keep
        .pad_jtag_tdo(pad_jtag_tdo), //keep
        .pad_jtag_tms(pad_jtag_tms), //keep
        .pad_jtag_trst(1'b1),        //keep
        
        .pad_xtal_in(ref_clk),       //keep
        .pad_bootsel()               //keep
        );

endmodule

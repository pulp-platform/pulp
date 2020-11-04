//-----------------------------------------------------------------------------
// Title         : FPGA slow clk generator for PULPissimo
//-----------------------------------------------------------------------------
// File          : fpga_slow_clk_gen.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 20.05.2019
//-----------------------------------------------------------------------------
// Description : Instantiates Xilinx Clocking Wizard IP to generate the slow_clk
// signal since for certain boards the available clock sources are to fast to
// use directly.
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


module fpga_slow_clk_gen
  #(
    parameter CLK_DIV_VALUE = 256 //The xilinx_slow_clk_mngr is supposed to
                                  //generate an 8.3886MHz clock. We need to divide it
                                  //by 256 to arrive to a 32.768kHz clock
    )
  (input logic ref_clk_i,
   input logic rst_ni,
   output logic slow_clk_o
   );



  localparam COUNTER_WIDTH = $clog2(CLK_DIV_VALUE);


  //Create clock divider using BUFGCE cells as the PLL/MMCM cannot generate clocks
  //slower than 4.69 MHz and we need 32.768kHz

  logic [COUNTER_WIDTH-1:0] clk_counter_d, clk_counter_q;
  logic                     clock_gate_en;

  logic                     intermmediate_clock;

  xilinx_slow_clk_mngr i_slow_clk_mngr
    (
     .resetn(rst_ni),
     .clk_in1(ref_clk_i),
     .clk_out1(intermmediate_clock)
     );



  always_comb begin
    if (clk_counter_q == CLK_DIV_VALUE-1) begin
      clk_counter_d = '0;
      clock_gate_en = 1'b1;
    end else begin
      clk_counter_d = clk_counter_q + 1;
      clock_gate_en = 1'b0;
    end
  end

  always_ff @(posedge intermmediate_clock, negedge rst_ni) begin
    if (!rst_ni) begin
      clk_counter_q <= '0;
    end else begin
      clk_counter_q <= clk_counter_d;
    end
  end

  BUFGCE i_clock_gate
    (
      .I(intermmediate_clock),
      .CE(clock_gate_en),
      .O(slow_clk_o)
     );

endmodule : fpga_slow_clk_gen

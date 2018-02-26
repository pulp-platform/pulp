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
 * tb_clk_gen.sv
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 */

module tb_clk_gen #(
   parameter CLK_PERIOD = 1.0
) (
   output logic   clk_o
);

   initial
   begin
      clk_o  = 1'b1;

      // wait one cycle first
      #(CLK_PERIOD);

      forever clk_o = #(CLK_PERIOD/2) ~clk_o;
   end

endmodule

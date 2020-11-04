//-----------------------------------------------------------------------------
// Title : FPGA Private RAM Bank for PULPissimo
// -----------------------------------------------------------------------------
// File : fpga_private_ram.sv Author : Manuel Eggimann
// <meggimann@iis.ee.ethz.ch> Created : 20.05.2019
// -----------------------------------------------------------------------------
// Description : Instantiated block ram generator IP to replace the SRAM banks
// in the private region of L2. Since Xilinx LogicoreIP are not customizable
// via parameters, the bank size selected in l2_ram_multibank must match the one
// used in the TCL script for IP generation.
// -----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna Copyright and
// related rights are licensed under the Solderpad Hardware License, Version
// 0.51 (the "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law or
// agreed to in writing, software, hardware and materials distributed under this
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the specific
// language governing permissions and limitations under the License.
// -----------------------------------------------------------------------------

module fpga_private_ram
  #(
    parameter ADDR_WIDTH=12
    ) (
       input logic                  clk_i,
       input logic                  rst_ni,
       input logic                  csn_i,
       input logic                  wen_i,
       input logic [3:0]            be_i,
       input logic [ADDR_WIDTH-1:0] addr_i,
       input logic [31:0]           wdata_i,
       output logic [31:0]          rdata_o
   );

  logic [3:0]                       wea;

  always_comb begin
    if (wen_i == 1'b0) begin
      wea = be_i;
    end else begin
      wea = '0;
    end
  end

  xilinx_private_ram i_xilinx_private_ram
    (
     .clka(clk_i),
     .ena(~csn_i),
     .wea(wea),
     .addra(addr_i),
     .dina(wdata_i),
     .douta(rdata_o)
     );

endmodule : fpga_private_ram

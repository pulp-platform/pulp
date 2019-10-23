//-----------------------------------------------------------------------------
// Title         : FPGA Bootrom for PULP
//-----------------------------------------------------------------------------
// File          : fpga_bootrom.sv
// Author        : Jie Chen  <owenchj@gmail.com>
// Created       : 23.10.2019
//-----------------------------------------------------------------------------
// Description :
// Real boot with jtag reaction.
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


module fpga_bootrom
  #(
    parameter ADDR_WIDTH=32,
    parameter DATA_WIDTH=32
    )
   (
    input logic                   CLK,
    input logic                   RSTN,
    input logic                   CEN,
    input logic [ADDR_WIDTH-1:0]  A,
    output logic [DATA_WIDTH-1:0] Q
    );

   logic [3:0]                    wea;
   logic [31:0]                   dina;

   assign wea  = 4'b0000;
   assign dina = 32'h0000_0000;

   xilinx_rom_bank_2048x32 rom_mem_i (
                                      .clka  (CLK),
                                      .rsta  (~RSTN),
                                      .ena   (~CEN),
                                      .wea   (wea),
                                      .addra (A),
                                      .dina  (dina),
                                      .douta (Q)
                                      );

endmodule : fpga_bootrom

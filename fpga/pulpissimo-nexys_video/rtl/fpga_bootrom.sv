//-----------------------------------------------------------------------------
// Title         : FPGA Bootrom for PULPissimo
//-----------------------------------------------------------------------------
// File          : fpga_bootrom.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 29.05.2019
//-----------------------------------------------------------------------------
// Description :
// Mockup bootrom that keeps returning jal x0,0 to trap the core in an infinite
// loop until the debug module takes over control.
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
   input logic                   CEN,
   input logic [ADDR_WIDTH-1:0]  A,
   output logic [DATA_WIDTH-1:0] Q
   );
  assign Q = 32'h0000006f; //jal x0,0
endmodule : fpga_bootrom

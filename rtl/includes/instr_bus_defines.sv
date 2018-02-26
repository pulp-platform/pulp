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
 * instr_bus_defines.sv
 * Davide Rossi <davide.rossi@unibo.it>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Pasquale Davide Schiavone <pschiavo@iss.ee.ethz.ch>
 */

// INSTRUCTION BUS PARAMETRES

// L2
`define NB_REGION 2

`define MASTER_0_REGION_0_START_ADDR 32'h1A00_0000
`define MASTER_0_REGION_0_END_ADDR   32'h1DFF_FFFF
`define MASTER_0_REGION_1_START_ADDR 32'h1C00_0000
`define MASTER_0_REGION_1_END_ADDR   32'h1FFF_FFFF

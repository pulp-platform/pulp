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
 * pulp_soc_defines.sv
 * Davide Rossi <davide.rossi@unibo.it>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Pasquale Davide Schiavone <pschiavo@iss.ee.ethz.ch>
 */

`ifndef PULP_SOC_DEFINES_SV
`define PULP_SOC_DEFINES_SV

// define if the 0x0000_0000 to 0x0040_0000 is the alias of the current cluster address space (eg cluster 0 is from  0x1000_0000 to 0x1040_0000)
`define CLUSTER_ALIAS
// the same for fabric controller
`define FC_ALIAS

// To use new icache use this define
`define MP_ICACHE
//`define SP_ICACHE
//`define PRIVATE_ICACHE

// To use The L2 Multibank Feature, please decomment this define
`define USE_L2_MULTIBANK
`define NB_L2_CHANNELS 4

// JTAG
`define DMI_JTAG_IDCODE 32'h249511C3


// Hardware Accelerator selection
`define HWCRYPT

// Uncomment if the SCM is not present (it will still be in the memory map)
//`define NO_SCM

`define APU_CLUSTER

// uncomment if you want to place the DEMUX peripherals (EU, MCHAN) rigth before the Test and set region.
// This will steal 16KB from the 1MB TCDM reegion.
// EU is mapped           from 0x10100000 - 0x400
// MCHAN regs are mapped  from 0x10100000 - 0x800
// remember to change the defines in the pulp.h as well to be coherent with this approach
//`define DEM_PER_BEFORE_TCDM_TS



// uncomment if FPGA emulator
// `define PULP_FPGA_EMUL 1
// uncomment if using Vivado for ulpcluster synthesis
`define VIVADO


// Enables memory mapped register and counters to extract statistic on instruction cache
`define FEATURE_ICACHE_STAT




`ifdef PULP_FPGA_EMUL
  // `undef  FEATURE_ICACHE_STAT
  `define SCM_BASED_ICACHE
`endif



// PE selection (only for non-FPGA - otherwise selected via PULP_CORE env variable)
// -> define RISCV for RISC-V processor
//`define RISCV

//PARAMETRES
`define NB_CLUSTERS   1
`define NB_CORES      8
`define NB_DMAS       4
`define NB_MPERIPHS   1
`define NB_SPERIPHS   8


// DEFINES
`define MPER_EXT_ID   0

`define NB_SPERIPH_PLUGS_EU 2

`define SPER_EOC_ID      0
`define SPER_TIMER_ID    1
`define SPER_EVENT_U_ID  2
`define SPER_HWCE_ID     4
`define SPER_ICACHE_CTRL 5
`define SPER_DMA_ID      6
`define SPER_EXT_ID      7


`define RVT 0
`define LVT 1

`ifndef PULP_FPGA_EMUL
  `define LEVEL_SHIFTER
`endif

// Comment to use bheavioral memories, uncomment to use stdcell latches. If uncommented, simulations slowdown occuor
`ifdef SYNTHESIS
 `define SCM_IMPLEMENTED
 `define SCM_BASED_ICACHE
`endif
//////////////////////
// MMU DEFINES
//
// switch for including implementation of MMUs
//`define MMU_IMPLEMENTED
// number of logical TCDM banks (regarding interleaving)
`define MMU_TCDM_BANKS 8
// switch to enable local copy registers of
// the control signals in every MMU
//`define MMU_LOCAL_COPY_REGS
//
//////////////////////

// Width of byte enable for a given data width
`define EVAL_BE_WIDTH(DATAWIDTH) (DATAWIDTH/8)

// LOG2()
`define LOG2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE)< (8) ? 3:(VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : 10)

/* Interfaces have been moved to pulp_interfaces.sv. Sorry :) */

`endif

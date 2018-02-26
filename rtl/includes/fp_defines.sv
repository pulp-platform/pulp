// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// FPU SUPPORT                                                                //
//----------------------------------------------------------------------------//
// select at most one of the following 3 options                              //
// choose between None, Private FPUs, Shared FPUs and Shared LNU              //
////////////////////////////////////////////////////////////////////////////////

//`define PRIVATE_FPU   // private FPU per core
//`define SHARED_LNU   // implements 1-NB_LNUS shared logarithmic number unit
//`define SHARED_FPU // implements 1-NB_FPUS shared floating point units

`define NB_LNUS 1 // valid options: 1
`define NB_FPUS 2 // valid options: 1,2,4 (to be verified)


////////////////////////////////////////////////////////////////////////////////
// The following paramters are not to be modified                             //
// (unless your name is Michael Gautschi)                                     //
////////////////////////////////////////////////////////////////////////////////
`ifdef SHARED_FPU
 `define FP_SUPPORT
 `define APU
 `define FPU
`endif
`ifdef SHARED_LNU
 `define FP_SUPPORT
 `define LNU
 `define APU
// `define LNU_LATENCY_ONE
 `define LNU_LATENCY 3
 `define LNU_FBIT_WIDTH 23
`endif
`ifdef PRIVATE_FPU
 `define FP_SUPPORT
 `define FPU
`endif

////////////////////////////////////////////////////////////////////////////////
// Shared APU support                                                         //
// Defines Bitwidths, and Interfaces between arbiter, APU and Core            //
////////////////////////////////////////////////////////////////////////////////

// FLAGS
`ifdef APU
 `ifdef LNU
  `define NUSFLAGS 3
  `define NDSFLAGS 0
  `define WOP 3
 `endif
 `ifdef FPU
  `define NUSFLAGS 9
  `define NDSFLAGS 2
  `define WOP 4
 `endif
`else
 `ifdef FPU
  `define NUSFLAGS 9
  `define NDSFLAGS 2
  `define WOP 4
 `else
  `define NUSFLAGS -1
  `define NDSFLAGS -1
  `define WOP -1
 `endif
`endif

`define WARG 32
`define WRESULT 32


`ifndef CORE_REGION

 `define NCPUS `NB_CORES

 `ifdef APU
  `ifdef FPU
   `define NAPUS `NB_FPUS
  `endif
  `ifdef LNU
   `define NAPUS `NB_LNUS
  `endif
 `else
  `define NAPUS -1
 `endif

 `define WREGADDR 5
 `define LQUEUE 1


 `define WCPUTAG 5
 `define WAPUTAG (`WCPUTAG+$clog2(`NCPUS))

 `ifdef APU
/// Interface an APU (Auxiliary Processing Unit) is expected to implement in
/// order to be attached to the interconnect and sharing mechanism. See the file
/// apu_template.sv for an example as how to create a module that implements the
/// interface.
interface marx_apu_if;

	 // Downstream
	 logic valid_ds_s;
	 logic ready_ds_s;

	 logic [`WARG-1:0] arga_ds_d;
	 logic [`WARG-1:0] argb_ds_d;
	 logic [`WOP-1:0]  op_ds_d;
	 logic [`NDSFLAGS-1:0] flags_ds_d;
	 logic [`WAPUTAG-1:0]  tag_ds_d;

	 // Upstream
	 logic                 req_us_s;
	 logic                 ack_us_s;

	 logic [`WRESULT-1:0]  result_us_d;
	 logic [`NUSFLAGS-1:0] flags_us_d;
	 logic [`WAPUTAG-1:0]  tag_us_d;

	 // The interface from the APU's perspective.
	 modport apu (
		            input  valid_ds_s, arga_ds_d, argb_ds_d, op_ds_d, flags_ds_d, tag_ds_d, ack_us_s,
		            output ready_ds_s, req_us_s, result_us_d, flags_us_d, tag_us_d
	              );

	 // The interface from interconnect's perspective.
	 modport marx (
		             output valid_ds_s, arga_ds_d, argb_ds_d, op_ds_d, flags_ds_d, tag_ds_d, ack_us_s,
		             input  ready_ds_s, req_us_s, result_us_d, flags_us_d, tag_us_d
	               );

endinterface // marx_apu_if

// Interface between arbiter and fp-interconnect
interface marx_arbiter_if #(
		                        parameter NIN = -1, // number of request inputs
		                        parameter NOUT = -1, // number of allocatable resources
		                        parameter NIN2 = $clog2(NIN)
	                          );

	 // Allocation request handshake.
	 logic [NIN-1:0]      req_d;
	 logic [NIN-1:0]      ack_d;

	 // Index of the resource allocated.
	 logic                unsigned [NOUT-1:0] [NIN2-1:0] assid_d;

	 // Resource handshake.
	 logic [NOUT-1:0]     avail_d; // resource is ready to be allocated
	 logic [NOUT-1:0]     alloc_d; // resource was allocated

	 modport arbiter (
		                input  req_d, avail_d,
		                output ack_d, assid_d, alloc_d
	                  );

	 modport marx (
		             output req_d, avail_d,
		             input  ack_d, assid_d, alloc_d
	               );

endinterface // marx_arbiter_if

/// The interface between the Marx interconnect and the cores. The interconnect
/// shall instantiate the "marx" modport.
interface cpu_marx_if;

	 // Downstream
	 logic                req_ds_s;
	 logic                ack_ds_s;

	 logic [`WARG-1:0]    arga_ds_d;
	 logic [`WARG-1:0]    argb_ds_d;
	 logic [`WOP-1:0]     op_ds_d;
	 logic [`NDSFLAGS-1:0] flags_ds_d;
	 logic [`WCPUTAG-1:0]  tag_ds_d;

	 // Upstream
	 logic                 valid_us_s;
	 logic                 ready_us_s;

	 logic [`WRESULT-1:0]  result_us_d;
	 logic [`NUSFLAGS-1:0] flags_us_d;
	 logic [`WCPUTAG-1:0]  tag_us_d;

	 // The interface from the Core's perspective.
	 modport cpu (
		            output req_ds_s, arga_ds_d, argb_ds_d, op_ds_d, flags_ds_d, ready_us_s, tag_ds_d,
		            input  ack_ds_s, valid_us_s, result_us_d, flags_us_d, tag_us_d
	              );

	 // The interface from the interconnect's perspective.
	 modport marx (
		             input  req_ds_s, arga_ds_d, argb_ds_d, op_ds_d, ready_us_s, tag_ds_d, flags_ds_d,
		             output ack_ds_s, valid_us_s, result_us_d, flags_us_d, tag_us_d
	               );

endinterface
 `endif
`endif

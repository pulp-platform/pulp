// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module jtag_tap_top
(
    input  logic              tck_i,
    input  logic              trst_ni,
    input  logic              tms_i,
    input  logic              td_i,
    output logic              td_o,

    input  logic              test_clk_i,
    input  logic              test_rstn_i,

    input  logic        [7:0] soc_jtag_reg_i,
    output logic        [7:0] soc_jtag_reg_o,
    output logic              sel_fll_clk_o,

   // tap
   output logic               jtag_shift_dr_o,
   output logic               jtag_update_dr_o,
   output logic               jtag_capture_dr_o,
   output logic               axireg_sel_o,

   output logic               dbg_axi_scan_in_o,
   input  logic               dbg_axi_scan_out_i
);

    logic                       s_scan_i;
    logic [8:0]                 s_confreg;
    logic                       confscan;
    logic                       confreg_sel;
    logic                       td_o_int;

    logic [7:0] r_soc_reg0;
    logic [7:0] r_soc_reg1;

    logic [7:0] s_soc_jtag_reg_sync;



    // jtag tap controller
    tap_top tap_top_i
    (
        .tms_i             ( tms_i              ),
        .tck_i             ( tck_i              ),
        .rst_ni            ( trst_ni            ),
        .td_i              ( td_i               ),
        .td_o              ( td_o               ),

        .shift_dr_o        ( jtag_shift_dr_o    ),
        .update_dr_o       ( jtag_update_dr_o   ),
        .capture_dr_o      ( jtag_capture_dr_o  ),

        .memory_sel_o      ( axireg_sel_o       ),
        .fifo_sel_o        (                    ),
        .confreg_sel_o     ( confreg_sel        ),

        .scan_in_o         ( s_scan_i           ),

        .memory_out_i      ( dbg_axi_scan_out_i ),
        .fifo_out_i        ( 1'b0               ),
        .confreg_out_i     ( confscan           )
    );

    // pulp configuration register
    jtagreg
    #(
        .JTAGREGSIZE(9),
        .SYNC(0)
    )
    confreg
    (
        .clk_i                  ( tck_i               ),
        .rst_ni                 ( trst_ni             ),
        .enable_i               ( confreg_sel         ),
        .capture_dr_i           ( jtag_capture_dr_o   ),
        .shift_dr_i             ( jtag_shift_dr_o     ),
        .update_dr_i            ( jtag_update_dr_o    ),
        .jtagreg_in_i           ( {1'b0, s_soc_jtag_reg_sync} ), //at sys rst enable the fll
        .mode_i                 ( 1'b1                ),
        .scan_in_i              ( s_scan_i            ),
        .jtagreg_out_o          ( s_confreg           ),
        .scan_out_o             ( confscan            )
    );

    always_ff @(posedge tck_i or negedge trst_ni) begin
      if(~trst_ni) begin
        r_soc_reg0 <= 0;
        r_soc_reg1 <= 0;
      end else begin
        r_soc_reg1 <= soc_jtag_reg_i;
        r_soc_reg0 <= r_soc_reg1;
      end
    end

   assign s_soc_jtag_reg_sync =r_soc_reg0;

   assign dbg_axi_scan_in_o           =  s_scan_i;

   assign soc_jtag_reg_o              =  s_confreg[7:0];

   assign sel_fll_clk_o               =  s_confreg[8];

endmodule

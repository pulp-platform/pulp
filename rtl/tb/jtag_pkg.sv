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
 * jtag_pkg.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 */

package jtag_pkg;

   parameter int unsigned JTAG_SOC_INSTR_WIDTH       = 4;
   parameter logic [3:0]  JTAG_SOC_IDCODE            = 4'b0010;
   parameter logic [3:0]  JTAG_SOC_AXIREG            = 4'b0100;
   parameter logic [3:0]  JTAG_SOC_BBMUXREG          = 4'b0101;
   parameter logic [3:0]  JTAG_SOC_CLKGATEREG        = 4'b0110;
   parameter logic [3:0]  JTAG_SOC_CONFREG           = 4'b0111;
   parameter logic [3:0]  JTAG_SOC_TESTMODEREG       = 4'b1000;
   parameter logic [3:0]  JTAG_SOC_BISTREG           = 4'b1001;
   parameter logic [3:0]  JTAG_SOC_BYPASS            = 4'b1111;
   parameter int unsigned JTAG_SOC_IDCODE_WIDTH      = 32;
   parameter int unsigned JTAG_SOC_AXIREG_WIDTH      = 96;
   parameter int unsigned JTAG_SOC_BBMUXREG_WIDTH    = 21;
   parameter int unsigned JTAG_SOC_CLKGATEREG_WIDTH  = 11;
   parameter int unsigned JTAG_SOC_CONFREG_WIDTH     = 16;
   parameter int unsigned JTAG_SOC_TESTMODEREG_WIDTH =  4;
   parameter int unsigned JTAG_SOC_BISTREG_WIDTH     = 20;

   parameter int unsigned JTAG_CLUSTER_INSTR_WIDTH    = 4;
   parameter logic [3:0]  JTAG_CLUSTER_IDCODE         = 4'b0010;
   parameter logic [3:0]  JTAG_CLUSTER_SAMPLE_PRELOAD = 4'b0001;
   parameter logic [3:0]  JTAG_CLUSTER_EXTEST         = 4'b0000;
   parameter logic [3:0]  JTAG_CLUSTER_DEBUG          = 4'b1000;
   parameter logic [3:0]  JTAG_CLUSTER_MBIST          = 4'b1001;
   parameter logic [3:0]  JTAG_CLUSTER_BYPASS         = 4'b1111;
   parameter int unsigned JTAG_CLUSTER_IDCODE_WIDTH   = 32;

   parameter int unsigned JTAG_IDCODE_WIDTH = JTAG_CLUSTER_IDCODE_WIDTH+JTAG_SOC_IDCODE_WIDTH;
   parameter int unsigned JTAG_INSTR_WIDTH  = JTAG_CLUSTER_INSTR_WIDTH+JTAG_SOC_INSTR_WIDTH;

   task automatic jtag_wait_halfperiod(input int cycles);
      #(50000*cycles);
   endtask

   task automatic jtag_clock(
      input int cycles,
      ref logic s_tck
   );
      for(int i=0; i<cycles; i=i+1) begin
         s_tck = 1'b0;
         jtag_wait_halfperiod(1);
         s_tck = 1'b1;
         jtag_wait_halfperiod(1);
         s_tck = 1'b0;
      end
   endtask

   task automatic jtag_reset(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi
   );
      s_tms   = 1'b0;
      s_tck   = 1'b0;
      s_trstn = 1'b0;
      s_tdi   = 1'b0;
      jtag_wait_halfperiod(2);
      s_trstn = 1'b1;
   endtask

   task automatic jtag_softreset(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi
   );
      s_tms   = 1'b1;
      s_trstn = 1'b1;
      s_tdi   = 1'b0;
      jtag_clock(5, s_tck); //enter RST
      s_tms   = 1'b0;
      jtag_clock(1, s_tck); // back to IDLE

   endtask

   class JTAG_reg #(int unsigned size = 32, logic [(JTAG_CLUSTER_INSTR_WIDTH+JTAG_SOC_INSTR_WIDTH)-1:0] instr = 'h0);

      task idle(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         // from SHIFT_DR to RUN_TEST : tms sequence 10
         s_tms   = 1'b1;
         s_tdi   = 1'b0;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
      endtask

      task update_and_goto_shift(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         // from SHIFT_DR to RUN_TEST : tms sequence 110
         s_tms   = 1'b1;
         s_tdi   = 1'b0;
         jtag_clock(1, s_tck);
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         jtag_clock(1, s_tck);
      endtask

      task jtag_goto_SHIFT_IR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tdi   = 1'b0;
         // from IDLE to SHIFT_IR : tms sequence 1100
         s_tms   = 1'b1;
         jtag_clock(2, s_tck);
         s_tms   = 1'b0;
         jtag_clock(2, s_tck);
      endtask

      task jtag_goto_SHIFT_DR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tdi   = 1'b0;
         // from IDLE to SHIFT_IR : tms sequence 100
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(2, s_tck);
      endtask

      task jtag_shift_SHIFT_IR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<(JTAG_CLUSTER_INSTR_WIDTH+JTAG_SOC_INSTR_WIDTH); i=i+1) begin
            if (i==(JTAG_CLUSTER_INSTR_WIDTH+JTAG_SOC_INSTR_WIDTH-1))
                 s_tms = 1'b1;
            s_tdi = instr[i];
            jtag_clock(1, s_tck);
         end
      endtask

      task jtag_shift_NBITS_SHIFT_DR (
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<numbits; i=i+1) begin
            if (i == (numbits-1))
               s_tms = 1'b1;
            s_tdi = datain[i];
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end
      endtask

      task shift_nbits_noex(
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<numbits; i=i+1) begin
            s_tdi = datain[i];
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end
      endtask

      task start_shift(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         this.jtag_goto_SHIFT_DR(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task shift_nbits(
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
           this.jtag_shift_NBITS_SHIFT_DR(numbits, datain, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      endtask

      task setIR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         this.jtag_goto_SHIFT_IR(s_tck, s_tms, s_trstn, s_tdi);
         this.jtag_shift_SHIFT_IR(s_tck, s_tms, s_trstn, s_tdi);
         this.idle(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task shift(
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         this.jtag_goto_SHIFT_DR(s_tck, s_tms, s_trstn, s_tdi);
         this.jtag_shift_NBITS_SHIFT_DR(size, datain, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.idle(s_tck, s_tms, s_trstn, s_tdi);
      endtask

   endclass

   task automatic jtag_get_idcode(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic JTAG_reg #(.size(JTAG_IDCODE_WIDTH), .instr({JTAG_SOC_IDCODE,JTAG_CLUSTER_IDCODE})) jtag_idcode = new;
      logic [63:0] s_idcode;
      jtag_idcode.setIR(s_tck, s_tms, s_trstn, s_tdi);
      jtag_idcode.shift('0, s_idcode, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      $display("JTAG: Tap0 ID: %h Tap1 ID: %h",s_idcode[63:32],s_idcode[31:0]);
   endtask

   task automatic jtag_bypass_test(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic JTAG_reg #(.size(258), .instr({JTAG_SOC_BYPASS,JTAG_CLUSTER_BYPASS})) jtag_bypass = new;
                logic [257:0] result_data;
      automatic logic [257:0] test_data = {2'b0,32'hDEADBEEF, 32'h0BADF00D, 32'h01234567, 32'h89ABCDEF,
                                                32'hAAAABBBB, 32'hCCCCDDDD, 32'hEEEEFFFF, 32'h00001111};
      jtag_bypass.setIR(s_tck, s_tms, s_trstn, s_tdi);
      jtag_bypass.shift(test_data, result_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      if (test_data[255:0] == result_data[257:2])
         $display("JTAG: Bypass Test Passed");
      else
      begin
         $display("JTAG: Bypass Test Failed");
         $display("JTAG:   LSB WORD TEST = %h",test_data[31:0]);
         $display("JTAG:   LSB WORD RES  = %h",result_data[33:2]);
      end
   endtask

   class test_mode_if_t;

      task init(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         JTAG_reg #(.size(256), .instr({JTAG_SOC_CONFREG, JTAG_CLUSTER_BYPASS})) jtag_soc_dbg = new;
         jtag_soc_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);
         $display("[test_mode_if] %t - Init", $realtime);
      endtask

      task set_confreg(
         input logic [21:0] confreg,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         JTAG_reg #(.size(256), .instr({JTAG_SOC_CONFREG, JTAG_CLUSTER_BYPASS})) jtag_soc_dbg = new;
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(22, confreg, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[test_mode_if] %t - Setting confreg to value %X.", $realtime, confreg);
      endtask

   endclass

endpackage

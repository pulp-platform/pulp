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
 * dbg_pkg.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 */

package dbg_pkg;

   parameter logic [7:0] DBG_MODULE     = 6'b100000;
   parameter logic [7:0] DBG_CPU_MODULE = 6'b100001;

   parameter logic [6:0] DBG_NOP     = 5'h0;
   parameter logic [6:0] DBG_WRITE8  = 5'h1;
   parameter logic [6:0] DBG_WRITE16 = 5'h2;
   parameter logic [6:0] DBG_WRITE32 = 5'h3;
   parameter logic [6:0] DBG_WRITE64 = 5'h4;
   parameter logic [6:0] DBG_READ8   = 5'h5;
   parameter logic [6:0] DBG_READ16  = 5'h6;
   parameter logic [6:0] DBG_READ32  = 5'h7;
   parameter logic [6:0] DBG_READ64  = 5'h8;
   parameter logic [6:0] DBG_WREG    = 5'h9;
   parameter logic [6:0] DBG_SELREG  = 5'hD;

   parameter logic [6:0] DBG_CPU_NOP    = 5'h0;
   parameter logic [6:0] DBG_CPU_WRITE  = 5'h3;
   parameter logic [6:0] DBG_CPU_READ   = 5'h7;
   parameter logic [6:0] DBG_CPU_WREG   = 5'h9;
   parameter logic [6:0] DBG_CPU_SELREG = 5'hD;

   parameter logic [3:0] DBG_CPU_REG_STATUS = 3'b000;

   class dbg_if_cluster_t;

      jtag_pkg::JTAG_reg #(.size(256), .instr({jtag_pkg::JTAG_SOC_BYPASS, jtag_pkg::JTAG_CLUSTER_DEBUG})) jtag_cluster_dbg;

      task init(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         jtag_cluster_dbg = new;
         jtag_cluster_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task nop(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         // TO BE CHECKED
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
   //      jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_NOP, 32'b0, 0}, dataout, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] NOP command.");
      endtask

      task write8(
         input logic[31:0]        addr,
         input int                nwords,
         input logic [255:0][7:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_WRITE8, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits_noex(9, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_cluster_dbg.shift_nbits_noex(8, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] WRITE8 burst @%h for %d bytes.", addr, nwords);
      endtask

      task write16(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][15:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_WRITE16, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits_noex(17, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_cluster_dbg.shift_nbits_noex(16, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] WRITE16 burst @%h for %d bytes.", addr, nwords*2);
      endtask

      task write32(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_WRITE32, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits_noex(33, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_cluster_dbg.shift_nbits_noex(32, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] WRITE32 burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task write64(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][63:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_WRITE64, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits_noex(65, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_cluster_dbg.shift_nbits_noex(64, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] WRITE64 burst @%h for %d bytes.", addr, nwords*8);
      endtask

      task read8(
         input  logic[31:0]        addr,
         input  int                nwords,
         output logic [255:0][7:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_READ8, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_cluster_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_cluster_dbg.shift_nbits_noex(8, 8'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[7:0];
         for(int i=1; i<nwords; i++) begin
            jtag_cluster_dbg.shift_nbits_noex(8, 8'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[7:0];
         end
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] READ8 burst @%h for %d bytes.", addr, nwords);
      endtask

      task read16(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][15:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_READ16, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_cluster_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_cluster_dbg.shift_nbits_noex(16, 16'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[15:0];
         for(int i=1; i<nwords; i++) begin
            jtag_cluster_dbg.shift_nbits_noex(16, 16'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[15:0];
         end
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] READ16 burst @%h for %d bytes.", addr, nwords*2);
      endtask

      task read32(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_READ32, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_cluster_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_cluster_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[31:0];
         for(int i=1; i<nwords; i++) begin
            jtag_cluster_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[31:0];
         end
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         //$display("[dbg_if] READ32 burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task read64(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][63:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(54,{1'b0, DBG_READ64, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_cluster_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_cluster_dbg.shift_nbits_noex(64, 64'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[63:0];
         for(int i=1; i<nwords; i++) begin
            jtag_cluster_dbg.shift_nbits_noex(64, 64'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[63:0];
         end
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         //$display("[dbg_if] READ64 burst @%h for %d bytes.", addr, nwords*8);
      endtask

      task cpu_write(
         input logic [3:0]         cpu_id,
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_CPU_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(58,{1'b0, DBG_CPU_WRITE, cpu_id, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits_noex(33, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_cluster_dbg.shift_nbits_noex(32, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] CPU WRITE burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task cpu_read(
         input  logic [3:0]         cpu_id,
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_CPU_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(58,{1'b0, DBG_CPU_READ, cpu_id, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the OR1K module
         begin
           jtag_cluster_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_cluster_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[31:0];
         for(int i=1; i<nwords; i++) begin
            jtag_cluster_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[31:0];
         end
         jtag_cluster_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore C, s_tdoRC
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] CPU READ burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task cpu_wait_for_stall(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         while(1)
         begin
           jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
           jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_CPU_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
           jtag_cluster_dbg.shift_nbits(9,{1'b0, DBG_CPU_NOP, DBG_CPU_REG_STATUS, 2'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);

           if(dataout[0] == 1'b1) break;
         end
      endtask

      task cpu_stall(
         input logic [3:0] cpu_mask,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_CPU_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(13,{1'b0, 1'b0, DBG_CPU_WREG, DBG_CPU_REG_STATUS, cpu_mask}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] CPU STALL command.");
      endtask

      task cpu_reset(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_cluster_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(7, {1'b0, DBG_CPU_MODULE}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_cluster_dbg.shift_nbits(13,{1'b0, 1'b0, DBG_CPU_WREG, DBG_CPU_REG_STATUS, 4'b0000}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_cluster_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if] CPU RESET command.");
      endtask

   endclass

   class dbg_if_soc_t;

      jtag_pkg::JTAG_reg #(.size(256), .instr({jtag_pkg::JTAG_SOC_AXIREG, jtag_pkg::JTAG_SOC_BYPASS})) jtag_soc_dbg;
      logic s_tdo;

      task init(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         jtag_soc_dbg = new;
         jtag_soc_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task nop(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] NOP command.");
      endtask

      task write8(
         input logic[31:0]        addr,
         input int                nwords,
         input logic [255:0][7:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_WRITE8, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits_noex(9, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_soc_dbg.shift_nbits_noex(8, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] WRITE8 burst @%h for %d bytes.", addr, nwords);
      endtask

      task write16(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][15:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_WRITE16, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits_noex(17, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_soc_dbg.shift_nbits_noex(16, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] WRITE16 burst @%h for %d bytes.", addr, nwords*2);
      endtask

      task write32(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_WRITE32, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits_noex(33, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_soc_dbg.shift_nbits_noex(32, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] WRITE32 burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task write64(
         input logic[31:0]         addr,
         input int                 nwords,
         input logic [255:0][63:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_WRITE64, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits_noex(65, {data[0], 1'b1}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         for(int i=1; i<nwords; i++)
            jtag_soc_dbg.shift_nbits_noex(64, data[i], dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'h11111111}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] WRITE64 burst @%h for %d bytes.", addr, nwords*8);
      endtask

      task read8(
         input  logic[31:0]        addr,
         input  int                nwords,
         output logic [255:0][7:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_READ8, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_soc_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_soc_dbg.shift_nbits_noex(8, 8'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[7:0];
         for(int i=1; i<nwords; i++) begin
            jtag_soc_dbg.shift_nbits_noex(8, 8'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[7:0];
         end
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] READ8 burst @%h for %d bytes.", addr, nwords);
      endtask

      task read16(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][15:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_READ16, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_soc_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_soc_dbg.shift_nbits_noex(16, 16'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[15:0];
         for(int i=1; i<nwords; i++) begin
            jtag_soc_dbg.shift_nbits_noex(16, 16'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[15:0];
         end
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] READ16 burst @%h for %d bytes.", addr, nwords*2);
      endtask

      task read32(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][31:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_READ32, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_soc_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_soc_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[31:0];
         for(int i=1; i<nwords; i++) begin
            jtag_soc_dbg.shift_nbits_noex(32, 32'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[31:0];
         end
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         // $display("[dbg_if_soc] READ32 burst @%h for %d bytes.", addr, nwords*4);
      endtask

      task read64(
         input  logic[31:0]         addr,
         input  int                 nwords,
         output logic [255:0][63:0] data,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [255:0] dataout;
         jtag_soc_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(6, DBG_MODULE, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         jtag_soc_dbg.shift_nbits(53,{DBG_READ64, addr, nwords[15:0]}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         jtag_soc_dbg.update_and_goto_shift(s_tck, s_tms, s_trstn, s_tdi);
         while(1) // wait for a '1' from the AXI module
         begin
           jtag_soc_dbg.shift_nbits_noex(1, {1'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
           if(dataout[0] == 1'b1) break;
         end
         jtag_soc_dbg.shift_nbits_noex(64, 64'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         data[0] = dataout[63:0];
         for(int i=1; i<nwords; i++) begin
            jtag_soc_dbg.shift_nbits_noex(64, 64'b0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            data[i] = dataout[63:0];
         end
         jtag_soc_dbg.shift_nbits(34, {2'b0, 32'b0}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo); // for now we completely ignore CRC
         jtag_soc_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         $display("[dbg_if_soc] READ64 burst @%h for %d bytes.", addr, nwords*8);
      endtask

   endclass

   task automatic cpu_read_gpr(
      input  logic [3:0]  cpu_id,
      input  logic [4:0]  addr,
      output logic [31:0] data,
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic dbg_if_cluster_t dbg_if = new;
      logic [255:0][31:0] tmp;
      dbg_if.cpu_read(cpu_id, {16'b0, 6'b1, 5'b0, addr}, 1, tmp, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      data = tmp[0];
   endtask

   task automatic cpu_write_gpr(
      input logic [3:0]  cpu_id,
      input logic [4:0]  addr,
      input logic [31:0] data,
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic dbg_if_cluster_t dbg_if = new;
     logic [255:0][31:0] tmp;
     tmp[0] = data;
     dbg_if.cpu_write(cpu_id, {16'b0, 6'b1, 5'b0, addr}, 1, tmp, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
   endtask

   task automatic jtag_load_L2(
      input int          num_stim,
      ref   logic [95:0] stimuli [100000:0],
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic logic [511:0][31:0] jtag_data;
      automatic logic [31:0]        jtag_addr;
      automatic integer             jtag_burst_len;
      automatic logic [31:0] spi_addr;
      automatic logic [31:0] spi_addr_old;
      automatic logic        more_stim = 1;
      automatic dbg_if_soc_t dbg_if_soc = new;
      spi_addr        = stimuli[num_stim][95:64]; // assign address
      jtag_data[0]    = stimuli[num_stim][63:0];  // assign data

      $display("[JTAG] Loading L2 with jtag interface");
      dbg_if_soc.init(s_tck, s_tms, s_trstn, s_tdi);

      spi_addr_old = spi_addr - 32'h8;

      while (more_stim) begin // loop until we have no more stimuli

         jtag_burst_len = 0;
         jtag_addr = stimuli[num_stim][95:64];
         for (int i=0;i<256;i=i+2) begin
            spi_addr       = stimuli[num_stim][95:64]; // assign address
            jtag_data[i]   = stimuli[num_stim][31:0];  // assign data
            jtag_data[i+1] = stimuli[num_stim][63:32]; // assign data

            if (spi_addr != (spi_addr_old + 32'h8))
               begin
                  spi_addr_old = spi_addr - 32'h8;
                  break;
               end
            else begin
               jtag_burst_len = i + 2;
               num_stim = num_stim + 1;
            end
            if (num_stim > $size(stimuli) || stimuli[num_stim]===96'bx ) begin // make sure we have more stimuli
               more_stim = 0;                    // if not set variable to 0, will prevent additional stimuli to be applied
               break;
            end
            spi_addr_old = spi_addr;
         end
         dbg_if_soc.write32(jtag_addr, jtag_burst_len, jtag_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      end

   endtask : jtag_load_L2

endpackage

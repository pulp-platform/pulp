// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Robert Balas (balasr@iis.ee.ethz.ch)

// Minimal manual test of srec_pkg.sv
// test: qverilog srec_pkg.sv srec.sv

module srec();
  import srec_pkg::*;

  initial begin
    automatic srec_record_t records[$];
    automatic logic [95:0] stimuli[$];
    automatic logic [31:0] entrypoint;
    srec_read("min.srec", records);

    $display("");
    $display("QUEUE OUTPUT");
    for(int i = 0 ; i < records.size; i++) begin
      $display("addr=%x", records[i].addr);
      $display("length=%d", records[i].length);
      $write("data bytes= ");
      for (int j = 0; j < records[i].length; j++)
        $write("%x", records[i].mem[j]);
      $write("\n");
    end
    srec_records_to_stimuli(records, stimuli, entrypoint);
  end

endmodule // srec

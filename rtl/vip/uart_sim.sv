// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author:
//  * Antonio Pullini <pullinia@iis.ee.ethz.ch>
//  * Igor Loi <igor.loi@unibo.it>
//  * Florian Zaruba <zarubaf@iis.ee.ethz.cht>
//  * Robert Balas <balasr@iis.ee.ethz.cht>
//
// Date: Unknown
// Description: This module takes data over UART and prints them to the console
//              A string is printed to the console as soon as a '\n' character is found

module uart_sim #(
    parameter int unsigned BAUD_RATE = 115200,
    parameter int unsigned PARITY_EN = 0
)(
    input  logic rx,
    output logic tx,
    input  logic rx_en
);

/* pragma translate_off */
`ifndef VERILATOR
  localparam time BIT_PERIOD = (1000000000 / BAUD_RATE) * 1ns;

  bit               newline;
  logic [7:0]       character;
  logic [256*8-1:0] stringa;
  logic             parity;
  integer           charnum;
  integer           file;

  initial begin
    // uart should idle with 1'b1, since that means no transmission
    tx      = 1'b1;
    newline = 1;
`ifdef LOG_UART_SIM
    file = $fopen("uart.log", "w");
`endif
  end

  always begin
    if (rx_en) begin
      @(negedge rx);
      #(BIT_PERIOD/2);
      for (int i = 0; i <= 7; i++) begin
        #BIT_PERIOD character[i] = rx;
      end

      if (PARITY_EN == 1) begin
        // check parity
        #BIT_PERIOD parity = rx;

        for (int i=7;i>=0;i--) begin
          parity = character[i] ^ parity;
        end

        if (parity == 1'b1) begin
          $display("Parity error detected");
        end
      end

      // STOP BIT
      #BIT_PERIOD;

`ifdef LOG_UART_SIM
      $fwrite(file, "%c", character);
`endif
      $fflush();

      if (character == 8'h0A) begin
        $write("\n");
        newline = 1;
      end else begin
        if (newline) begin
          $write("[UART]: ");
          newline = 0;
        end
        $write("%c", character);
      end

    end else begin
      charnum = 0;
      stringa = "";
      #10;
    end
  end

  task send_char(input logic [7:0] c);
    int i;

    // start bit
    tx = 1'b0;

    for (i = 0; i < 8; i++) begin
      #(BIT_PERIOD);
      tx = c[i];
    end

    // stop bit
    #(BIT_PERIOD);
    tx = 1'b1;
    #(BIT_PERIOD);
  endtask
`endif

  task wait_symbol();
    #(BIT_PERIOD * 10);
  endtask // wait_symbol

/* pragma translate_on */
endmodule

/* 
 * uart_tb_rx.sv
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 *
 * Copyright (C) 2013-2018 ETH Zurich, University of Bologna.
 *
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 */

// This module takes data over UART and prints them to the console
// A string is printed to the console as soon as a '\n' character is found
module uart_tb_rx
  #(
    parameter BAUD_RATE = 115200,
    parameter PARITY_EN = 0
    )
  (
    input  logic rx,
    input  logic rx_en,
    output logic word_done
  );
  timeunit      1ns;
  // bit_period is in ns
  localparam NS_UNIT_SCALER = 1000000000;
  real BIT_PERIOD = (NS_UNIT_SCALER/BAUD_RATE);

  logic [7:0]       character;
  logic [256*8-1:0] stringa;
  logic             parity;
  integer           charnum;
  integer           file;

  initial
  begin
    file = $fopen("stdout/uart", "w");
  end

  always
  begin
    if (rx_en)
    begin
      @(negedge rx);
      #(BIT_PERIOD/2) ;
      for (int i=0;i<=7;i++)
      begin
        #BIT_PERIOD character[i] = rx;
      end

      if(PARITY_EN == 1)
      begin
        // check parity
        #BIT_PERIOD parity = rx;

        for (int i=7;i>=0;i--)
        begin
          parity = character[i] ^ parity;
        end

        if(parity == 1'b1)
        begin
          $display("Parity error detected");
        end
      end

      // STOP BIT
      #BIT_PERIOD;

      $fwrite(file, "%c", character);
      stringa[(255-charnum)*8 +: 8] = character;
      if (character == 8'h0A || charnum == 254) // line feed or max. chars reached
      begin
        if (character == 8'h0A)
          stringa[(255-charnum)*8 +: 8] = 8'h0; // null terminate string, replace line feed
        else
          stringa[(255-charnum-1)*8 +: 8] = 8'h0; // null terminate string

        $write("RX string: %s\n",stringa);
        charnum = 0;
        stringa = "";
        word_done = 1;
        #100 word_done = 0;
      end
      else
      begin
        charnum = charnum + 1;
      end
    end
    else
    begin
      charnum = 0;
      stringa = "";
      word_done = 0;
      #10;
    end
  end
endmodule


module pulpemu_ref_clk_div
  #(
    parameter DIVISOR = 256
    )
   (
    input logic  clk_i,
    input logic  rstn_i,
    output logic ref_clk_o
    );

   logic [($clog2(DIVISOR) - 1):0]   counter;

   always_ff @(posedge clk_i, negedge rstn_i)
     begin
        if(!rstn_i)
          begin
             counter <= '0;
          end
        else
          begin
             if(counter >= (DIVISOR-1))
               counter <= '0;
             else
               counter <= counter + 1;
          end // else: !if(!rstn_i)
     end

   // The frequency of the output clk_out
   //  = The frequency of the input clk_in divided by DIVISOR
   // For example: clk_i = 8.388608 Mhz, if you want to get 32768 Hz signal to be reference clock
   // You will modify the DIVISOR parameter value to 256
   // Then the frequency of the output clk_out = 8.388608 Mhz/ 256 = 32768 Hz

   assign ref_clk_o = (counter < DIVISOR / 2 ) ? 1'b0 : 1'b1;

endmodule

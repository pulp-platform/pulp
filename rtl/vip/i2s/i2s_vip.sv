/* 
 * i2s_vip.sv
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
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

module i2s_vip 
#(
	parameter I2S_CHAN = 4'h1,
	parameter FILENAME = "i2s_buffer.hex"
) 
(

   input   logic        A0,                             // chip select bit
   input   logic        A1,                             // chip select bit
   inout   wire         SDA,                            // serial data I/O
   input   wire         SCL,                            // serial data clock
   input   logic        sck_i,
   input   logic        ws_i,
   output  logic        data_o,
   output   logic        sck_o,
   output   logic        ws_o
);


// Signals from I2C to I2S VIP channel
logic 		s_i2s_rst;
logic       s_pdm_ddr;
logic       s_pdm_en;
logic       s_lsb_first;
logic       s_i2s_mode;
logic       s_i2s_enable;
logic [1:0] s_transf_size;
logic       s_i2s_snap_enable;
     


i2s_vip_channel 
#(
	.I2S_CHAN(I2S_CHAN),
	.FILENAME(FILENAME)
) 
i2s_vip_channel_i
(
	//IF to I2C
    .rst         ( s_i2s_rst    ),
	.pdm_ddr_i   ( s_pdm_ddr    ),
	.pdm_en_i    ( s_pdm_en     ),
	.lsb_first_i ( s_lsb_first  ),
    .mode_i      ( s_i2s_mode   ),
    .enable_i    ( s_i2s_enable ),
    .transf_size_i( s_transf_size),	
    .i2s_snap_enable_i(s_i2s_snap_enable), // input 
	// IF to PULP
    .sck_i     ( sck_i        ),
    .ws_i      ( ws_i         ),
    .data_o    ( data_o       ),
    .sck_o     ( sck_o        ),
    .ws_o      ( ws_o         )
);

i2c_if i2c_if_i 
(
	.A0         ( A0           ),
	.A1         ( A1           ),
	.A2         ( 1'b1         ),
	.WP         ( 1'b0         ),
	.SDA        ( SDA          ),
	.SCL        ( SCL          ),
	.RESET      ( 1'b0         ),
	
	.pdm_ddr    ( s_pdm_ddr    ),
	.pdm_en     ( s_pdm_en     ),
	.lsb_first  ( s_lsb_first  ),
	.i2s_rst    ( s_i2s_rst    ),
    .i2s_mode   ( s_i2s_mode   ),
    .i2s_enable ( s_i2s_enable ),
    .transf_size (s_transf_size ),
    .i2s_snap_enable(s_i2s_snap_enable) // output 
);

endmodule 

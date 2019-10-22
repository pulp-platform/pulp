// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module rtc_date(
	input  logic clk_i,
	input  logic rstn_i,

	input  logic        date_update_i,
	input  logic [31:0] date_i,
	output logic [31:0] date_o,

	input logic new_day_i
);
	logic	[5:0]	s_day;
	logic	[4:0]	s_month;
	logic	[13:0]	s_year;
	logic   [5:0]   r_day;
	logic   [4:0]   r_month;
	logic   [13:0]  r_year;

	logic s_end_of_month;
	logic s_end_of_year;
	logic s_year_century;
	logic s_year_400;
	logic s_year_leap;
	logic s_year_div_4;

	assign s_day  = date_i[5:0];
	assign s_month  = date_i[12:8];
	assign s_year = date_i[29:16];

	assign date_o = {2'b00,r_year,3'b000,r_month,2'b00,r_day};

	assign s_end_of_year = s_end_of_month & (r_month == 5'h12);

	always_comb
	begin
		case(r_month)
		5'h01: s_end_of_month = (r_day == 6'h31); // Jan
		5'h02: s_end_of_month = (r_day == 6'h29) || ((~s_year_leap)&&(r_day == 6'h28));
		5'h03: s_end_of_month = (r_day == 6'h31); // March
		5'h04: s_end_of_month = (r_day == 6'h30); // April
		5'h05: s_end_of_month = (r_day == 6'h31); // May
		5'h06: s_end_of_month = (r_day == 6'h30); // June
		5'h07: s_end_of_month = (r_day == 6'h31); // July
		5'h08: s_end_of_month = (r_day == 6'h31); // August
		5'h09: s_end_of_month = (r_day == 6'h30); // Sept
		5'h10: s_end_of_month = (r_day == 6'h31); // October
		5'h11: s_end_of_month = (r_day == 6'h30); // November
		5'h12: s_end_of_month = (r_day == 6'h31); // December
		default: s_end_of_month = 1'b0;
		endcase
	end

	assign s_year_div_4   = ((~r_year[0])&&(r_year[4]==r_year[1]));
	assign s_year_century = (r_year[7:0] == 8'h00);
	assign s_year_400     = ((~r_year[8])&&((r_year[12]==r_year[9])));
	assign s_year_leap    = (s_year_div_4) && ( (~s_year_century) || ((s_year_century)&&(s_year_400)) );


	// Adjust the day of month
	always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_day
		if(~rstn_i) begin
			r_day <= 6'h1;
		end else begin
		if (date_update_i)
			r_day <= s_day;
		else if ((new_day_i)&&(s_end_of_month))
			r_day <= 6'h01;
		else if ((new_day_i)&&(r_day[3:0] != 4'h9))
			r_day[3:0] <= r_day[3:0] + 4'h1;
		else if (new_day_i)
		begin
			r_day[3:0] <= 4'h0;
			r_day[5:4] <= r_day[5:4] + 2'h1;
		end

		end
	end

	always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_month
		if(~rstn_i) begin
			r_month <= 5'h01;
		end else begin
			if (date_update_i)
				r_month <= s_month;
			else if ((new_day_i)&&(s_end_of_year))
				r_month <= 5'h01;
			else if ((new_day_i)&&(s_end_of_month)&&(r_month[3:0] != 4'h9))
				r_month[3:0] <= r_month[3:0] + 4'h1;
			else if ((new_day_i)&&(s_end_of_month))
			begin
				r_month[3:0] <= 4'h0;
				r_month[4] <= 1;
			end
		end
	end // proc_r_month

	always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_year
	 	if(~rstn_i) begin
	 		r_year <= 14'h2000;
	 	end else begin
	 		if (date_update_i)
	 			r_year <= s_year;
	 		else if ((new_day_i)&&(s_end_of_year))
			begin
				if (r_year[3:0] != 4'h9)
					r_year[3:0] <= r_year[3:0] + 4'h1;
				else begin
					r_year[3:0] <= 4'h0;
					if (r_year[7:4] != 4'h9)
						r_year[7:4] <= r_year[7:4] + 4'h1;
					else begin
						r_year[7:4] <= 4'h0;
						if (r_year[11:8] != 4'h9)
							r_year[11:8] <= r_year[11:8]+4'h1;
						else begin
							r_year[11:8] <= 4'h0;
							r_year[13:12] <= r_year[13:12]+2'h1;
						end
					end
				end
			end
	 	end
	end

endmodule

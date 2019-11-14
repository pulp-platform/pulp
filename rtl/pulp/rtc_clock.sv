// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module	rtc_clock(
	input  logic        clk_i,
	input  logic        rstn_i,

	input  logic        clock_update_i,
	output logic [21:0] clock_o,
	input  logic [21:0] clock_i,

	input  logic  [9:0] init_sec_cnt_i,

	input  logic        timer_update_i,
	input  logic        timer_enable_i,
	input  logic        timer_retrig_i,
	input  logic [16:0] timer_target_i,
	output logic [16:0] timer_value_o,

	input  logic        alarm_enable_i,
	input  logic        alarm_update_i,
	input  logic [21:0] alarm_clock_i,
	output logic [21:0] alarm_clock_o,

	output logic        event_o,

	output logic        update_day_o
);

	logic [7:0] r_seconds;
	logic [7:0] r_minutes;
	logic [6:0] r_hours;

	logic [7:0] s_seconds;
	logic [7:0] s_minutes;
	logic [6:0] s_hours;

	logic [7:0] r_alarm_seconds;
	logic [7:0] r_alarm_minutes;
	logic [6:0] r_alarm_hours;
	logic       r_alarm_enable;

	logic [7:0] s_alarm_seconds;
	logic [7:0] s_alarm_minutes;
	logic [5:0] s_alarm_hours;

	logic [14:0] r_sec_counter;

	logic s_update_seconds;
	logic s_update_minutes;
	logic s_update_hours;
	logic s_alarm_match;
	logic r_alarm_match;
	logic s_alarm_event;
	logic s_timer_event;

	logic [16:0] r_timer;
	logic [16:0] r_timer_target;
	logic        r_timer_en;
	logic        r_timer_retrig;


	assign s_seconds = clock_i[7:0];
	assign s_minutes = clock_i[15:8];
	assign s_hours   = clock_i[21:16];

	assign s_alarm_seconds = alarm_clock_i[7:0];
	assign s_alarm_minutes = alarm_clock_i[15:8];
	assign s_alarm_hours   = alarm_clock_i[21:16];

	assign s_alarm_match = (r_seconds == s_alarm_seconds) & (r_minutes == s_alarm_minutes) & (r_hours == s_alarm_hours);//alarm condition(high for 1 sec)
	assign s_alarm_event = r_alarm_enable & s_alarm_match & ~r_alarm_match; //edge detect on alarm event

	assign s_timer_match = r_timer == r_timer_target;
	assign s_timer_event = r_timer_en & s_timer_match;

	assign s_update_seconds = r_sec_counter == 15'h7FFF;
	assign s_update_minutes = s_update_seconds & (r_seconds == 8'h59);
	assign s_update_hours   = s_update_minutes & (r_minutes == 8'h59);

	assign event_o        = s_alarm_event | s_timer_event;
	assign update_day_o   = s_update_hours & (r_hours == 6'h23);
	assign clock_o        = {r_hours,r_minutes,r_seconds};
	assign alarm_clock_o = {r_alarm_hours,r_alarm_minutes,r_alarm_seconds};

	assign timer_value_o = r_timer;

    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i)
        begin
            r_alarm_seconds <= 'h0;
            r_alarm_minutes <= 'h0;
            r_alarm_hours   <= 'h0;
            r_alarm_enable  <= 'h0;
        end
        else
        begin
        	if (alarm_update_i)
        	begin
        		r_alarm_enable  <= alarm_enable_i;
            	r_alarm_seconds <= s_alarm_seconds;
            	r_alarm_minutes <= s_alarm_minutes;
            	r_alarm_hours   <= s_alarm_hours  ;
        	end
        	else if(s_alarm_event) //disable alarm when alarm event is generated(sw must retrigger)
        		r_alarm_enable <= 'h0;
        end
    end

    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i)
            r_alarm_match <= 'h0;
        else
       		r_alarm_match <= s_alarm_match;
    end

    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i)
        begin
            r_timer_en     <= 'h0;
            r_timer_target <= 'h0;
            r_timer        <= 'h0;
            r_timer_retrig <= 'h0;
        end
        else
        begin
        	if (timer_update_i)
        	begin
        		r_timer_en     <= timer_enable_i;
            	r_timer_target <= timer_target_i;
            	r_timer_retrig <= timer_retrig_i;
            	r_timer        <= 'h0;
        	end
        	else if(r_timer_en)
        	begin
        		if(s_timer_match)
        		begin
        			if(!r_timer_retrig)
        				r_timer_en <= 0;
        			r_timer    <= 'h0;
        		end
        		else
        			r_timer <= r_timer + 1;
        	end
        end
    end

    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i)
            r_sec_counter <= 'h0;
        else
        begin
        	if (clock_update_i)
        		r_sec_counter <= {init_sec_cnt_i,5'h0};
        	else
            	r_sec_counter <= r_sec_counter + 1;
        end
    end

	always @(posedge clk_i or negedge rstn_i)
	begin
		if(~rstn_i)
		begin
			r_seconds <= 0;
			r_minutes <= 0;
			r_hours   <= 0;
		end
		else
		begin
			if (clock_update_i)
			begin
				r_seconds <= s_seconds;
				r_minutes <= s_minutes;
				r_hours   <= s_hours;
			end
			else
			begin
				if (s_update_seconds)
				begin // advance the seconds
					if (r_seconds[3:0] >= 4'h9)
						r_seconds[3:0] <= 4'h0;
					else
						r_seconds[3:0] <= r_seconds[3:0] + 4'h1;
					if (r_seconds >= 8'h59)
						r_seconds[7:4] <= 4'h0;
					else if (r_seconds[3:0] >= 4'h9)
						r_seconds[7:4] <= r_seconds[7:4] + 4'h1;
				end

				if (s_update_minutes)
				begin // advance the minutes
					if (r_minutes[3:0] >= 4'h9)
						r_minutes[3:0] <= 4'h0;
					else
						r_minutes[3:0] <= r_minutes[3:0] + 4'h1;
					if (r_minutes >= 8'h59)
						r_minutes[7:4] <= 4'h0;
					else if (r_minutes[3:0] >= 4'h9)
						r_minutes[7:4] <= r_minutes[7:4] + 4'h1;
				end

				if (s_update_hours)
				begin // advance the hours
					if (r_hours >= 6'h23)
					begin
						r_hours <= 6'h00;
					end else if (r_hours[3:0] >= 4'h9)
					begin
						r_hours[3:0] <= 4'h0;
						r_hours[5:4] <= r_hours[5:4] + 2'h1;
					end else begin
						r_hours[3:0] <= r_hours[3:0] + 4'h1;
					end
				end
			end
		end
	end


endmodule

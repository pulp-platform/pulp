// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


// NOTE: Safe regs will be mapped starting from BASEADDR+0x100.
//       Have a look in apb_soc_ctrl for details (7th address bit is used
//       to dispatch reg access req between safe_domain_reg_if and
//       apb_soc_ctrl)

// PMU REGISTERS
`define REG_RAR         6'b000000 //BASEADDR+0x100
`define REG_SLEEP_CTRL  6'b000001 //BASEADDR+0x104
`define REG_NOTUSED     6'b000010 //BASEADDR+0x108
`define REG_PGCFG       6'b000011 //BASEADDR+0x10C

// PAD MUXING

`define REG_SLEEPPADCFG0 6'b010100 //BASEADDR+0x150 sets the pad sleep mode for pins  0 (bits [1:0]) to 15 (bits [31:30]) BITS 0 = OUTPUT ENABLE, BITS 1 = OUTPUT DATA
`define REG_SLEEPPADCFG1 6'b010101 //BASEADDR+0x154 sets the pad sleep mode for pins 16 (bits [1:0]) to 31 (bits [31:30]) BITS 0 = OUTPUT ENABLE, BITS 1 = OUTPUT DATA
`define REG_SLEEPPADCFG2 6'b010110 //BASEADDR+0x158 sets the pad sleep mode for pins 32 (bits [1:0]) to 47 (bits [31:30]) BITS 0 = OUTPUT ENABLE, BITS 1 = OUTPUT DATA
`define REG_SLEEPPADCFG3 6'b010111 //BASEADDR+0x15C sets the pad sleep mode for pins 48 (bits [1:0]) to 63 (bits [31:30]) BITS 0 = OUTPUT ENABLE, BITS 1 = OUTPUT DATA
`define REG_PADSLEEP     6'b011000 //BASEADDR+0x160 sets the pad sleep mode on (1= on, 0= off)

`define REG_RTC_CLOCK   6'b110100 //BASEADDR+0x1D0
`define REG_RTC_ALARM   6'b110101 //BASEADDR+0x1D4
`define REG_RTC_TIMER   6'b110110 //BASEADDR+0x1D8
`define REG_RTC_DATE    6'b110111 //BASEADDR+0x1DC


module safe_domain_reg_if
  (
   input  logic             clk_i,
   input  logic             rstn_i,

   output logic      [11:0] cfg_mem_ret_o,
   output logic       [1:0] cfg_fll_ret_o,

   output logic       [4:0] cfg_rar_nv_volt_o,
   output logic       [4:0] cfg_rar_mv_volt_o,
   output logic       [4:0] cfg_rar_lv_volt_o,
   output logic       [4:0] cfg_rar_rv_volt_o,

   output logic       [1:0] cfg_wakeup_o,

   input  logic      [31:0] wake_gpio_i,
   output logic             wake_event_o,

   output logic             boot_l2_o,

   output logic             rtc_event_o,

   output logic             pad_sleep_mode_o,
   output logic [63:0][1:0] pad_sleep_cfg_o,

   input  logic             reg_if_req_i,
   input  logic             reg_if_wrn_i,
   input  logic       [5:0] reg_if_add_i,
   input  logic      [31:0] reg_if_wdata_i,
   output logic             reg_if_ack_o,
   output logic      [31:0] reg_if_rdata_o,

   output logic      [31:0] pmu_sleep_control_o
   );

   logic  [4:0] r_rar_nv_volt;
   logic  [4:0] r_rar_mv_volt;
   logic  [4:0] r_rar_lv_volt;
   logic  [4:0] r_rar_rv_volt;

   logic  [4:0] r_extwake_sel;
   logic 	      r_extwake_en;
   logic  [1:0] r_extwake_type;
   logic 	      r_extevent;
   logic  [2:0] r_extevent_sync;
   logic  [2:0] r_reboot;

   logic        s_extwake_rise;
   logic        s_extwake_fall;
   logic        s_extwake_in;

   logic  [1:0] r_wakeup;
   logic        r_cluster_wake;

   logic [13:0] r_cfg_ret;

   logic    		s_rise;
   logic 		    s_fall;

   logic [63:0] r_sleep_pad_cfg0;
   logic [63:0] r_sleep_pad_cfg1;
   logic        r_pad_sleep;

   logic 		    s_req_sync;

   logic        r_boot_l2;

   logic [31:0] s_pmu_sleep_control;

   logic [21:0] s_rtc_clock;
   logic [21:0] s_rtc_alarm;
   logic [31:0] s_rtc_date;
   logic [16:0] s_rtc_timer;


   pulp_sync_wedge i_sync
     (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .en_i(1'b1),
      .serial_i(reg_if_req_i),
      .r_edge_o(s_rise),
      .f_edge_o(s_fall),
      .serial_o(s_req_sync)
      );

   assign cfg_rar_nv_volt_o           = r_rar_nv_volt;
   assign cfg_rar_mv_volt_o           = r_rar_mv_volt;
   assign cfg_rar_lv_volt_o           = r_rar_lv_volt;
   assign cfg_rar_rv_volt_o           = r_rar_rv_volt;

   assign cfg_mem_ret_o               = r_cfg_ret[11:0];
   assign cfg_fll_ret_o               = r_cfg_ret[13:12];

   assign wake_event_o                = r_extevent;
   assign cfg_wakeup_o                = r_wakeup;

   assign boot_l2_o                   = r_boot_l2;

   always_ff @(posedge clk_i, negedge rstn_i)
     begin
	if(!rstn_i)
	     reg_if_ack_o  <= 1'b0;
	else if (s_rise)
	  	reg_if_ack_o <= 1'b1;
	else if (s_fall)
		reg_if_ack_o <= 1'b0;
   end

   assign s_extwake_in   = wake_gpio_i[r_extwake_sel];
   assign s_extwake_rise =  r_extevent_sync[1] & ~r_extevent_sync[0];
   assign s_extwake_fall = ~r_extevent_sync[1] &  r_extevent_sync[0];

   assign s_rtc_date_select  = reg_if_add_i == `REG_RTC_DATE;
   assign s_rtc_clock_select = reg_if_add_i == `REG_RTC_CLOCK;
   assign s_rtc_timer_select = reg_if_add_i == `REG_RTC_TIMER;
   assign s_rtc_alarm_select = reg_if_add_i == `REG_RTC_ALARM;

   assign s_rtc_date_update  = s_rtc_date_select & (s_rise & ~reg_if_wrn_i);
   assign s_rtc_alarm_update = s_rtc_alarm_select & (s_rise & ~reg_if_wrn_i);
   assign s_rtc_clock_update = s_rtc_clock_select & (s_rise & ~reg_if_wrn_i);
   assign s_rtc_timer_update = s_rtc_timer_select & (s_rise & ~reg_if_wrn_i);

	rtc_clock i_rtc_clock (
		.clk_i           ( clk_i                 ),
		.rstn_i          ( rstn_i                ),
		.clock_update_i  ( s_rtc_clock_update    ),
		.clock_o         ( s_rtc_clock           ),
		.clock_i         ( reg_if_wdata_i[21:0]  ),
    .init_sec_cnt_i  ( reg_if_wdata_i[31:22] ),
		.timer_update_i  ( s_rtc_timer_update    ),
		.timer_enable_i  ( reg_if_wdata_i[31]    ),
    .timer_retrig_i  ( reg_if_wdata_i[30]    ),
		.timer_target_i  ( reg_if_wdata_i[16:0]  ),
		.timer_value_o   ( s_rtc_timer           ),
		.alarm_enable_i  ( reg_if_wdata_i[31]    ),
		.alarm_update_i  ( s_rtc_alarm_update    ),
		.alarm_clock_i   ( reg_if_wdata_i[21:0]  ),
		.alarm_clock_o   ( s_rtc_alarm           ),
		.event_o         ( rtc_event_o           ),
		.update_day_o    ( s_rtc_update_day      )
	);

	rtc_date i_rtc_date (
		.clk_i          ( clk_i                ),
		.rstn_i         ( rstn_i               ),
		.date_update_i  ( s_rtc_date_update    ),
		.date_i         ( reg_if_wdata_i[31:0] ),
		.date_o         ( s_rtc_date           ),
		.new_day_i      ( s_rtc_update_day     )
	);

   always_ff @(posedge clk_i, negedge rstn_i)
     begin
	if(!rstn_i)
	  begin
	     r_cfg_ret              <= 13'h0;
	     r_rar_nv_volt          <= 5'h0D; //1.2V
	     r_rar_mv_volt          <= 5'h09; //1.0V
	     r_rar_lv_volt          <= 5'h09; //1.0V
	     r_rar_rv_volt          <= 5'h05; //0.8V
       r_sleep_pad_cfg0       <= '0;
       r_sleep_pad_cfg1       <= '0;
       r_pad_sleep            <= '0;
	     r_extwake_sel          <= '0;
	     r_extwake_en           <= '0;
	     r_extwake_type         <= '0;
	     r_extevent             <= 0;
	     r_extevent_sync        <= 0;
	     r_wakeup               <= 0;
	     r_cluster_wake         <= 1'b0;
	     r_boot_l2              <= 0;
	     r_reboot               <= 2'b00;
	  end
	else if (s_rise & ~reg_if_wrn_i)
	  begin
	     case(reg_if_add_i)
	       `REG_RAR:
	  	 begin
		    r_rar_nv_volt <= reg_if_wdata_i[4:0];
		    r_rar_mv_volt <= reg_if_wdata_i[12:8];
		    r_rar_lv_volt <= reg_if_wdata_i[20:16];
		    r_rar_rv_volt <= reg_if_wdata_i[28:24];
	  	 end
	       `REG_SLEEP_CTRL:
	  	 begin
        r_cfg_ret[13:12] <= reg_if_wdata_i[1:0];
        r_cfg_ret[11]    <= reg_if_wdata_i[2];
		    r_extwake_sel    <= reg_if_wdata_i[10:6];
		    r_extwake_type   <= reg_if_wdata_i[12:11];
		    r_extwake_en     <= reg_if_wdata_i[13];
		    r_wakeup         <= reg_if_wdata_i[15:14];
		    r_boot_l2        <= reg_if_wdata_i[16];
		    // pmu extint readonly [17]
		    r_reboot         <= reg_if_wdata_i[19:18];
		    r_cluster_wake   <= reg_if_wdata_i[20];
        r_cfg_ret[10:0] <= reg_if_wdata_i[31:21];
	  	 end

           `REG_SLEEPPADCFG0:
         for (int i=0;i<16;i++)
           begin
              r_sleep_pad_cfg0[i] <= reg_if_wdata_i[i*2];
              r_sleep_pad_cfg1[i] <= reg_if_wdata_i[i*2+1];
           end
           `REG_SLEEPPADCFG1:
         for (int i=0;i<16;i++)
           begin
              r_sleep_pad_cfg0[16+i] <= reg_if_wdata_i[i*2];
              r_sleep_pad_cfg1[16+i] <= reg_if_wdata_i[i*2+1];
           end
           `REG_SLEEPPADCFG2:
         for (int i=0;i<16;i++)
           begin
              r_sleep_pad_cfg0[32+i] <= reg_if_wdata_i[i*2];
              r_sleep_pad_cfg1[32+i] <= reg_if_wdata_i[i*2+1];
           end
           `REG_SLEEPPADCFG3:
         for (int i=0;i<16;i++)
           begin
              r_sleep_pad_cfg0[48+i] <= reg_if_wdata_i[i*2];
              r_sleep_pad_cfg1[48+i] <= reg_if_wdata_i[i*2+1];
           end

           `REG_PADSLEEP:
         begin
            r_pad_sleep          <= reg_if_wdata_i[0];
         end

	     endcase
	  end
	  else if (s_rise & reg_if_wrn_i)
	  begin
	     case(reg_if_add_i)
	       `REG_SLEEP_CTRL:
	  	 begin
	  	 	if (r_extevent)
	  	 		r_extevent <= 1'b0;
	  	 end
	  	 endcase // reg_if_add_i
	  end
	  else
	  begin
	  	if (r_extwake_en)
	  	begin
	  		r_extevent_sync <= {s_extwake_in,r_extevent_sync[2:1]};
	  		case(r_extwake_type)
	  			2'b00:
	  				if(s_extwake_rise)      r_extevent <= 1'b1;
	  			2'b01:
	  				if(s_extwake_fall)      r_extevent <= 1'b1;
	  			2'b10:
	  				if(r_extevent_sync[0])  r_extevent <= 1'b1;
	  			2'b11:
	  				if(!r_extevent_sync[0]) r_extevent <= 1'b1;
	  		endcase // r_extwake_sel
	  	end
	  end
     end

   always_comb begin
      case(reg_if_add_i)
        `REG_RAR:
          reg_if_rdata_o = {3'h0,r_rar_rv_volt,3'h0,r_rar_lv_volt,3'h0,r_rar_mv_volt,3'h0,r_rar_nv_volt};
        `REG_SLEEP_CTRL:
          reg_if_rdata_o = s_pmu_sleep_control;
        `REG_SLEEPPADCFG0:
                for (int i=0;i<16;i++)
                  begin
                     reg_if_rdata_o[i*2]   = r_sleep_pad_cfg0[i];
                     reg_if_rdata_o[i*2+1] = r_sleep_pad_cfg1[i];
                  end
        `REG_SLEEPPADCFG1:
                for (int i=0;i<16;i++)
                  begin
                     reg_if_rdata_o[i*2]   = r_sleep_pad_cfg0[16+i];
                     reg_if_rdata_o[i*2+1] = r_sleep_pad_cfg1[16+i];
                  end
        `REG_SLEEPPADCFG2:
                for (int i=0;i<16;i++)
                  begin
                     reg_if_rdata_o[i*2]   = r_sleep_pad_cfg0[32+i];
                     reg_if_rdata_o[i*2+1] = r_sleep_pad_cfg1[32+i];
                  end
        `REG_SLEEPPADCFG3:
                for (int i=0;i<16;i++)
                  begin
                     reg_if_rdata_o[i*2]   = r_sleep_pad_cfg0[48+i];
                     reg_if_rdata_o[i*2+1] = r_sleep_pad_cfg1[48+i];
                  end
        `REG_PADSLEEP:
          reg_if_rdata_o = {31'h0,r_pad_sleep};
		`REG_RTC_DATE:
		  reg_if_rdata_o = s_rtc_date;
		`REG_RTC_CLOCK:
		  reg_if_rdata_o = s_rtc_clock;
		`REG_RTC_TIMER:
		  reg_if_rdata_o = s_rtc_timer;
		`REG_RTC_ALARM:
		  reg_if_rdata_o = s_rtc_alarm;
		default:
		  reg_if_rdata_o = 'h0;
	  endcase
   end

   always_comb begin
      for (int i=0;i<64;i++)
        begin
           pad_sleep_cfg_o[i][0]  = r_sleep_pad_cfg0[i];
           pad_sleep_cfg_o[i][1]  = r_sleep_pad_cfg1[i];
        end
   end

   assign pad_sleep_mode_o = r_pad_sleep;

   assign s_pmu_sleep_control = {r_cfg_ret[10:0],r_cluster_wake,r_reboot,r_extevent,r_boot_l2,r_wakeup,r_extwake_en,r_extwake_type,r_extwake_sel,3'h0,r_cfg_ret[11],r_cfg_ret[13:12]};

   assign pmu_sleep_control_o = s_pmu_sleep_control;

endmodule // safe_domain_reg_if

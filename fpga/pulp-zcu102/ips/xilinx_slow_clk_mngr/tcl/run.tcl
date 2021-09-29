source ../../tcl/common.tcl

# detect target clock
if [info exists ::env(SLOW_CLK_PERIOD_NS)] {
    set SLOW_CLK_PERIOD_NS $::env(SLOW_CLK_PERIOD_NS)
} else {
    set SLOW_CLK_PERIOD_NS 30517
}

# Multiply frequency by 256 as there is a clock divider (by 256) after the
# slow_clk_mngr since the MMCMs do not support clocks slower then 4.69 MHz.
set SLOW_CLK_FREQ_MHZ [expr 1000 * 256 / $SLOW_CLK_PERIOD_NS]

set ipName xilinx_slow_clk_mngr

create_project $ipName . -part $partNumber
set_property board_part $XILINX_BOARD [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.PRIM_IN_FREQ {125.000} \
                        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$SLOW_CLK_FREQ_MHZ} \
                        CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
                        CONFIG.USE_LOCKED {false} \
                        CONFIG.RESET_TYPE {ACTIVE_LOW} \
                        CONFIG.CLKIN1_JITTER_PS {50.0} \
                        CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
                        CONFIG.RESET_PORT {resetn} \
                       ] [get_ips $ipName]


generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1

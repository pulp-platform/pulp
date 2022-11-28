source tcl/common.tcl

set PROJECT pulp-$BOARD
set RTL ../../../rtl
set CONSTRS constraints
set FPGA_RTL rtl
set FPGA_IPS ips

# create project
create_project $PROJECT . -force -part $::env(XILINX_PART)
set_property board_part $XILINX_BOARD [current_project]

# Add sources
source tcl/add_sources.tcl

# Set Verilog Defines.
set DEFINES "FPGA_TARGET_XILINX=1 TARGET_FPGA=1 TARGET_XILINX=1 PULP_FPGA_EMUL=1 AXI4_XCHECK_OFF=1"
if { $BOARD == "zcu102" } {
    set DEFINES "$DEFINES zcu102=1"
}
if { $BOARD == "vcu118" } {
    set DEFINES "$DEFINES vcu118=1"
}
set_property verilog_define $DEFINES [current_fileset]

# detect target clock
if [info exists ::env(FC_CLK_PERIOD_NS)] {
    set FC_CLK_PERIOD_NS $::env(FC_CLK_PERIOD_NS)
} else {
    set FC_CLK_PERIOD_NS 10.000
}
set CLK_HALFPERIOD_NS [expr ${FC_CLK_PERIOD_NS} / 2.0]

# Add toplevel wrapper
add_files -norecurse ../pulp-$BOARD/rtl/xilinx_pulp.v

# Add Xilinx IPs
read_ip $FPGA_IPS/xilinx_clk_mngr/xilinx_clk_mngr.srcs/sources_1/ip/xilinx_clk_mngr/xilinx_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_slow_clk_mngr/xilinx_slow_clk_mngr.srcs/sources_1/ip/xilinx_slow_clk_mngr/xilinx_slow_clk_mngr.xci

# set pulp as top
set_property top xilinx_pulp [current_fileset]; #

# needed only if used in batch mode
update_compile_order -fileset sources_1

# Add constraints
add_files -fileset constrs_1 -norecurse ../pulp-$BOARD/$CONSTRS/$BOARD.xdc

auto_detect_xpm

# Elaborate design
synth_design -rtl -name rtl_1 -gated_clock_conversion on -sfcu;# sfcu -> run synthesis in single file compilation unit mode

# Launch synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value -sfcu -objects [get_runs synth_1] ;# Use single file compilation unit mode to prevent issues with import pkg::* statements in the codebase
launch_runs synth_1 -jobs $CPUS
wait_on_run synth_1
open_run synth_1 -name netlist_1
set_property needs_refresh false [get_runs synth_1]

# Remove unused IOBUF cells in padframe (they are not optimized away since the
# pad driver also drives the input creating a datapath from pad_xy_o to pad_xy_i
# )
remove_cell i_pulp/pad_frame_i/padinst_bootsel0
remove_cell i_pulp/pad_frame_i/padinst_bootsel1


# Launch Implementation

# set for RuntimeOptimized implementation
set_property "steps.opt_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.place_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.route_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.phys_opt_design.args.is_enabled" true [get_runs impl_1]
set_property "steps.phys_opt_design.args.directive" "ExploreWithHoldFix" [get_runs impl_1]
set_property "steps.post_route_phys_opt_design.args.is_enabled" true [get_runs impl_1]
set_property "steps.post_route_phys_opt_design.args.directive" "ExploreWithAggressiveHoldFix" [get_runs impl_1]

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs impl_1 -jobs $CPUS 
wait_on_run impl_1
launch_runs impl_1 -jobs $CPUS -to_step write_bitstream
wait_on_run impl_1

open_run impl_1

# Generate reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/$PROJECT.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/$PROJECT.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/$PROJECT.timing.rpt
report_utilization -hierarchical                                          -file reports/$PROJECT.utilization.rpt

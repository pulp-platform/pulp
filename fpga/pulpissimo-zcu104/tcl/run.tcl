set project pulpissimo_zcu104
set RTL ../../../rtl
set IPS ../../../ips
set CONSTRS constraints


# detect board
if [info exists ::env(BOARD)] {
    set BOARD $::env(BOARD)
} else {
    puts "Please execute 'source ../sourceme.sh first before you start vivado in order to setup necessary environment variables."
    exit
}
if [info exists ::env(XILINX_BOARD)] {
    set XILINX_BOARD $::env(XILINX_BOARD)
}

# create project
create_project $project . -force -part $::env(XILINX_PART)
set_property board_part $XILINX_BOARD [current_project]

# set up meaningfull errors
source tcl/messages.tcl

# set up includes
source ../pulpissimo/tcl/ips_inc_dirs.tcl
set_property include_dirs $INCLUDE_DIRS [current_fileset]
set_property include_dirs $INCLUDE_DIRS [current_fileset -simset]

# setup and add IP source files
source ../pulpissimo/tcl/ips_src_files.tcl
source ../pulpissimo/tcl/ips_add_files.tcl

# setup and add RTL source files
source ../pulpissimo/tcl/rtl_src_files.tcl
source ../pulpissimo/tcl/rtl_add_files.tcl

# Override IPSApprox default variables
set FPGA_RTL rtl
set FPGA_IPS ips

# remove duplicate incompatible modules
remove_files $IPS/pulp_soc/rtl/components/axi_slice_dc_slave_wrap.sv
remove_file $IPS/pulp_soc/rtl/components/axi_slice_dc_master_wrap.sv
remove_file $IPS/tech_cells_generic/pad_functional_xilinx.sv

# Set Verilog Defines.
set DEFINES "FPGA_TARGET_XILINX=1 PULP_FPGA_EMUL=1 AXI4_XCHECK_OFF=1"
if { $BOARD == "zcu104" } {
    set DEFINES "$DEFINES ZCU104=1"
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
add_files -norecurse $FPGA_RTL/xilinx_pulpissimo.v

# Add Xilinx IPs
read_ip $FPGA_IPS/xilinx_clk_mngr/ip/xilinx_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_slow_clk_mngr/ip/xilinx_slow_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_interleaved_ram/ip/xilinx_interleaved_ram.xci
read_ip $FPGA_IPS/xilinx_private_ram/ip/xilinx_private_ram.xci

# Add wrappers and xilinx specific techcells
add_files -norecurse $FPGA_RTL/fpga_clk_gen.sv
add_files -norecurse $FPGA_RTL/fpga_slow_clk_gen.sv
add_files -norecurse $FPGA_RTL/fpga_interleaved_ram.sv
add_files -norecurse $FPGA_RTL/fpga_private_ram.sv
add_files -norecurse $FPGA_RTL/fpga_bootrom.sv
add_files -norecurse $FPGA_RTL/pad_functional_xilinx.sv
add_files -norecurse $FPGA_RTL/pulp_clock_gating_xilinx.sv


# set pulpissimo as top
set_property top xilinx_pulpissimo [current_fileset]; #

# needed only if used in batch mode
update_compile_order -fileset sources_1

# Add constraints
add_files -fileset constrs_1 -norecurse $CONSTRS/zcu104.xdc

# Elaborate design
synth_design -rtl -name rtl_1 -sfcu;# sfcu -> run synthesis in single file compilation unit mode



# launch synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value -sfcu -objects [get_runs synth_1] ;# Use single file compilation unit mode to prevent issues with import pkg::* statements in the codebase
launch_runs synth_1 -jobs 8
wait_on_run synth_1
open_run synth_1 -name netlist_1
set_property needs_refresh false [get_runs synth_1]

# Remove unused IOBUF cells in padframe (they are not optimized away since the
# pad driver also drives the input creating a datapath from pad_xy_o to pad_xy_i
# )
remove_cell i_pulpissimo/pad_frame_i/padinst_bootsel


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

launch_runs impl_1 -jobs 8
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

open_run impl_1

# Generate reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical                                          -file reports/${project}.utilization.rpt

# create project
create_project pulp_cluster . -force -part $::env(XILINX_PART)
set_property board_part $::env(XILINX_BOARD) [current_project]

# set up includes
source tcl/ips_inc_dirs.tcl
source tcl/rtl_inc_dirs.tcl
set_property include_dirs $INCLUDE_DIRS [current_fileset]

# set up meaningful errors
source ../common/messages.tcl

# setup source files
source tcl/ips_src_files.tcl
source tcl/rtl_src_files.tcl

# add IPs
source tcl/ips_add_files.tcl
source tcl/rtl_add_files.tcl

# add memory cuts + FPU IPs
read_ip $FPGA_IPS/xilinx_tcdm_bank_1024x32/ip/xilinx_tcdm_bank_1024x32.xci
read_ip $FPGA_IPS/xilinx_tcdm_bank_2048x32/ip/xilinx_tcdm_bank_2048x32.xci

# set pulp_cluster as top
set_property top pulp_cluster [current_fileset]

# needed only if used in batch mode
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# add constraints
add_files -fileset constrs_1 -norecurse tcl/constraints.xdc
set_property target_constrs_file tcl/constraints.xdc [current_fileset -constrset]
# create path groups
add_files -fileset constrs_1 -norecurse tcl/create_path_groups.xdc
set_property target_constrs_file tcl/create_path_groups.xdc [current_fileset -constrset]

# run synthesis
# first try will fail
catch {synth_design -rtl -name rtl_1 -verilog_define PULP_FPGA_EMUL=1 -verilog_define PERF_COUNTERS=1 -verilog_define RISCV=1 -gated_clock_conversion on -constrset constrs_1}
update_compile_order -fileset sources_1
synth_design -rtl -name rtl_1 -verilog_define PULP_FPGA_EMUL=1 -verilog_define PERF_COUNTERS=1 -verilog_define RISCV=1 -gated_clock_conversion on -constrset constrs_1

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

launch_runs synth_1 -jobs 28
wait_on_run synth_1
open_run synth_1

# save EDIF netlist
write_edif -force pulp_cluster.edf
write_verilog -force -mode synth_stub pulp_cluster_stub.v
write_verilog -force -mode funcsim pulp_cluster_funcsim.v

# reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                            -file reports/pulp_cluster.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/pulp_cluster.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/pulp_cluster.timing.rpt
report_utilization -hierarchical                                        -file reports/pulp_cluster.utilization.rpt

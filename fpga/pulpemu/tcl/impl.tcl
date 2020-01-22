# set for RuntimeOptimized implementation
set_property "steps.opt_design.args.directive"   "RuntimeOptimized" [get_runs impl_1]
set_property "steps.place_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.route_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.phys_opt_design.args.is_enabled" true [get_runs impl_1]
set_property "steps.phys_opt_design.args.directive" "ExploreWithHoldFix" [get_runs impl_1]
set_property "steps.post_route_phys_opt_design.args.is_enabled" true [get_runs impl_1]
set_property "steps.post_route_phys_opt_design.args.directive" "ExploreWithAggressiveHoldFix" [get_runs impl_1]

launch_runs impl_1 -jobs 12
wait_on_run impl_1

catch {
# Set only for VCU device to flash SPI flash fast
open_run impl_1
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8         [get_designs impl_1]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES      [get_designs impl_1]
reset_run impl_1
}

# reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                                                         -file reports/pulpemu.check_timing.rpt

catch {
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack                              -file reports/pulpemu.timing_WORST_100.rpt
report_timing -group CLUSTER_CLK -max_paths 100 -nworst 100 -delay_type max -sort_by slack           -file reports/pulpemu.timing_CLUSTER_WORST_100.rpt
report_timing -group SOC_CLK -max_paths 100 -nworst 100 -delay_type max -sort_by slack               -file reports/pulpemu.timing_SOC_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                                               -file reports/pulpemu.timing.rpt
report_utilization -hierarchical                                                                     -file reports/pulpemu.utilization.rpt
report_utilization -hierarchical -hierarchical_depth 1                                               -file reports/pulpemu.area_top.rpt
report_utilization -hierarchical -hierarchical_depth 2 -cells pulp_chip_i                            -file reports/pulpemu.area_pulp_chip.rpt
report_utilization -hierarchical -hierarchical_depth 2 -cells pulp_chip_i/soc_domain_i/pulp_soc_i      -file reports/pulpemu.area_soc.rpt
report_utilization -hierarchical -hierarchical_depth 2 -cells pulp_chip_i/cluster_domain_i/cluster_i -file reports/pulpemu.area_cluster.rpt
}

launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1


# output Verilog netlist + SDC for timing simulation
write_verilog -force -mode funcsim pulpemu_funcsim.v
write_verilog -force -mode timesim pulpemu_timesim.v
write_sdf     -force pulpemu_timesim.sdf

# copy bitstream
exec cp pulpemu.runs/impl_1/pulpemu.bit .
if [info exists ::env(SDK_WORKSPACE)] {
    exec cp pulpemu.bit $SDK_WORKSPACE/.
}

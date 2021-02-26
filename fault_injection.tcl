# Fault injection file by Michael Rogenmoser
# 
# Based in part on:
#   - https://diglib.tugraz.at/download.php?id=576a7490f01c3&location=browse

# Signal where a fault is injected
set ::signal_to_force "/tb_pulp/i_dut/cluster_domain_i/cluster_i/cTCLS_gen/cTCLS(0)/core_ctcls_i/core_data_add_i(0)(0)"
# puts $::signal_to_force
# set fault_type = "TRANSIENT"
# echo [drivers $::signal_to_force]

# set ::injection_time 16000000ns
# puts $::injection_time

# when { sim:/tb_pulp/i_dut/cluster_domain_i/cluster_i/fetch_en_int(0) == 1 } {
#   set transient_input [examine $::signal_to_force]
#   echo $transient_input
#   if {$transient_input == "1'h1"} {
#     force -freeze sim:$signal_to_force 0 -cancel 20ns
#     force -deposit sim:$signal_to_force 0 20ns
#   }
#   if {$transient_input == "1'h0"} {
#     force -freeze sim:$signal_to_force 1 -cancel 20ns
#     force -deposit sim:$signal_to_force 1 20ns
#   }
#   if {$transient_input == "1'x"} {
#     echo "don't care!"
#   }
# }

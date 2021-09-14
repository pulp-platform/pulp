# Fault injection file by Michael Rogenmoser
# 
# Based in part on:
#   - https://diglib.tugraz.at/download.php?id=576a7490f01c3&location=browse


echo "\[FAULT\] Injection script running."

set FAULTY_CORE 4

# Simple injection at interface
# Signal where a fault is injected
# set ::signal_to_force "/tb_pulp/i_dut/cluster_domain_i/cluster_i/instr_addr_tcls(0)(0)"
# when { $now == 17500000ns } {
#   echo "\[FAULT\] Injecting fault."
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

# Single Fault injection to every RegFile element
set ::signal_to_force "/tb_pulp/i_dut/cluster_domain_i/cluster_i/CORE($FAULTY_CORE)/core_wrap_i/CL_CORE/IBEX_CORE/u_ibex_core/gen_regfile_ff/register_file_i/rf_reg_q"
when { $now == 17660000ns } {
  echo "\[FAULT\] ${now} - Injecting fault to all of RegFile."
  for { set i 1 } { $i < 32 } { incr i } {
    set j 5
    set ::current_signal "${::signal_to_force}(${i})(${j})"
    set transient_input [examine $::current_signal]
    if {$transient_input == "1'h1"} {
      force -freeze sim:$current_signal 0 -cancel 20ns
      force -deposit sim:$current_signal 0 20ns
    }
    if {$transient_input == "1'h0"} {
      force -freeze sim:$current_signal 1 -cancel 20ns
      force -deposit sim:$current_signal 1 20ns
    }
    if {$transient_input == "1'x"} {
      echo "don't care!"
    }
  }
}

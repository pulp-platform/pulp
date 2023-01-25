# Copyright 2021 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Luca Rufer (lrufer@student.ethz.ch)

# Disable transcript
transcript quietly

# == Verbosity if the fault injection script ==
# 0 : No statements at all
# 1 : Only important initializaion information
# 2 : Important information and occurences of bitflips (recommended)
# 3 : All information that is possible
set verbosity 3

# Import Netlist procs
source tcl_files/fault_injection/extract_nets.tcl

###################
#  Test Settings  #
###################

# == random seed ==
expr srand(12345)

# == Time of first fault injection
# Note: Faults will be injected on falling clock edges to make the flipped
#       Signals (and their consequences) easier to see in the simulator
set inject_start_time 4370000ns

# == Period of Faults (in clk cycles, 0 for no repeat) ==
set fault_period 10000000000000

# == Time to force-stop simulation (set to 0 for no stop) ==
set inject_stop_time 0

# == Duration of the fault ==
set fault_duration 2ns

# == Cores where faults will be injected ==
set target_cores {{0 0 0} {0 0 1}}

# == Select where to inject faults
set inject_protected_states 0
set inject_unprotected_states 0
set inject_protected_regfile 0
set inject_unprotected_regfile 0
set inject_protected_lsu 0
set inject_unprotected_lsu 0
set inject_combinatorial_logic 0

# == Allow multiple injections in the same net ==
set allow_multi_bit_upset 0

# == Check if core outputs were modified by flip ==
set check_core_output_modification 0

# == Check if next state signals were modified by flip ==
set check_core_next_state_modification 0

# == Nets that can be flipped ==
# leave empty {} to generate the netlist according to the settings above
set force_flip_nets [get_output_netlist 0]
#set force_flip_nets [list \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/push_id \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/pop_id \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/id_table_push \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/id_table_pop \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/push_metadata \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/metadata_we \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/push_id \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/pop_id \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/id_table_push \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/id_table_pop \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/push_metadata \
[base_path 0 0 1]/gen_DMR_lsu/i_snitch_lsu/metadata_we \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/gen_meta_write/i_write_mux/wdata_error \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/gen_meta_write/i_write_mux/wen_error \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/gen_meta_write/i_write_mux/dmr_error_o \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/gen_meta_write/i_write_mux/wdata_expanded \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/data_1_i \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/data_2_i \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/data_1_o \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/data_2_o \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/dmr_err_o \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/voter_err_o \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/diff_12 \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/diff_23 \
[base_path 0 0 0]/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/sel \
]

########################################
#  Finish setup depending on settings  #
########################################

set inject_netlist $force_flip_nets

# Common path sections of all nets where errors can be injected (computed later)
set netlist_common_path_sections [list]

# List of combinatorial nets that contain the next state
set next_state_netlist [list]

# List of output nets
set output_netlist [list]

# == Assertions to be disabled to prevent simulation failures ==
# Note: Assertions will only be diabled between the inject start and stop time.
set assertion_disable_list [list]

# Add all targeted cores
# foreach target $target_cores {
#   foreach {group tile core} $target {}
#   set next_state_netlist [concat $next_state_netlist [get_next_state_netlist $group $tile $core]]
#   set output_netlist [concat $output_netlist [get_output_netlist $core]]
#   set assertion_disable_list [concat $assertion_disable_list [get_assertions $group $tile $core]]
# }

# check net list selection is forced
if {[llength $inject_netlist] == 0} {
  foreach target $target_cores {
    foreach {group tile core} $target {}
    if {$inject_protected_states} {
      set inject_netlist [concat $inject_netlist [get_protected_state_netlist $group $tile $core]]
    }
    if {$inject_unprotected_states} {
      set inject_netlist [concat $inject_netlist [get_unprotected_state_netlist $group $tile $core]]
    }
    if {$inject_protected_regfile} {
      set inject_netlist [concat $inject_netlist [get_protected_regfile_mem_netlist $group $tile $core]]
    }
    if {$inject_unprotected_regfile} {
      set inject_netlist [concat $inject_netlist [get_unprotected_regfile_mem_netlist $group $tile $core]]
    }
    if {$inject_protected_lsu} {
      set inject_netlist [concat $inject_netlist [get_protected_lsu_state_netlist $group $tile $core]]
    }
    if {$inject_unprotected_lsu} {
      set inject_netlist [concat $inject_netlist [get_unprotected_lsu_state_netlist $group $tile $core]]
    }
  }
}

#######################
#  Helper Procedures  #
#######################

proc time_ns {time_ps} {
  set time_str ""
  append time_str "[expr $time_ps / 1000]"
  set remainder [expr $time_ps % 1000]
  if {$remainder != 0} {
    append time_str "."
    if {$remainder < 100} {append time_str "0"}
    if {$remainder < 10} {append time_str "0"}
    append time_str "$remainder"
  }
  append time_str " ns"
  return $time_str
}

proc find_common_path_sections {netlist} {
  # Safety check if the list has any elements
  if {[llength $netlist] == 0} {
    return [list]
  }
  # Extract the first net as reference
  set first_net [lindex $netlist 0]
  set first_net_sections [split $first_net "/"]
  # Determine the minimal number of sections in the netlist
  set min_num_sections 9999
  foreach net $netlist {
    set cur_path_sections [split $net "/"]
    set num_sections [llength $cur_path_sections]
    if {$num_sections < $min_num_sections} {set min_num_sections $num_sections}
  }
  # Create a match list
  set match_list [list]
  for {set i 0} {$i < $min_num_sections} {incr i} {lappend match_list 1}
  # Test for every net which sections in its path matches the first net path
  foreach net $netlist {
    set cur_path_sections [split $net "/"]
    # Test every section
    for {set i 0} {$i < $min_num_sections} {incr i} {
      # prevent redundant checking for speedup
      if {[lindex $match_list $i] != 0} {
        # check if the sections matches the first net section
        if {[lindex $first_net_sections $i] != [lindex $cur_path_sections $i]} {
          lset match_list $i 0
        }
      }
    }
  }
  return $match_list
}

proc net_print_str {net_name} {
  # Check if the list exists
  if {[llength $::netlist_common_path_sections] == 0} {
    return $net_name
  }
  # Split the netname path
  set cur_path_sections [split $net_name "/"]
  set print_str ""
  set printed_dots 0
  # check sections individually
  for {set i 0} {$i < [llength $cur_path_sections]} {incr i} {
    # check if the section at the current index is a common to all paths
    if {$i < [llength $::netlist_common_path_sections] && [lindex $::netlist_common_path_sections $i] == 1} {
      # Do not print the dots if multiple sections match in sequence
      if {!$printed_dots} {
        # Print dots to indicate the path was shortened
        append print_str "\[...\]"
        if {$i != [llength $cur_path_sections] - 1} {append print_str "/"}
        set printed_dots 1
      }
    } else {
      # Sections don't match, print the path section
      append print_str "[lindex $cur_path_sections $i]"
      if {$i != [llength $cur_path_sections] - 1} {append print_str "/"}
      set printed_dots 0
    }
  }
  return $print_str
}

################
#  Flip a Bit  #
################

# flip a spefific bit of the given net name. returns a 1 if the bit could be flipped
proc flipbit {signal_name} {
  set success 0
  set old_value [examine -radixenumsymbolic $signal_name]
  # check if net is an enum
  if {[examine -radixenumnumeric $signal_name] != [examine -radixenumsymbolic $signal_name]} {
    set old_value_numeric [examine -radix binary,enumnumeric $signal_name]
    set new_value_numeric [expr int(rand()*([expr 2 ** [string length $old_value_numeric]]))]
    while {$old_value_numeric == $new_value_numeric && [string length $old_value_numeric] != 1} {
      set new_value_numeric [expr int(rand()*([expr 2 ** [string length $old_value_numeric]]))]
    }
    force -freeze sim:$signal_name $new_value_numeric, $old_value_numeric $::fault_duration -cancel $::fault_duration
    set success 1
  } else {
    set flip_signal_name $signal_name
    set bin_val [examine -radix binary $signal_name]
    set len [string length $bin_val]
    set flip_index 0
    if {$len != 1} {
      set flip_index [expr int(rand()*$len)]
      set flip_signal_name $signal_name\($flip_index\)
    }
    set old_bit_value "0"
    set new_bit_value "1"
    if {[string index $bin_val [expr $len - 1 - $flip_index]] == "1"} {
      set new_bit_value "0"
      set old_bit_value "1"
    }
    force -freeze sim:$flip_signal_name $new_bit_value, $old_bit_value $::fault_duration -cancel $::fault_duration
    if {[examine -radix binary $signal_name] != $bin_val} {set success 1}
  }
  set new_value [examine -radixenumsymbolic $signal_name]
  set result [list $success $old_value $new_value]
  return $result
}

##############################
#  Fault injection routine   #
##############################

# Statistics
set stat_num_bitflips 0
set stat_num_outputs_changed 0
set stat_num_state_changed 0
set stat_num_flip_propagated 0

# Start the Error injection script
if {$verbosity >= 1} {
  echo "\[Fault Injection\] Injection script running."
}

# Open the log file
set time_stamp [exec date +%Y%m%d_%H%M%S]
set injection_log [open "fault_injection_$time_stamp.log" w+]
puts $injection_log "timestamp,netname,pre_flip_value,post_flip_value,output_changed,new_state_changed"

# After the simulation start, get all the nets of the core
when { $now == 10ns } {
  if {$inject_combinatorial_logic} {
    foreach target $target_cores {
      foreach {group tile core} $target {}
      set inject_netlist [concat $inject_netlist [get_all_core_nets $group $tile $core]]
    }
  }
  # print how many nets were found
  set num_nets [llength $inject_netlist]
  if {$::verbosity >= 1} {
    echo "\[Fault Injection\] Selected $num_nets nets for fault injection."
  }
  # print all nets that were found
  if {$::verbosity >= 3} {
    foreach net $inject_netlist {
      echo " - [get_net_reg_width $net]-bit [get_net_type $net] : $net"
    }
    echo ""
  }
  # determine the common sections
  set ::netlist_common_path_sections [find_common_path_sections $inject_netlist]
}

# start fault injection
when "\$now == $inject_start_time" {
  if {$verbosity >= 1} {
    echo "$inject_start_time: \[Fault Injection\] Starting fault injection."
  }
  foreach assertion $assertion_disable_list {
    assertion enable -off $assertion
  }
}

# Dictionary to keep track of injections
set inject_dict [dict create]

# periodically inject faults
set prescaler [expr $fault_period - 1]
when "\$now >= $inject_start_time and /tb_pulp/i_dut/cluster_domain_i/cluster_i/clk_cluster == \"1'h0\"" {
  incr prescaler
  if {$prescaler == $fault_period && [llength $inject_netlist] != 0} {
    set prescaler 0

    # record the output before the flip
    set pre_flip_out_val [list]
    if {$check_core_output_modification} {
      foreach net $output_netlist {
        lappend pre_flip_out_val [examine $net]
      }
    }
    # record the new state before the flip
    set pre_flip_next_state_val [list]
    if {$check_core_next_state_modification} {
      foreach net $next_state_netlist {
        lappend pre_flip_next_state_val [examine $net]
      }
    }

    # Questa currently has a bug that it won't force certain nets. So we retry
    # until we successfully flip a net.
    # The bug primarily affects arrays of structs:
    # If you try to force a member/field of a struct in an array, QuestaSim will
    # flip force that member/field in the struct/record with index 0 in the
    # array, not at the array index that was specified.
    set success 0
    set attempts 0
    while {!$success && [incr attempts] < 50} {
      # get a random net
      set idx [expr int(rand()*[llength $inject_netlist])]
      set net_to_flip [lindex $inject_netlist $idx]

      # Check if the selected net is allowed to be flipped
      set allow_flip 1
      if {!$allow_multi_bit_upset} {
        set net_value [examine -radixenumsymbolic $net_to_flip]
        if {[dict exists $inject_dict $net_to_flip] && [dict get $inject_dict $net_to_flip] == $net_value} {
          set allow_flip 0
          if {$verbosity >= 3} {
            echo "[time_ns $now]: \[Fault Injection\] Tried to flip [net_print_str $net_to_flip], but was already flipped."
          }
        }
      }
      # flip the random net
      if {$allow_flip} {
        set flip_return [flipbit $net_to_flip]
        if {[lindex $flip_return 0]} {
          set success 1
          if {!$allow_multi_bit_upset} {
            # save the new value to the dict
            dict set inject_dict $net_to_flip [examine -radixenumsymbolic $net_to_flip]
          }
        } else {
          if {$::verbosity >= 3} {
            echo "[time_ns $now]: \[Fault Injection\] Failed to flip [net_print_str $net_to_flip]. Choosing another one."
          }
        }
      }
    }
    if {$success} {
      incr stat_num_bitflips

      set flip_propagated 0
      # record the output after the flip
      set post_flip_out_val [list]
      if {$check_core_output_modification} {
        foreach net $output_netlist {
          lappend post_flip_out_val [examine $net]
        }
        # check if the output changed
        set output_state "not modified"
        set output_changed [expr ![string equal $pre_flip_out_val $post_flip_out_val]]
        if {$output_changed} {
          set output_state "changed"
          incr stat_num_outputs_changed
          set flip_propagated 1
        }
      } else {
        set output_changed "x"
      }
      # record the new state before the flip
      set post_flip_next_state_val [list]
      if {$check_core_next_state_modification} {
        foreach net $next_state_netlist {
          lappend post_flip_next_state_val [examine $net]
        }
        # check if the new state changed
        set new_state_state "not modified"
        set new_state_changed [expr ![string equal $pre_flip_next_state_val $post_flip_next_state_val]]
        if {$new_state_changed} {
          set new_state_state "changed"
          incr stat_num_state_changed
          set flip_propagated 1
        }
      } else {
        set new_state_changed "x"
      }

      if {$flip_propagated} {
        incr stat_num_flip_propagated
      }
      # display the result
      if {$verbosity >= 2} {
        set print_str "[time_ns $now]: \[Fault Injection\] "
        append print_str "Flipped net [net_print_str $net_to_flip] from [lindex $flip_return 1] to [lindex $flip_return 2]. "
        if {$check_core_output_modification} {
          append print_str "Output signals $output_state. "
        }
        if {$check_core_next_state_modification} {
          append print_str "New state $new_state_state. "
        }
        echo $print_str
      }
      # Log the result
      puts $injection_log "$now,$net_to_flip,[lindex $flip_return 1],[lindex $flip_return 2],$output_changed,$new_state_changed"
      flush $injection_log
    }
  }
}

# stop the simulation and output statistics
when "\$now >= $inject_stop_time" {
  if { $inject_stop_time != 0 } {
    # Stop the simulation
    stop
    # Enable Assertions again
    foreach assertion $assertion_disable_list {
      assertion enable -on $assertion
    }
    # Output simulation Statistics
    if {$verbosity >= 1} {
      echo " ========== Fault Injection Statistics ========== "
      echo " Number of Bitflips : $stat_num_bitflips"
      echo " Number of Bitflips propagated to outputs : $stat_num_outputs_changed"
      echo " Number of Bitflips propagated to new state : $stat_num_state_changed"
      echo " Number of Bitflips propagated : $stat_num_flip_propagated"
      echo ""
    }
    # Close the logfile
    close $injection_log
  }
}

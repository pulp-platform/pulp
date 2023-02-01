# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Luca Rufer (lrufer@student.ethz.ch)

# ============ List of variables that may be passed to this script ============
# Any of these variables may not be changed while the fault injection script
# is running, unless noted otherwise. Changing any of the settings during
# runtime may result in undefined behaviour.
# ----------------------------------- General ---------------------------------
# 'verbosity'         : Controls the amount of information printed during script
#                       execution. Possible values are:
#                       0 : No statements at all
#                       1 : Only important initializaion information
#                       2 : Important information and occurences of bitflips
#                           (Recommended). Default
#                       3 : All information that is possible
# 'log_injections'    : Create a logfile of all injected faults, including
#                       timestamps, the absolute path of the flipped net, the
#                       value before the flip, the value after the flip and
#                       more.
#                       The logfile is named "fault_injection_<time_stamp>.log".
#                       0 : Disable logging (Default)
#                       1 : Enable logging
# 'seed'              : Set the seed for the number generator. Default: 12345
# ------------------------------- Timing settings -----------------------------
# 'inject_start_time' : Earliest time of the first fault injection.
# 'inject_stop_time'  : Latest possible time for a fault injection.
#                       Set to 0 for no stop.
# 'injection_clock'   : Absolute path to the net that is used as an injected
#                       trigger and clock. Can be a special trigger clock in
#                       the testbench, or the normal system clock.
# 'injection_clock_trigger' : Signal value of 'injection_clock' that triggers
#                       the fault injection. If a normal clock of a rising edge
#                       triggered circuit is used as injection clock, it is
#                       recommended to set the trigger to '0', so injected
#                       flips can clearly be distinguished in the waveforms.
# 'fault_period'      : Period of the fault injection in clock cycles of the
#                       injection clock. Set to 0 for only a single flip.
# 'rand_initial_injection_phase' : Set the phase relative to the 'fault_period'
#                       to a random initial value between 0 (inclusive) and
#                       'fault_period' (exclusive). If multiple simulation
#                       with different seeds are performed, this option allows
#                       the injected faults to be evenly distributed accross
#                       the 'injection_clock' cycles.
#                       0 : Disable random phase. The first fault injection
#                           is performed at the first injeciton clock trigger
#                           after the 'inject_start_time'. Default.
#                       1 : Enable random phase.
# 'max_num_fault_inject' : Maximum number of faults to be injected. The number
#                       of faults injected may be lower than this if the
#                       simualtion finishes before, or if the 'inject_stop_time'
#                       is reached. If 'max_num_fault_inject' is set to 0, this
#                       setting is ignored (default).
# 'signal_fault_duration' : Duration of faults injected into combinatorial
#                       signals, before the original value is restored.
# 'register_fault_duration' : Minumum duration of faults injected into
#                       registers. Faults injected into registers are not
#                       restored after the 'register_fault_duration' and will
#                       persist until overwritten by the circuit under test.
# -------------------------------- Flip settings ------------------------------
# 'allow_multi_bit_upset' : Allow injecting another error in a Register that was
#                       already flipped and not driven to another value yet.
#                       0 : Disable multi bit upsets (default)
#                       1 : Enable multi bit upsets
# 'use_bitwidth_as_weight' : Use the bit width of a net as a weight for the
#                       random fault injection net selection. If this option
#                       is enabled, a N-bit net has an N times higher chance
#                       than a 1-bit net of being selected for fault injection.
#                       0 : Disable using the bitwidth as weight and give every
#                           net the same chance of being picked (Default).
#                       1 : Enable using the bit width of nets as weights.
# 'check_core_output_modification' : Check if an injected fault changes the
#                       output of the circuit under test. All nets in
#                       'output_netlist' are checked. The result of the check
#                       is printed after every flip (if verbosity high enough),
#                       and logged to the logfile.
#                       0 : Disable output modification checks. The check will
#                           be logged as 'x'.
#                       1 : Enable output modification checks.
# 'check_core_next_state_modification' : Check if an injected fault changes the
#                       next state of the circuit under test. All nets in
#                       'next_state_netlist' are checked. The result of the
#                       check is printed after every flip (if verbosity high
#                       enough), and logged to the logfile.
#                       0 : Disable next state modification checks. The check
#                           will be logged as 'x'.
#                       1 : Enable next state modification checks.
# 'reg_to_sig_ratio'  : Ratio of Registers to combinatorial signals to be
#                       selected for a fault injection. Example: A value of 4
#                       selects a ratio of 4:1, giving an 80% for a Register to
#                       be selected, and a 20% change of a combinatorial signal
#                       to be selected. If the provided
#                       'inject_register_netlist' is empty, or the
#                       'inject_signals_netlist' is empty, this parameter is
#                       ignored and nets are only selected from the non-empty
#                       netlist.
#                       Default value is 1, so the default ratio is 1:1.
# ---------------------------------- Netlists ---------------------------------
# 'inject_register_netlist' : List of absolute paths to Registers to be flipped
#                       in the simulation. This is used to simulate Single
#                       Event Upsets (SEUs). Flips injected in registers are not
#                       removed by the injection script. If the inject netlist
#                       is changed after this script was first called, the proc
#                       'updated_inject_netlist' must be called.
# 'inject_signals_netlist' : List of absolute paths to combinatorial signals to
#                       be flipped in the simulation. This is used to simulate
#                       Single Event Transients (SETs). A fault injection
#                       drives the target signal for a 'fault_duration', and
#                       afterwards returns the signal to its original state.
#                       If the inject netlist is changed after this script was
#                       first called, the proc 'updated_inject_netlist' must be
#                       called.
# 'output_netlist'    : List of absolute net or register paths to be used for
#                       the output modification check.
# 'next_state_netlist' : List of absolute net or register paths to be used for
#                       the next state modification check.
# 'assertion_disable_list' : List of absolute paths to named assertions that
#                       need to be disabled for during fault injecton.
#                       Assertions are enabled again after the simulation stop
#                       time.

##################################
#  Set default parameter values  #
##################################

# General
if {![info exists verbosity]}      { set verbosity          2 }
if {![info exists log_injections]} { set log_injections     0 }
if {![info exists seed]}           { set seed           12345 }
# Timing settings
if {![info exists inject_start_time]}            { set inject_start_time          100ns }
if {![info exists inject_stop_time]}             { set inject_stop_time             0   }
if {![info exists injection_clock]}              { set injection_clock          "clk"   }
if {![info exists injection_clock_trigger]}      { set injection_clock_trigger      0   }
if {![info exists fault_period]}                 { set fault_period                 0   }
if {![info exists rand_initial_injection_phase]} { set rand_initial_injection_phase 0   }
if {![info exists max_num_fault_inject]}         { set max_num_fault_inject         0   }
if {![info exists signal_fault_duration]}        { set signal_fault_duration        1ns }
if {![info exists register_fault_duration]}      { set register_fault_duration      0ns }
# Flip settings
if {![info exists allow_multi_bit_upset]}              { set allow_multi_bit_upset              0 }
if {![info exists check_core_output_modification]}     { set check_core_output_modification     0 }
if {![info exists check_core_next_state_modification]} { set check_core_next_state_modification 0 }
if {![info exists reg_to_sig_ratio]}                   { set reg_to_sig_ratio                   1 }
if {![info exists use_bitwidth_as_weight]}             { set use_bitwidth_as_weight             0 }
# Netlists
if {![info exists inject_register_netlist]} { set inject_register_netlist [list] }
if {![info exists inject_signals_netlist]}  { set inject_signals_netlist  [list] }
if {![info exists output_netlist]}          { set output_netlist          [list] }
if {![info exists next_state_netlist]}      { set next_state_netlist      [list] }
if {![info exists assertion_disable_list]}  { set assertion_disable_list  [list] }

# Source generic netlist extraction procs
source tcl_files/fault_injection/extract_nets.tcl

########################################
#  Finish setup depending on settings  #
########################################

# Set the seed
expr srand($seed)

# Common path sections of all nets where errors can be injected
set netlist_common_path_sections [list]

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

proc calculate_weight_by_width {netlist} {
  set total_weight 0
  set group_weight_dict [dict create]
  set group_net_dict [dict create]
  foreach net $netlist {
    # determine the width of a net (used as weight)
    set width [get_net_reg_width $net]
    if {![dict exists $group_weight_dict $width]} {
      # New width discovered, add new entry
      dict set group_weight_dict $width $width
      dict set group_net_dict $width [list $net]
    } else {
      dict incr group_weight_dict $width $width
      dict lappend group_net_dict $width $net
    }
  }
  # Sum weights of all groups
  foreach group_weight [dict values $group_weight_dict] {
    set total_weight [expr $total_weight + $group_weight]
  }
  return [list $total_weight $group_weight_dict $group_net_dict]
}

proc updated_inject_netlist {} {
  # print how many nets were found
  set num_reg_nets [llength $::inject_register_netlist]
  set num_comb_nets [llength $::inject_signals_netlist]
  if {$::verbosity >= 1} {
    echo "\[Fault Injection\] Selected $num_reg_nets Registers for fault injection."
    echo "\[Fault Injection\] Selected $num_comb_nets combinatorial Signals for fault injection."
  }
  # print all nets that were found
  if {$::verbosity >= 3} {
    echo "Registers: "
    foreach net $::inject_register_netlist {
      echo " - [get_net_reg_width $net]-bit [get_net_type $net] : $net"
    }
    echo "Combinatorial Signals: "
    foreach net $::inject_signals_netlist {
      echo " - [get_net_reg_width $net]-bit [get_net_type $net] : $net"
    }
    echo ""
  }
  # determine the common sections
  set combined_inject_netlist [concat $::inject_register_netlist $::inject_signals_netlist]
  set ::netlist_common_path_sections [find_common_path_sections $combined_inject_netlist]
  # determine the distribution of the nets
  if {$::use_bitwidth_as_weight} {
    set ::inject_register_distibrution_info [calculate_weight_by_width $::inject_register_netlist]
    set ::inject_signals_distibrution_info  [calculate_weight_by_width $::inject_signals_netlist]
  }
}

##########################
#  Random Net Selection  #
##########################

proc select_random_net {} {
  # Choose between Register and Signal
  if {[llength $::inject_register_netlist] != 0 && \
     ([llength $::inject_signals_netlist] == 0 || \
      rand() * ($::reg_to_sig_ratio + 1) >= 1)} {
    set is_register 1
    set selected_list $::inject_register_netlist
  } else {
    set is_register 0
    set selected_list $::inject_signals_netlist
  }
  # Select the distribution
  if {$::use_bitwidth_as_weight} {
    # select the distribution
    if {$is_register} {
      set distibrution_info $::inject_register_distibrution_info
    } else {
      set distibrution_info $::inject_signals_distibrution_info
    }
    # unpack the distribution
    set distribution_total_weight [lindex $distibrution_info 0]
    set distribution_weight_dict  [lindex $distibrution_info 1]
    set distribution_net_dict     [lindex $distibrution_info 2]
    # determine the group
    set selec [expr rand() * $distribution_total_weight]
    dict for {group group_weight} $distribution_weight_dict {
      if {$group_weight <= $selec} {
        break
      } else {
        set selec [expr $selec - $group_weight]
      }
    }
    set selected_list [dict get $distribution_net_dict $group]
  }
  set idx [expr int(rand()*[llength $selected_list])]
  set selected_net [lindex $selected_list $idx]
  return [list $selected_net $is_register]
}

################
#  Flip a Bit  #
################

# flip a spefific bit of the given net name. returns a 1 if the bit could be flipped
proc flipbit {signal_name is_register} {
  set success 0
  set old_value [examine -radixenumsymbolic $signal_name]
  # check if net is an enum
  if {[examine -radixenumnumeric $signal_name] != [examine -radixenumsymbolic $signal_name]} {
    set old_value_numeric [examine -radix binary,enumnumeric $signal_name]
    set new_value_numeric [expr int(rand()*([expr 2 ** [string length $old_value_numeric]]))]
    while {$old_value_numeric == $new_value_numeric && [string length $old_value_numeric] != 1} {
      set new_value_numeric [expr int(rand()*([expr 2 ** [string length $old_value_numeric]]))]
    }
    if {$is_register} {
      force -freeze $signal_name $new_value_numeric -cancel $::register_fault_duration
    } else {
      force -freeze $signal_name $new_value_numeric, $old_value_numeric $::signal_fault_duration -cancel $::signal_fault_duration
    }
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
    if {$is_register} {
      force -freeze $flip_signal_name $new_bit_value -cancel $::register_fault_duration
    } else {
      force -freeze $flip_signal_name $new_bit_value, $old_bit_value $::signal_fault_duration -cancel $::signal_fault_duration
    }
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
if {$log_injections} {
  set time_stamp [exec date +%Y%m%d_%H%M%S]
  set injection_log [open "fault_injection_$time_stamp.log" w+]
  puts $injection_log "timestamp,netname,pre_flip_value,post_flip_value,output_changed,new_state_changed"
}

# Update the inject netlist
updated_inject_netlist

# start fault injection
when -label inject_start "\$now == $inject_start_time" {
  if {$verbosity >= 1} {
    echo "$inject_start_time: \[Fault Injection\] Starting fault injection."
  }
  foreach assertion $assertion_disable_list {
    assertion enable -off $assertion
  }
}

# Dictionary to keep track of injections
set inject_dict [dict create]

# determine the phase for the initial fault injection
if {$rand_initial_injection_phase} {
  set prescaler [expr int(rand() * $fault_period)]
} else {
  set prescaler [expr $fault_period - 1]
}

# periodically inject faults
when -label inject_fault "\$now >= $inject_start_time and $injection_clock == $injection_clock_trigger" {
  incr prescaler
  if {$prescaler == $fault_period && \
      ([llength $inject_register_netlist] != 0 || \
       [llength $inject_signals_netlist] != 0) && \
      ($max_num_fault_inject == 0 || \
      $stat_num_bitflips < $max_num_fault_inject)} {
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
      set net_selc_info [select_random_net]
      set net_to_flip [lindex $net_selc_info 0]
      set is_register [lindex $net_selc_info 1]
      # Check if the selected net is allowed to be flipped
      set allow_flip 1
      if {$is_register && !$allow_multi_bit_upset} {
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
        set flip_return [flipbit $net_to_flip $is_register]
        if {[lindex $flip_return 0]} {
          set success 1
          if {$is_register && !$allow_multi_bit_upset} {
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
      if {$log_injections} {
        puts $injection_log "$now,$net_to_flip,[lindex $flip_return 1],[lindex $flip_return 2],$output_changed,$new_state_changed"
        flush $injection_log
      }
    }
  }
}

# stop the simulation and output statistics
when -label inject_stop "\$now >= $inject_stop_time" {
  if { $inject_stop_time != 0 } {
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
    if {$log_injections} {
      close $injection_log
    }
  }
}

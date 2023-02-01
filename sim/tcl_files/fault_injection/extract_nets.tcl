# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Luca Rufer (lrufer@student.ethz.ch)

# Description: This file provides some generic procs to extract next from a
#              circuit.

# ================================= Overview ==================================
# ----------------------- General Netlist utility procs -----------------------
# 'get_net_type'           : Get the type of a Net using the describe command.
#                            Example return type are "Register", "Net", "Enum",
#                            "Array", "Record" (struct), and others
# 'get_net_array_length'   : Get the length of an Array using the describe
#                            command.
# 'get_net_reg_width'      : Get the width (number of bits) of a Register or
#                            Net using the describe command
# 'get_record_field_names' : Get the names of all fiels of a Record (struct).
# ------------------------- Netlist Extraction procs --------------------------
# 'get_state_netlist'      : Example function for how to extract state nets.
#                            Non-recursive implementation.
# 'get_state_netlist_revursive' : Example function for how to extract state nets
#                            Recursive implementation.
# 'get_next_state_netlist' : Example function for how to extract next state
#                            nets. Non-recursive implementation.
# 'get_next_state_netlist_recursive' : Example function for how to extract
#                            next state nets. Recursive implementation.
# 'get_output_netlist'     : Example function for how to extract output nets
#                            of a circuit.
# 'extract_netlists'       : Given a list of nets obtained e.g. from the 'find'
#                            command, recursively extract signals until only
#                            signals of type "Register", "Net" and "Enum"
#                            remain.
# 'extract_all_nets_recursive_filtered' : Extract all nets from a circuit,
#                            filter them using the given patterns, and
#                            recursively extract them using 'extract_netlists'.

##################################
#  Net extraction utility procs  #
##################################

proc get_net_type {signal_name} {
  set sig_description [examine -describe $signal_name]
  set type_string [string trim [string range $sig_description 1 [string wordend $sig_description 1]] " \n\r()\[\]{}"]
  if { $type_string == "Verilog" } { set type_string "Enum"}
  return $type_string
}

proc get_net_array_length {signal_name} {
  set sig_description [examine -describe $signal_name]
  regexp "\\\[length (\\d+)\\\]" $sig_description -> match
  return $match
}

proc get_net_reg_width {signal_name} {
  set sig_description [examine -describe $signal_name]
  set length 1
  if {[regexp "\\\[(\\d+):(\\d+)\\\]" $sig_description -> up_lim low_lim]} {
    set length [expr $up_lim - $low_lim + 1]
  }
  return $length
}

proc get_record_field_names {signal_name} {
  set sig_description [examine -describe $signal_name]
  set matches [regexp -all -inline "Element #\\d* \"\[a-zA-Z_\]\[a-zA-Z0-9_\]*\"" $sig_description]
  set field_names {}
  foreach match $matches { lappend field_names [lindex [split $match \"] 1] }
  return $field_names
}

###########################################
#  Recursevely extract all nets and enums #
###########################################

proc extract_netlists {item_list} {
  set extract_list [list]
  foreach item $item_list {
    set item_type [get_net_type $item]
    if {$item_type == "Register" || $item_type == "Net" || $item_type == "Enum"} {
      lappend extract_list $item
    } elseif { $item_type == "Array"} {
      set array_length [get_net_array_length $item]
      for {set i 0}  {$i < $array_length} {incr i} {
        set new_net "$item\[$i\]"
        set extract_list [concat $extract_list [extract_netlists $new_net]]
      }
    } elseif { $item_type == "Record"} {
      set fields [get_record_field_names $item]
      foreach field $fields {
        set new_net $item.$field
        set extract_list [concat $extract_list [extract_netlists $new_net]]
      }
    } elseif { $item_type == "int"} {
      # Ignore
    } else {
      if { $::verbosity >= 2 } {
        echo "\[Fault Injection\] Unknown Type $item_type of net $item. Skipping..."
      }
    }
  }
  return $extract_list
}

####################
#  State Netlists  #
####################

# Example proc on how to extract state nets (not recursive)
# This is not guaranteed to work for every circuit, as net may not be named
# according to conventions!
proc get_state_netlist {base_path} {
  return [extract_netlists [find signal $base_path/*_q]]
}

# Example proc on how to extract state nets.
# This is not guaranteed to work for every circuit, as net may not be named
# according to conventions!
proc get_state_netlist_revursive {base_path} {
  return [extract_netlists [find signal -r $base_path/*_q]]
}

#####################
#  Next State Nets  #
#####################

# Example proc on how to extract next state nets (not recursive).
# This is not guaranteed to work for every circuit, as net may not be named
# according to conventions!
proc get_next_state_netlist {base_path} {
  return [find signal $base_path/*_d]
}

# Example proc on how to extract next state nets.
# This is not guaranteed to work for every circuit, as net may not be named
# according to conventions!
proc get_next_state_netlist_recursive {base_path} {
  return [find signal -r $base_path/*_d]
}

#########################
#  Circuit Output Nets  #
#########################

proc get_output_netlist {base_path} {
  return [find signal -out $base_path/*]
}

##################
#  Get all nets  #
##################

proc extract_all_nets_recursive_filtered {base_path filter_list} {

  # recursively extract all signals from the circuit
  set netlist [find signal -r $base_path/*];

  # filter and sort the signals
  set netlist_filtered [list];
  foreach net $netlist {
    set ignore_net 0
    # ignore any net that matches any ignore pattern
    foreach ignore_pattern $filter_list {
      if {[string match $ignore_pattern $net]} {
        set ignore_net 1
        break
      }
    }
    # add all nets that are not ignored
    if {$ignore_net == 0} {
      lappend netlist_filtered $net
    }
  }

  # sort the filtered nets alphabetically
  set netlist_filtered [lsort -dictionary $netlist_filtered]

  # recursively extract all nets and enums from arrays and structs
  set netlist_extracted [extract_netlists $netlist_filtered]

  return $netlist_extracted
}

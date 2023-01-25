# Copyright 2021 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Luca Rufer (lrufer@student.ethz.ch)

# Description: This file is used to extract specific groups of nets from
#              Mempool, that can be used in a fault injection script


# == Base Path for the Simulations ==
# proc base_path {group tile core} {return "/mempool_tb/dut/i_mempool_cluster/gen_groups\[$group\]/i_group/gen_tiles\[$tile\]/i_tile/gen_cores\[$core\]/gen_mempool_cc/riscv_core/i_snitch"}
proc base_path {core} {return "/tb_pulp/i_dut/cluster_domain_i/cluster_i/CORE\[$core\]/core_region_i"} 

# == Determine the snitch core parameters ==
# set is_dmr_enabled [examine -radix dec /snitch_dmr_pkg::DualModularRedundancy]
# set is_ecc_enabled [examine -radix binary [base_path 0 0 0]/EnableECCReg]

# == Nets to ignore for transient bit flips ==
# nets used for debugging
lappend core_netlist_ignore *gen_stack_overflow_check*
# nets that would crash the simulation if flipped
lappend core_netlist_ignore *dmr*
lappend core_netlist_ignore *hart_id*
lappend core_netlist_ignore *clk_i
lappend core_netlist_ignore *rst_ni
lappend core_netlist_ignore *rst_i
lappend core_netlist_ignore *rst
# registers/memories
lappend core_netlist_ignore *mem
lappend core_netlist_ignore *_q
# Others
# - none -

####################
#  State Netlists  #
####################

proc get_protected_master_state_netlist {group tile core} {
  if {$core % 2 != 0} {
    throw {CORE SEL} {Core $group $tile $core is not a Master.}
  }
  set base [base_path $group $tile $core]
  set netlist [list]
  # Snitch state
  if {$::is_dmr_enabled} {
    lappend netlist $base/DMR_state/mst/i_pc/data_q
    lappend netlist $base/DMR_state/mst/i_wfi/data_q
    lappend netlist $base/DMR_state/mst/i_wake_up/data_q
    lappend netlist $base/DMR_state/mst/i_sb/data_q
  } elseif {$::is_ecc_enabled} {
    lappend netlist $base/state/TMR/i_pc/data_q
    lappend netlist $base/state/TMR/i_wfi/data_q
    lappend netlist $base/state/TMR/i_wake_up/data_q
    lappend netlist $base/state/TMR/i_sb/data_q
  }
  return $netlist
}

proc get_protected_slave_state_netlist {group tile core} {
  if {$core % 2 != 1} {
    throw {CORE SEL} {Core $group $tile $core is not a slave.}
  }
  set base [base_path $group $tile $core]
  set netlist [list]
  # Snitch state
  if {$::is_ecc_enabled} {
    if {$::is_dmr_enabled} {
      lappend netlist $base/DMR_state/slv/TMR/i_pc/data_q
      lappend netlist $base/DMR_state/slv/TMR/i_wfi/data_q
      lappend netlist $base/DMR_state/slv/TMR/i_wake_up/data_q
      lappend netlist $base/DMR_state/slv/TMR/i_sb/data_q
    } else {
      lappend netlist $base/state/TMR/i_pc/data_q
      lappend netlist $base/state/TMR/i_wfi/data_q
      lappend netlist $base/state/TMR/i_wake_up/data_q
      lappend netlist $base/state/TMR/i_sb/data_q
    }
  }
  return $netlist
}

proc get_unprotected_master_state_netlist {group tile core} {
  if {$core % 2 != 0} {
    throw {CORE SEL} {Core $group $tile $core is not a Master.}
  }
  set base [base_path $group $tile $core]
  set netlist [list]
  # Snitch state
  if {!$::is_dmr_enabled && !$::is_ecc_enabled} {
    lappend netlist $base/pc_q
    lappend netlist $base/wfi_q
    lappend netlist $base/wake_up_q
    lappend netlist $base/sb_q
  }
  return $netlist
}

proc get_unprotected_slave_state_netlist {group tile core} {
  if {$core % 2 != 1} {
    throw {CORE SEL} {Core $group $tile $core is not a slave.}
  }
  set base [base_path $group $tile $core]
  set netlist [list]
  # Snitch state
  if {!$::is_ecc_enabled} {
    if {$::is_dmr_enabled} {
      lappend netlist $base/DMR_state/slv/pc_qq
      lappend netlist $base/DMR_state/slv/wfi_qq
      lappend netlist $base/DMR_state/slv/wake_up_qq
      lappend netlist $base/DMR_state/slv/sb_qq
    } else {
      lappend netlist $base/pc_q
      lappend netlist $base/wfi_q
      lappend netlist $base/wake_up_q
      lappend netlist $base/sb_q
    }
  }
  return $netlist
}

proc get_slave_state_netlist {group tile core} {
  if {$core % 2 != 1} {
    throw {CORE SEL} {Core $group $tile $core is not a slave.}
  }
  set protected_netlist [get_protected_slave_state_netlist $group $tile $core]
  set unprotected_netlist [get_unprotected_slave_state_netlist $group $tile $core]
  return [concat $protected_netlist $unprotected_netlist]
}

proc get_master_state_netlist {group tile core} {
  if {$core % 2 != 0} {
    throw {CORE SEL} {Core $group $tile $core is not a master.}
  }
  set protected_netlist [get_protected_master_state_netlist $group $tile $core]
  set unprotected_netlist [get_unprotected_master_state_netlist $group $tile $core]
  return [concat $protected_netlist $unprotected_netlist]
}

proc get_unprotected_state_netlist {group tile core} {
  if {$core % 2 == 0} {
    return [get_unprotected_master_state_netlist $group $tile $core]
  } else {
    return [get_unprotected_slave_state_netlist $group $tile $core]
  }
}

proc get_protected_state_netlist {group tile core} {
  if {$core % 2 == 0} {
    return [get_protected_master_state_netlist $group $tile $core]
  } else {
    return [get_protected_slave_state_netlist $group $tile $core]
  }
}

proc get_state_netlist {group tile core} {
  if {$core % 2 == 0} {
    return [get_master_state_netlist $group $tile $core]
  } else {
    return [get_slave_state_netlist $group $tile $core]
  }
}

proc get_protected_regfile_mem_netlist {group tile core} {
  set base [base_path $group $tile $core]
  set netlist [list]
  if {$core % 2 == 0} {
    # Protected Master
    if {$::is_dmr_enabled} {
      for {set i 0} {$i < 32} {incr i} {
        lappend netlist $base/gen_dmr_master_regfile/i_snitch_regfile/mem\[$i\]
      }
    } elseif {$::is_ecc_enabled} {
      for {set i 0} {$i < 32} {incr i} {
        lappend netlist $base/gen_regfile/ECC/i_snitch_regfile/mem\[$i\]
      }
    }
  } else {
    # Protected Slave
    if {$::is_ecc_enabled} {
      for {set i 0} {$i < 32} {incr i} {
        lappend netlist $base/gen_regfile/ECC/i_snitch_regfile/mem\[$i\]
      }
    }
  }
  return $netlist
}

proc get_unprotected_regfile_mem_netlist {group tile core} {
  set base [base_path $group $tile $core]
  set netlist [list]
  if {$::is_ecc_enabled || ($core % 2 == 0 && $::is_dmr_enabled)}{return $netlist}

  for {set i 0} {$i < 32} {incr i} {
    lappend netlist $base/gen_regfile/noECC/i_snitch_regfile/mem\[$i\]
  }
  
  return $netlist
}

proc lsu_is_dmr_master {group tile core} {
  set is_master 0
  if {$::is_dmr_enabled} {
    set base [base_path $group $tile $core]/gen_DMR_lsu/i_snitch_lsu
    set is_master [examine -radix decimal $base/IsDMRMaster]
  }
  return $is_master
}

proc get_protected_lsu_state_netlist {group tile core} {
  set base [base_path $group $tile $core]
  set netlist [list]
  if {$::is_dmr_enabled} {
    set NumOutstandingLoads [examine -radix decimal $base/gen_DMR_lsu/i_snitch_lsu/NumOutstandingLoads]
    if {[lsu_is_dmr_master $group $tile $core]} {
      lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/mst_state/i_id/data_q
      for {set i 0} {$i < $NumOutstandingLoads} {incr i} {
      lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/metadata_q\[$i\]
      }
    } else {
      if {$::is_ecc_enabled} {
        lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/slv_state/ECC/i_id/data_q
        for {set i 0} {$i < $NumOutstandingLoads} {incr i} {
          lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/metadata_q\[$i\]
        }
      }
    }
  } else {
    set NumOutstandingLoads [examine -radix decimal $base/gen_lsu/i_snitch_lsu/NumOutstandingLoads]
    if {$::is_ecc_enabled} {
      lappend netlist $base/gen_lsu/i_snitch_lsu/ECC/i_id/data_q
      for {set i 0} {$i < $NumOutstandingLoads} {incr i} {
        lappend netlist $base/gen_lsu/i_snitch_lsu/metadata_q\[$i\]
      }
    }
  }

  return $netlist
}

proc get_unprotected_lsu_state_netlist {group tile core} {
  set base [base_path $group $tile $core]
  set netlist [list]
  # LSU state
  if {$::is_dmr_enabled} {
    set NumOutstandingLoads [examine -radix decimal $base/gen_DMR_lsu/i_snitch_lsu/NumOutstandingLoads]
    if {![lsu_is_dmr_master $group $tile $core] && !$::is_ecc_enabled} {
      lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/id_available_q
      for {set i 0} {$i < $NumOutstandingLoads} {incr i} {
        lappend netlist $base/gen_DMR_lsu/i_snitch_lsu/metadata_q\[$i\]
      }
    }
  } else {
    set NumOutstandingLoads [examine -radix decimal $base/gen_lsu/i_snitch_lsu/NumOutstandingLoads]
    if {!$::is_ecc_enabled} {
      set lsu_netlist [find signal $base/gen_lsu/i_snitch_lsu/*_q]
      set netlist [concat $netlist $lsu_netlist]
    }
  }
  return $netlist
}

######################
#  Core Output Nets  #
######################

proc get_output_netlist {core} {
  return [find nets -out [base_path $core]/*]
  # return [find signal [base_path $group $tile $core]/*_o]
}

#####################
#  Next State Nets  #
#####################

proc get_next_state_netlist {group tile core} {
  set next_state_netlist [find signal -r [base_path $group $tile $core]/*_d]
  # Note: CSRs currently not included
  # Note: Regfile not included
  return $next_state_netlist
}

################
#  Assertions  #
################

proc get_assertions {group tile core} {
  set assertion_list [list]
  lappend assertion_list [base_path $group $tile $core]/InstructionInterfaceStable
  lappend assertion_list [base_path $group $tile $core]/**/i_snitch_lsu/invalid_resp_id
  lappend assertion_list [base_path $group $tile $core]/**/i_snitch_lsu/invalid_req_id
  return $assertion_list
}

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

##############################
#  Get all nets from a core  #
##############################

proc get_all_core_nets {core} {

  # Path of the core
  set core_path [base_path $core]/*

  # extract all signals from the core
  set core_netlist [find signal -r $core_path];

  # filter and sort the signals
  set core_netlist_filtered [list];
  foreach core_net $core_netlist {
    set ignore_net 0
    # ignore any net that matches any ignore pattern
    foreach ignore_pattern $::core_netlist_ignore {
      if {[string match $ignore_pattern $core_net]} {
        set ignore_net 1
      }
    }
    # add all nets that are not ignored
    if {$ignore_net == 0} {
      lappend core_netlist_filtered $core_net
    }
  }

  # sort the filtered nets alphabetically
  set core_netlist_filtered [lsort -dictionary $core_netlist_filtered]

  # recursively extract all nets and enums from arrays and structs
  set core_netlist_extracted [extract_netlists $core_netlist_filtered]

  return $core_netlist_extracted
}
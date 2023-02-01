# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Michael Rogenmoser (michaero@iis.ee.ethz.ch)

transcript quietly

set verbosity 3
set log_injections 1
set seed 12345

set inject_start_time 4500000ns
set inject_stop_time 0
set injection_clock "/tb_pulp/i_dut/cluster_domain_i/cluster_i/clk_cluster"
set injection_clock_trigger 0
set fault_period 10
set rand_initial_injection_phase 0
set max_num_fault_inject 1
set signal_fault_duration 20ns
set register_fault_duration 0ns

set allow_multi_bit_upset 1
set use_bitwidth_as_weight 1
set check_core_output_modification 0
set check_core_next_state_modification 0
set reg_to_sig_ratio 1

proc base_path {core} {return "/tb_pulp/i_dut/cluster_domain_i/cluster_i/CORE\[$core\]/core_region_i"} 

set inject_register_netlist []
set inject_signals_netlist [find nets -out [base_path 0]/*]
set output_netlist []
set next_state_netlist []
set assertion_disable_list []

source tcl_files/fault_injection/inject_fault.tcl


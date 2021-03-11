# check exit status in tb and quit the simulation accordingly
proc run_and_exit {} {
    onElabError {quit -code 1}
    onerror {quit -code 1}
    if {[catch {run -all} ]} {
      quit -code 1
    }
    quit -code [examine -radix decimal sim:/tb/tb_test_i/sim_manager_i/exit_status]
}


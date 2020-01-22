
#######################################
quietly set testname_uid "dummy_testname"

quietly set vsim_testname "dummy_testname"
if {[info exists ::env(PLPTEST_NAME)]} {
    quietly set vsim_testname $::env(PLPTEST_NAME)
    quietly regsub -all {\.} $vsim_testname _ testname_uid
}  {
  if {[info exists ::env(TESTNAME)]} {
    quietly set testname_uid "$::env(TESTNAME)"
  }
}
quietly set vsimcmd_testname "coverage attribute -test $testname_uid -name TESTNAME_PLP -value $vsim_testname"

# vsim UID testname
#+ if {[info exists ::env(PLPTEST_RUN_ID)]} {
#+   #+ quietly set testname_uid "$::env(PLPTEST_RUN_ID)"
#+ } {
#+ }
quietly set vsim_testname_uid "-testname $testname_uid"

quietly set vsim_test_path "dummy_testpath"
if {[info exists ::env(PLPTEST_PATH)]} {
    quietly set vsim_test_path $::env(PLPTEST_PATH)
} 
quietly set vsimcmd_test_path "coverage attribute -test $testname_uid -name TESTPATH -value $vsim_test_path"

# vsim coverage enable
quietly set vsim_cov ""
if {[info exists ::env(VSIM_COV)]} {
  if {$::env(VSIM_COV) == "YES"} {
    quietly set vsim_cov "-coverage -coverstore $GAP_PATH_TCL/fe/sim/cov $vsim_testname_uid"
    quietly set vopt_cov "+cover+pulp_chip."
    #+ quietly set vopt_cov "+cover+pulp_chip. -coveropt 1"
  } 
} 
#######################################
#######################################
# enable access control in vopt when vsim gui mode activated
quietly set vopt_acc_ena ""
if {[info exists ::env(VOPT_ACC_ENA)]} {
  if {$::env(VOPT_ACC_ENA) == "YES"} {
    quietly set vopt_acc_ena "YES"
  } 
} 

#######################################
# Enable DPI use in tb
#######################################
quietly set use_dev_dpi "-gENABLE_DEV_DPI=0"
if {[info exists ::env(PLP_DEVICES)]} {
  quietly set use_dev_dpi "-gENABLE_DEV_DPI=1"
} 

#######################################
# record wlf
quietly set vsim_record_wlf ""
if {[info exists ::env(RECORD_WLF)]} {
  if {$::env(RECORD_WLF) == "YES"} {
    # enable access control in vopt when recordwlf mode activated
    quietly set vopt_acc_ena "YES"
    quietly set vsim_record_wlf "-wlf \"gap.wlf\""
  } 
} 

# select do file for waveform selection
quietly set vsim_do_files ""
if {[info exists ::env(DO_FILES)]} {
    quietly set vsim_do_files $::env(DO_FILES)
} 
#######################################
#######################################
# UART tb or VIP select
quietly set uart_drv_mon ""
if {[info exists ::env(UART_DRV_MON)]} {
  if {$::env(UART_DRV_MON) == "VIP"} {
    quietly set uart_drv_mon "+uart_drv_mon=$::env(UART_DRV_MON)"
  } 
} 
#######################################

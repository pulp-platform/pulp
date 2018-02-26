#######################################
# Define vsim path and custom variables passed via make
if {[info exists ::env(VSIM_PATH)]} {
    quietly set VSIM_SCRIPTS_PATH $::env(VSIM_PATH)
} {
    quietly set VSIM_SCRIPTS_PATH ./
}

if {[info exists ::env(TB_PATH)]} {
    quietly set TB_PATH_TCL $::env(TB_PATH)
} {
    quietly set TB_PATH_TCL "$VSIM_SCRIPTS_PATH/../../fe/tb/"
}

if {[info exists ::env(VSIM_FLAGS)]} {
    quietly set VSIM_FLAGS_TCL $::env(VSIM_FLAGS)
} {
    quietly set VSIM_FLAGS_TCL ""
}

if {[info exists ::env(VSIM_RUNNER_FLAGS)]} {
    quietly set VSIM_FLAGS_TCL "$VSIM_FLAGS_TCL $::env(VSIM_RUNNER_FLAGS)"
}

quietly set VSIM_TB_PATH $VSIM_SCRIPTS_PATH/../tb
#######################################
#######################################
quietly source $VSIM_SCRIPTS_PATH/tcl_files/config/vsim_ips.tcl

quietly source $VSIM_SCRIPTS_PATH/tcl_files/config/vsim_sdvt.tcl
quietly source $VSIM_SCRIPTS_PATH/tcl_files/config/vsim_custom.tcl

quietly set design_libs "\
  "

set sdkLib ""

if {[info exists ::env(PULP_SDK_HOME)]} {
  if {[file exists $::env(PULP_SDK_HOME)/install/ws/lib/libdpimodels]} {
    set sdkLib "-sv_lib $::env(PULP_SDK_HOME)/install/ws/lib/libdpimodels $sdkLib"
  }
}

if {[info exists ::env(PULP_SIMCHECKER)]} {
  set sdkLib "-sv_lib $::env(PULP_SDK_HOME)/install/ws/lib/libri5cyv2sim $sdkLib"
}

quietly set warning_args "\
  +nowarnTRAN \
  +nowarnTSCALE \
  +nowarnTFMPC \
  "

quietly set define_args "\
  +TB_PATH=$TB_PATH_TCL \
  +UVM_NO_RELNOTES \
  "

quietly set common_args "\
  $design_libs \
  $warning_args \
  $define_args \
  "

quietly set custom_args "\
  $VSIM_FLAGS_TCL \
  $uart_drv_mon \
  $use_dev_dpi \
  $sdkLib \
  "

quietly set common_sdvt_args "\
  $sdvt_debug_level \
  $use_sdvt_cpi \
  $sdvt_cpi_test \
  $sdvt_cpi_cmds \
  $sdvt_cpi_checker_ena \
  $sdvt_cpi_hres \
  $sdvt_cpi_vres \
  $use_sdvt_i2s \
  $sdvt_i2s_test \
  $sdvt_i2s_cmds \
  $use_sdvt_spi \
  $sdvt_spi_test \
  $sdvt_spi_cmds \
  "

quietly set vsim_custom_args "\
  $vsim_record_wlf \
  $vsim_do_files \
  $use_sdvt \
  +VSIM_PATH=$::env(VSIM_PATH) \
  "

quietly set vopt_args ""
if {$vopt_acc_ena == "YES"} {
  #+ quietly append vopt_args $vopt_args "+acc=abflmnprstv"
  quietly append vopt_args $vopt_args "+acc=mnprv \
                                       -assertdebug \
                                       -bitscalars \
                                       -fsmdebug \
                                       -linedebug"
}
if {[info exists vopt_cov]} {
  quietly append vopt_args $vopt_args $vopt_cov
}
if {$vopt_args != ""} {
  quietly set vsim_vopt_args "-voptargs=\"$vopt_args\""
} {
  quietly set vsim_vopt_args ""
}

quietly set vopt_cmd "vopt -quiet tb \
              $common_args \
              $custom_args \
              $common_sdvt_args \
              $vopt_args \
              -o pulp_opt -work work"

if {[info exists ::env(VOPT_FLOW)]} {
    onElabError {quit -code 1}
    onerror {quit -code 1}
    quietly eval $vopt_cmd
    quietly eval "quit"


} {
  set vsim_cmd "vsim -c -quiet $TB \
                -t ps \
                $vsim_cov \
                $common_args \
                $custom_args \
                $common_sdvt_args \
                $vsim_custom_args \
                $vsim_vopt_args \
                "

    eval $vsim_cmd
    eval $vsimcmd_test_path
    eval $vsimcmd_testname

    # Added these variables to avoid dummy warnings in the FLL
    set StdArithNoWarnings 1
    set NumericStdNoWarnings 1

    # check exit status in tb and quit the simulation accordingly
    proc run_and_exit {} {
        run -all
	if {[info exists ::env(VSIM_EXIT_SIGNAL)]} {
	    quit -code [examine -radix decimal sim:$::env(VSIM_EXIT_SIGNAL)]
	} else {
	    quit -code [examine -radix decimal sim:/tb_pulp/exit_status]
	}
    }

    #+ set StdArithNoWarnings 1
    #+ set NumericStdNoWarnings 1
    #+ run 1ps
    #+ set StdArithNoWarnings 0
    #+ set NumericStdNoWarnings 0
}

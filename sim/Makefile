.PHONY: build lib clean sim simc

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

QOPT ?= qopt
QSIM ?= qsim
Q1VE ?= q1ve --qverify

VOPT				?= vopt
VSIM				?= vsim
VLIB				?= vlib
VMAP				?= vmap
VSIM_FLAGS  = -gUSE_SDVT_SPI=0 -gUSE_SDVT_CPI=0 -gBAUDRATE=115200 \
		-gENABLE_DEV_DPI=0 -gLOAD_L2=JTAG -gUSE_SDVT_I2S=0

SVLIB	    =  ../rtl/tb/remote_bitbang/librbs

top_level ?= pulp

all: clean build opt

all_qone: clean build_qone opt_qone

# build the bitbang library, needed for simulating a jtag bridge to OpenOCD
build-deps:
	$(MAKE) -C ../rtl/tb/remote_bitbang all

clean-deps:
	$(MAKE) -C ../rtl/tb/remote_bitbang clean

sim_qone:
	$(QSIM) -qwavedb=+signal+memory -64 -gui vopt_tb -L models_lib -L vip_lib \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1"

sim:
	$(VSIM) -64 -gui vopt_tb -L models_lib -L vip_lib \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1"

simc:
	$(VSIM) -64 -c vopt_tb -L models_lib -L vip_lib \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" \
		-do "run -all" \
		-do "quit -code [examine -radix decimal sim:/tb_pulp/exit_status]"

opt_qone:
ifndef IPAPPROX
	$(QOPT) -debug,livesim +designfile tb_pulp -o vopt_tb -work work
else
	$(mkfile_path)/tcl_files/rtl_vopt.tcl
endif

opt:
ifndef IPAPPROX
	$(VOPT) +acc=npr tb_pulp -o vopt_tb -work work
else
	$(mkfile_path)/tcl_files/rtl_vopt.tcl
endif

build_qone:
# build-deps
ifndef IPAPPROX
	$(QSIM) -c -do 'source compile.tcl; quit'
else
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build
endif

build:
# build-deps
ifndef IPAPPROX
	$(VSIM) -c -do 'source compile.tcl; quit'
else
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build
endif

lib:
ifndef IPAPPROX
	@$(VLIB) work
# @chmod +w modelsim.ini
	$(VMAP) work $(mkfile_path)/work
else
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk lib
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk lib
endif

clean:
# clean-deps
ifndef IPAPPROX
	@mkdir -p work
	rm -r work 
else
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk clean
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean
endif
# @touch modelsim.ini
# @chmod +w modelsim.ini
# rm modelsim.ini

$(library):
	$(QUESTA) vlib $(library)

compile_lint: $(library)
	$(Q1VE) -od lint/comp_lint_results -c -do " \
	onerror {exit}; \
	do compile_lint.tcl; \
	exit"
lint: compile_lint
	$(Q1VE) -od lint/lint_results -c -do " \
	lint methodology ip -goal release; \
	lint run -d $(top_level); \
	exit"


# split rule in different .tcl files
# add configure message suppress -type generic
# sdc preference -infer_false_path_domains for false paths in sdc
# remove multi_fanout_async for now -> until sdc is cleaned
cdc: compile_lint
	$(Q1VE) -od cdc_results -c -do " \
	sdc preference -sta_mode; \
	sdc load timing.sdc; \
	cdc preference -multi_fanout_async; \
	cdc run -d $(top_level); \
	exit"

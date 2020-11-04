.PHONY: build lib clean sim simc

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

VSIM        ?= vsim
VSIM_FLAGS  = -gUSE_SDVT_SPI=0 -gUSE_SDVT_CPI=0 -gBAUDRATE=115200 \
		-gENABLE_DEV_DPI=0 -gLOAD_L2=JTAG -gUSE_SDVT_I2S=0

SVLIB	    =  ../../rtl/tb/remote_bitbang/librbs

PULP_CLUSTER_NETLIST  = ../pulp_cluster/pulp_cluster_postsynt.v
PULPEMU_TIME_NETLIST  = ../pulpemu/pulpemu_timesim.v
PULPEMU_FUNC_NETLIST  = ../pulpemu/pulpemu_funcsim.v

all: clean lib build opt

sim:
	$(VSIM) -64 -gui vopt_tb -L models_lib -L vip_lib \
		-suppress vsim-3009 -suppress vsim-8683 \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1"

simc:
	$(VSIM) -64 -c vopt_tb -L models_lib -L vip_lib \
		-suppress vsim-3009 -suppress vsim-8683 \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" \
		-do "run -all" \
		-do "quit -code [examine -radix decimal sim:/tb_pulp/exit_status]"

opt:
	$(mkfile_path)/tcl_files/rtl_vopt.tcl

build:
	@make --no-print-directory -f $(mkfile_path)/vcompile/fpga.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build

build_fpga_pulp_cluster:
	@if [ ! -f $(PULP_CLUSTER_NETLIST) ]; then\
	  echo "Can not find $(PULP_CLUSTER_NETLIST)! Please go to ../pulp_cluster and execute <python postsynth_names.py> to get netlist!";\
	fi
	@make --no-print-directory -f $(mkfile_path)/vcompile/fpga.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build
	@vlog -quiet +define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583 -suppress 13314 -work modelsim_libs/pulp_cluster_lib $(PULP_CLUSTER_NETLIST)
	@vlog -quiet -sv +incdir+../../rtl/includes +define+USE_CLUSTER_NETLIST \
	 +define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583 -suppress 13314 \
	-work modelsim_libs/pulp_lib ../../rtl/pulp/cluster_domain.sv

build_fpga_pulpemu_function:
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl/vip.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl/tb.mk USE_NETLIST=1 build
	@vlog -quiet -work modelsim_libs/pulpemu_lib $(PULPEMU_FUNC_NETLIST)

build_fpga_pulpemu_timing:
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl/vip.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/tb.mk USE_NETLIST=1 build
	@vlog -quiet -work modelsim_libs/pulpemu_lib $(PULPEMU_TIME_NETLIST)

lib:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk lib
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk lib

xilinx:
	vmap secureip xilinx_libs/secureip
	vmap simprims_ver xilinx_libs/simprims_ver
	vmap unifast xilinx_libs/unifast
	vmap unifast_ver xilinx_libs/unifast_ver
	vmap unimacro_ver xilinx_libs/unimacro_ver
	vmap unisim xilinx_libs/unisim
	vmap unisims_ver xilinx_libs/unisims_ver
	vmap unimacro xilinx_libs/unimacro
	vmap work modelsim_libs/work

clean:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk clean
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean

.PHONY: build lib clean

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

all: clean lib build opt
sim:
	vsim -lib modelsim_libs/work vopt_tb -do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" +UVM_NO_RELNOTES

simc:
	vsim -c -lib modelsim_libs/work vopt_tb -c -suppress vsim-3009 -suppress vsim-8683 -do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" +UVM_NO_RELNOTES

opt:
	$(mkfile_path)/tcl_files/rtl_vopt.tcl

build:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build

lib:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk lib
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk lib

clean:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk clean
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean


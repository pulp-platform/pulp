ifdef BOARD
	include ../pulp-$(BOARD)/fpga-settings.mk
endif

PROJECT:=pulp-$(BOARD)
VIVADO ?= vivado

.DEFAULT_GOAL:=help

.PHONY: help all gui ips clean-ips clk clean-clk clean vio clean-vio

all: ips ## Generate the bitstream for pulpissimo with vivado in batch mode. The vivado invocation command may be overriden with the env variable VIVADO.
	$(VIVADO) -mode batch -source tcl/run.tcl

elaborate: ips
	$(VIVADO) -mode batch -source tcl/run_elaboration.tcl

gui: ips ## Generates the bitstream for pulpissimo with vivado in GUI mode. The vivado invocation command may be overriden with the env variable VIVADO.
	$(VIVADO) -mode gui -source tcl/run.tcl &

ips: clk vio ## Synthesizes necessary xilinx and vio IPs

clean-ips: clean-clk clean-vio ## Clean all IPs

clk: ## Synthesizes the Xilinx Clocking Manager IPs
	$(MAKE) -C ips/xilinx_clk_mngr all BOARD=$(BOARD)
	$(MAKE) -C ips/xilinx_slow_clk_mngr all BOARD=$(BOARD)
	$(MAKE) -C ips/xilinx_clk_wiz all BOARD=$(BOARD)

clean-clk: ## Removes all Clocking Wizard IP outputs
	$(MAKE) -C ips/xilinx_clk_mngr clean
	$(MAKE) -C ips/xilinx_slow_clk_mngr clean

vio: ## Synthesizes the vio IP
	$(MAKE) -C ips/vio all BOARD=$(BOARD)

clean-vio: ## Removes all VIO IP outputs
	$(MAKE) -C ips/vio clean

clean: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*)
	rm -rf ${PROJECT}.*[^'bit']
	rm -rf ${PROJECT}.*[^'bin']
	rm -rf *.log
	rm -rf vivado*
	rm -rf .Xil/*
	rm -rf reports/*

# download: ## Download the bitstream into the FPGA
# 	$(VIVADO) -mode batch -source tcl/download_bitstream.tcl -tclargs $(PROJECT).runs/impl_1/xilinx_pulp.bit pulp_$(BOARD).bit

help:
	@grep -E -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

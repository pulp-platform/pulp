PROJECT:=pulpissimo_genesys2
VIVADO ?= vivado
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl

include fpga-settings.mk

.DEFAULT_GOAL:=help

.PHONY: help all gui ips clean-ips clk clean-clk ram clean-ram clean

all: ips ## Generate the bitstream for pulpissimo with vivado in batch mode. The vivado invocation command may be overriden with the env variable VIVADO.
	$(VIVADO) -mode batch -source tcl/run.tcl

gui: ips ## Generates the bitstream for pulpissimo with vivado in GUI mode. The vivado invocation command may be overriden with the env variable VIVADO.
	$(VIVADO) -mode gui -source tcl/run.tcl &

ips: clk ram ## Synthesizes necessary xilinx IP

clean-ips: clean-clk clean-ram ## Clean all IPs

clk: ## Synthesizes the Xilinx Clocking Manager IPs
	cd ips/xilinx_clk_mngr; make all
	cd ips/xilinx_slow_clk_mngr; make all

clean-clk: ## Removes all Clocking Wizard IP outputs
	cd ips/xilinx_clk_mngr; make clean
	cd ips/xilinx_slow_clk_mngr; make clean

ram: ## Synthesizes the Xilinx Block Memory Generator IPs for PULPissimo's L2 Ram
	cd ips/xilinx_interleaved_ram; make all
	cd ips/xilinx_private_ram; make all

clean-ram: ## Removes all Block Ram IP outputs related to l2 ram
	cd ips/xilinx_interleaved_ram; make clean
	cd ips/xilinx_private_ram; make clean

clean: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*)
	rm -rf ${PROJECT}.*[^'bit']
	rm -rf ${PROJECT}.*[^'bin']
	rm -rf *.log
	rm -rf vivado*

help:
	@grep -E -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

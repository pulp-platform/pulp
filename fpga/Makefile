.DEFAULT_GOAL:=help
export BENDER

all: zcu102

clean_all: clean_ips clean_zcu102 clean_vcu118

zcu102: ## Generates the bistream for the zcu102 board
ifdef gui
	$(MAKE) -C pulp gui BOARD=zcu102
else
	$(MAKE) -C pulp all BOARD=zcu102
	cp pulp/pulp-zcu102.runs/impl_1/xilinx_pulp.bit pulp_zcu102.bit
	cp pulp/pulp-zcu102.runs/impl_1/xilinx_pulp.bin pulp_zcu102.bin
	@echo "Bitstream generation for zcu102 board finished. The bitstream Configuration Memory File was copied to ./pulp_zcu102.bit and ./pulp_zcu102.bin"
endif

flash_zcu102: ## flashes the ZCU102 bitstream to the board.
	$(MAKE) -C pulp flash BOARD=zcu102

clean_zcu102: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the zcu102 board.
	$(MAKE) -C pulp clean BOARD=zcu102
	rm -f pulp_zcu102.bit
	rm -f pulp_zcu102.bin

vcu118: ## Generates the bitstream for the vcu118 board
ifdef gui
	$(MAKE) -C pulp gui BOARD=vcu118
else
	$(MAKE) -C pulp all BOARD=vcu118
	cp pulp/pulp-vcu118.runs/impl_1/xilinx_pulp.bit pulp_vcu118.bit
	cp pulp/pulp-vcu118.runs/impl_1/xilinx_pulp.bin pulp_vcu118.bin
	@echo "Bitstream generation for vcu118 board finished. The bitstream Configuration Memory File was copied to ./pulp_vcu118.bit and ./pulp_vcu118.bin"
endif

flash_vcu118: ## flashes the VCU118 bitstream to the board.
	$(MAKE) -C pulp flash BOARD=vcu118

clean_vcu118: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the vcu118 board.
	$(MAKE) -C pulp clean BOARD=vcu118
	rm -f pulp_vcu118.bit
	rm -f pulp_vcu118.bin

clean_ips: ## Cleans the generated IPs
	$(MAKE) -C pulp clean-ips BOARD=zcu102

help: ## Show help message
	@echo "PULP on FPGA"
	@echo ""
	@echo "Call make with one of the supported FPGA boards as arguments to generate the bitstream in the corresponding folder. "
	@echo "E.g. 'make zcu102' to generate the bitstream for the zcu102 board in pulp-zcu102 subdirectory."
	@echo "By default make invokes 'vivado'  to start Xilinx Vivado. This behaviour can be overriden by setting the make variable 'VIVADO'"
	@echo "e.g. make zcu102 VIVADO='vivado-2018.3 vivado' for ETH centos machines."
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

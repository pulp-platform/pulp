.DEFAULT_GOAL:=help

all: genesys2 zcu104 nexys_video ## Generates the bitstream for all supported boards board.

clean_all: clean_genesys2 clean_zcu104 clean_nexys_video ## Removes synthesis output and bitstreams for all boards.

genesys2: ## Generates the bistream for the genesys2 board
	cd pulpissimo-genesys2; make all
	cp pulpissimo-genesys2/pulpissimo_genesys2.runs/impl_1/xilinx_pulpissimo.bit pulpissimo_genesys2.bit
	cp pulpissimo-genesys2/pulpissimo_genesys2.runs/impl_1/xilinx_pulpissimo.bin pulpissimo_genesys2.bin
	@echo "Bitstream generation for genesys2 board finished. The bitstream Configuration Memory File was copied to ./pulpissimo_genesys2.bit and ./pulpissimo_genesys2.bin"

clean_genesys2: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the genesys2 board.
	cd pulpissimo-genesys2; make clean
	rm -f pulpissimo_genesys2.bit
	rm -f pulpissimo_genesys2.bin

zcu104: ## Generates the bistream for the zcu104 board
	cd pulpissimo-zcu104; make all
	cp pulpissimo-zcu104/pulpissimo_zcu104.runs/impl_1/xilinx_pulpissimo.bit pulpissimo_zcu104.bit
	cp pulpissimo-zcu104/pulpissimo_zcu104.runs/impl_1/xilinx_pulpissimo.bin pulpissimo_zcu104.bin
	@echo "Bitstream generation for zcu104 board finished. The bitstream Configuration Memory File was copied to ./pulpissimo_zcu104.bit and ./pulpissimo_zcu104.bin"

clean_zcu104: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the zcu104 board.
	cd pulpissimo-zcu104; make clean
	rm -f pulpissimo_zcu104.bit
	rm -f pulpissimo_zcu104.bin

nexys_video: ## Generates the bistream for the nexys_video board
	cd pulpissimo-nexys_video; make all
	cp pulpissimo-nexys_video/pulpissimo-nexys_video.runs/impl_1/xilinx_pulpissimo.bit pulpissimo_nexys_video.bit
	cp pulpissimo-nexys_video/pulpissimo-nexys_video.runs/impl_1/xilinx_pulpissimo.bin pulpissimo_nexys_video.bin
	@echo "Bitstream generation for nexys_video board finished. The bitstream Configuration Memory File was copied to ./pulpissimo_nexys_video.bit and ./pulpissimo_nexys_video.bin"

clean_nexys_video: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the nexys_video board.
	cd pulpissimo-nexys_video; make clean
	rm -f pulpissimo_nexys_video.bit
	rm -f pulpissimo_nexys_video.bin

help: ## Show this help message
	@echo "PULPissimo on FPGA"
	@echo ""
	@echo "Call make with one of the supported FPGA boards as arguments to generate the bitstream in the corresponding folder. "
	@echo "E.g. 'make genesys2' to generate the bitstream for the genesys2 board in pulpissimo-genesy2 subdirectory."
	@echo "By default make invokes 'vivado'  to start Xilinx Vivado. This behaviour can be overriden by setting the make variable 'VIVADO'"
	@echo "e.g. make genesys2 VIVADO='vivado-2018.3 vivado' for ETH centos machines."
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

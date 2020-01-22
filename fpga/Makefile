
include fpga-settings.mk

all: synth impl

gui:
	cd pulpemu; make clean-impl gui

impl:
	cd pulpemu; make clean-impl impl

ips: mem clk

mem:
	cd ips/xilinx_interleaved_ram; make clean all
	cd ips/xilinx_private_ram; make clean all
	cd ips/xilinx_rom_bank_2048x32; make clean all
	cd ips/xilinx_tcdm_bank_1024x32; make clean all

clk: ## Synthesizes the Xilinx Clocking Manager IPs
	cd ips/xilinx_clk_mngr; make clean all
	cd ips/xilinx_slow_clk_mngr; make clean all

synth: synth-ulpcluster synth-pulpemu

synth-ulpcluster:
	cd pulp_cluster; make clean all

synth-pulpemu:
	cd pulpemu; make clean all

cleanall: clean-ips clean-ulpcluster clean-pulpemu

clean-ulpcluster:
	cd pulp_cluster; make clean

clean-pulpemu:
	cd pulpemu; make clean

clean-ips:
	cd ips/xilinx_interleaved_ram; make clean
	cd ips/xilinx_private_ram; make clean
	cd ips/xilinx_rom_bank_2048x32; make clean
	cd ips/xilinx_tcdm_bank_1024x32; make clean
	cd ips/xilinx_clk_mngr; make clean

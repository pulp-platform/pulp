#
# Copyright (C) 2016 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=fpga
IP_PATH=../ips
LIB_NAME=fpga_lib

include vcompile/build.mk

vcompile-$(IP): $(LIB_PATH)/_vmake

$(LIB_PATH)/_vmake : | $(LIB_PATH)
	@make --no-print-directory -f vcompile/fpga.mk vcompile-subip-fpga-mem vcompile-subip-fpga-zynq

vcompile-subip-dummy:
	@touch $(LIB_PATH)/_vmake

vcompile-subip-fpga-mem: $(LIB_PATH)/fpga_mem.vmake

$(LIB_PATH)/fpga_mem.vmake:
	$(call subip_echo,fpga_mem)
	$(SVLOG_CC) -work $(LIB_PATH) ../ips/xilinx_clk_mngr/ip/xilinx_clk_mngr_sim_netlist.v
	$(SVLOG_CC) -work $(LIB_PATH) ../ips/xilinx_interleaved_ram/ip/xilinx_interleaved_ram_sim_netlist.v
	$(SVLOG_CC) -work $(LIB_PATH) ../ips/xilinx_private_ram/ip/xilinx_private_ram_sim_netlist.v
	$(SVLOG_CC) -work $(LIB_PATH) ../ips/xilinx_rom_bank_2048x32/ip/xilinx_rom_bank_2048x32_sim_netlist.v
	$(SVLOG_CC) -work $(LIB_PATH) ../ips/xilinx_tcdm_bank_1024x32/ip/xilinx_tcdm_bank_1024x32_sim_netlist.v
	@touch $(LIB_PATH)/fpga_mem.vmake

vcompile-subip-fpga-zynq: $(LIB_PATH)/fpga_zynq.vmake

$(LIB_PATH)/fpga_zynq.vmake:
	$(call subip_echo,fpga_zynq)
	$(SVLOG_CC) -work $(LIB_PATH) +define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583 -suppress 13314 +incdir+$(RTL_PATH)/includes ./misc/glbl.v
	@touch $(LIB_PATH)/fpga_zynq.vmake

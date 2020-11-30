#
# Copyright (C) 2016 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=tb
IP_PATH=$(RTL_PATH)/tb
LIB_NAME=$(IP)_lib

include vcompile/build.mk

.PHONY: vcompile-$(IP) vcompile-subip-tb 

vcompile-$(IP): $(LIB_PATH)/_vmake

$(LIB_PATH)/_vmake : $(LIB_PATH)/tb.vmake 
	@touch $(LIB_PATH)/_vmake

ifdef USE_NETLIST
$(info USE_NETLIST defined in tb)
DEF_MODEL_LEVEL=+define+USE_NETLIST
else
DEF_MODEL_LEVEL=
endif

SRC_SVLOG_TB=\
	$(IP_PATH)/../../ips/riscv-dbg/src/dm_pkg.sv\
	$(IP_PATH)/riscv_pkg.sv\
	$(IP_PATH)/jtag_pkg.sv\
	$(IP_PATH)/pulp_tap_pkg.sv\
	$(IP_PATH)/tb_clk_gen.sv\
	$(IP_PATH)/tb_fs_handler.sv\
	$(IP_PATH)/dpi_models/dpi_models.sv\
	$(IP_PATH)/tb_driver/tb_driver.sv\
	$(IP_PATH)/tb_pulp.sv\
	$(IP_PATH)/SimJTAG.sv\
	$(IP_PATH)/SimDTM.sv
SRC_VHDL_TB=

vcompile-subip-tb: $(LIB_PATH)/tb.vmake

$(LIB_PATH)/tb.vmake: $(SRC_SVLOG_TB) $(SRC_VHDL_TB)
	$(call subip_echo,tb)
	$(SVLOG_CC) -work $(LIB_PATH)  -L riscv_dbg_lib +define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583 $(INCDIR_TB) $(SRC_SVLOG_TB) ${DEF_MODEL_LEVEL}
	@touch $(LIB_PATH)/tb.vmake


#
# Copyright (C) 2015 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

# fix for colors on Ubuntu
SHELL=/bin/bash

# colors
Green=\e[0;92m
Yellow=\e[0;93m
Red=\e[0;91m
NC=\e[0;0m
Blue=\e[0;94m

# paths
VSIM_PATH?=.
PULP_PATH?=../..
MSIM_LIBS_PATH=$(VSIM_PATH)/modelsim_libs
IPS_PATH=../ips
RTL_PATH=../rtl
TB_PATH=../tb
LIB_PATH=$(MSIM_LIBS_PATH)/$(LIB_NAME)

# commands
ifndef VERBOSE
	LIB_CREATE=@vlib
	LIB_MAP=@vmap
	SVLOG_CC=@vlog -quiet -sv
	VLOG_CC=@vlog -quiet
	VHDL_CC=@vcom -quiet
	subip_echo=@echo -e "  $(NC)Building $(Yellow)$(IP)$(NC)/$(Yellow)$(1)$(NC)"
	ip_echo=@echo -e "$(Green)Built$(NC) $(Yellow)$(IP)$(NC)"
else
	LIB_CREATE=vlib
	LIB_MAP=vmap
	SVLOG_CC=vlog -quiet -sv
	VLOG_CC=vlog -quiet
	VHDL_CC=vcom -quiet
	subip_echo=@echo -e "\n$(NC)Building $(Yellow)$(IP)$(NC)/$(Yellow)$(1)$(NC)"
	ip_echo=@echo -e "\n$(Green)Built$(NC) $(Yellow)$(IP)$(NC)"
endif

# rules
.PHONY: build lib clean

build: vcompile-$(IP)
	@true

lib: $(LIB_PATH)

$(LIB_PATH): $(MSIM_LIBS_PATH)
	$(LIB_CREATE) $(LIB_PATH)
	$(LIB_MAP) $(LIB_NAME) $(LIB_PATH)

$(MSIM_LIBS_PATH):
	mkdir -p $(MSIM_LIBS_PATH)

clean:
	rm -rf $(LIB_PATH)

#
# Copyright (C) 2019 ETH Zurich, University of Bologna
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
VSIM_PATH?	=.
PULP_PATH?	=../..
NCSIM_LIBS_PATH	=$(VSIM_PATH)/ncsim_libs
IPS_PATH	=../ips
RTL_PATH	=../rtl
TB_PATH		=../tb
LIB_PATH	=$(NCSIM_LIBS_PATH)/$(LIB_NAME)

XRUN 		?= xrun

# commands
ifndef VERBOSE
	SVLOG_CC=$(XRUN) -64bit -sv -access +r -compile -nowarn NONPRT
	VLOG_CC=$(XRUN) -64bit -access +r -compile -nowarn NONPRT
	VHDL_CC=$(XRUN) -64bit -v93 -access +r -compile -nowarn NONPRT
	subip_echo=@echo -e "  $(NC)Building $(Yellow)$(IP)$(NC)/$(Yellow)$(1)$(NC)"
	ip_echo=@echo -e "$(Green)Built$(NC) $(Yellow)$(IP)$(NC)"
else
	SVLOG_CC=$(XRUN) -64bit -sv -access +r -compile -nowarn NONPRT
	VLOG_CC=$(XRUN) -64bit -access +r -compile -nowarn NONPRT
	VHDL_CC=$(XRUN) -64bit -v93 -access +r -compile -nowarn NONPRT
	subip_echo=@echo -e "\n$(NC)Building $(Yellow)$(IP)$(NC)/$(Yellow)$(1)$(NC)"
	ip_echo=@echo -e "\n$(Green)Built$(NC) $(Yellow)$(IP)$(NC)"
endif

# rules
.PHONY: build lib clean

build: ncompile-$(IP)
	@true

lib: $(LIB_PATH)

$(LIB_PATH): $(NCSIM_LIBS_PATH)
# $(LIB_CREATE) $(LIB_PATH)
# $(LIB_MAP) $(LIB_NAME) $(LIB_PATH)

$(NCSIM_LIBS_PATH):
	mkdir -p $(NCSIM_LIBS_PATH)

clean:
	rm -rf $(LIB_PATH)

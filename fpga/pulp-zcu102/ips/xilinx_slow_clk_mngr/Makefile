PROJECT:=xilinx_slow_clk_mngr
VIVADO ?= vivado
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl
MODE=batch

include ../../fpga-settings.mk

.DEFAULT_GOAL:=help

.PHONY: help all gui clean

all: MODE=batch ## Create and synthesize the IP in batch mode.

gui: MODE=gui  ## Create and synthesize the IP in GUI mode.

all gui: $(PROJECT).xpr

$(PROJECT).xpr: ../../fpga-settings.mk tcl/run.tcl
	$(MAKE) clean
	$(VIVADO) -mode $(MODE) -source tcl/run.tcl

clean: ## Remove all build products
	rm -rf ${PROJECT}.*
	rm -rf component.xml
	rm -rf vivado*.jou
	rm -rf vivado*.log
	rm -rf vivado*.str
	rm -rf xgui
	rm -rf .Xil

help: ## Shows this help message
	@grep -E -h '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

PROJECT:=xilinx_slow_clk_mngr
VIVADO ?= vivado
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl

.DEFAULT_GOAL:=help

.PHONY: help

all: ## Create and synthesize the IP in batch mode.
	$(VIVADO) -mode batch -source tcl/run.tcl
	mkdir -p ip
	cp -r ${PROJECT}.srcs/sources_1/ip/${PROJECT}/* ip/.
	cp ${PROJECT}.runs/${PROJECT}_synth_1/${PROJECT}.dcp ip/.

gui: ## Create and synthesize the IP in GUI mode.
	$(VIVADO) -mode gui -source tcl/run.tcl &

clean: ## Remove all build products
	rm -rf ip/*
	mkdir -p ip
	rm -rf ${PROJECT}.*
	rm -rf component.xml
	rm -rf vivado*.jou
	rm -rf vivado*.log
	rm -rf vivado*.str
	rm -rf xgui
	rm -rf .Xil

help: ## Shows this help message
	@grep -E -h '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

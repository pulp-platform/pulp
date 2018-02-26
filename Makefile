
SHELL=bash

sdk: pulp-tools
	 ./pulp-tools/bin/plpsdk src deps build --branch=integration --config=pulp --group runtime --group pkg
	 @echo "SDK has been successfully installed, now source this file before using it:"
	 @echo "  source setup/sdk.sh"

.PHONY: pulp-tools

pulp-tools:
	git submodule update --init

PKG_DIR ?= $(PWD)/install

export VSIM_PATH=$(PKG_DIR)
export PULP_PATH=$(PWD)

export MSIM_LIBS_PATH=$(VSIM_PATH)/modelsim_libs

export IPS_PATH=$(PULP_PATH)/fe/ips
export RTL_PATH=$(PULP_PATH)/fe/rtl
export TB_PATH=$(PULP_PATH)/rtl/tb

define declareInstallFile

$(VSIM_PATH)/$(1): sim/$(1)
	install -v -D sim/$(1) $$@

INSTALL_HEADERS += $(VSIM_PATH)/$(1)

endef

INSTALL_FILES += tcl_files/config/vsim_ips.tcl
INSTALL_FILES += modelsim.ini
INSTALL_FILES += $(shell cd sim && find boot -type f)
INSTALL_FILES += $(shell cd sim && find tcl_files -type f)
INSTALL_FILES += $(shell cd sim && find waves -type f)

$(foreach file, $(INSTALL_FILES), $(eval $(call declareInstallFile,$(file))))

BRANCH ?= master

checkout:
	git submodule update --init
	./update-ips

clean:
	rm -rf $(VSIM_PATH)
	cd sim && make clean

build:
	cd sim && make lib build opt
	cp -r rtl/tb/* $(VSIM_PATH)

install: $(INSTALL_HEADERS)

vopt:
	export VOPT_FLOW=1 && cd $(VSIM_PATH) && vsim -64 -c -do "source tcl_files/config/vsim.tcl; quit"

all: checkout build install vopt

test-checkout:
	./update-tests

test:
	source setup/sdk.sh && cd pulp-sdk && source init.sh && \
	  plpbuild --p tests test --threads 32 --db \
	    --db-info=$(CURDIR)/db_info.txt --stdout --branch=$(BRANCH) \
	    --env=quentin_validation --commit=`git rev-parse HEAD`

	source setup/sdk.sh && cd pulp-sdk && source init.sh && \
	  plpdb tests --build=`cat $(CURDIR)/db_info.txt | grep tests.build.id= | sed s/tests.build.id=//` \
	    --mail="Quentin regression report" --xls=report.xlsx --branch $(BRANCH) \
	    --config=$$PULP_CURRENT_CONFIG --url=$(BUILD_URL) \
	    --author-email=`git show -s --pretty=%ae` --env=quentin_validation && \
	  plpdb check_reg --build=`cat $(CURDIR)/db_info.txt | grep tests.build.id= | sed s/tests.build.id=//` \
	    --branch master --config=$$PULP_CURRENT_CONFIG --env=quentin_validation


SHELL=bash

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
	$(MAKE) -C rtl/tb/remote_bitbang clean
	rm -rf $(VSIM_PATH)
	cd sim && $(MAKE) clean

build:
	$(MAKE) -C rtl/tb/remote_bitbang all
	cd sim && $(MAKE) lib build opt
	cp -r rtl/tb/* $(VSIM_PATH)

install: $(INSTALL_HEADERS)

vopt:
	export VOPT_FLOW=1 && cd $(VSIM_PATH) && vsim -64 -c -do "source tcl_files/config/vsim.tcl; quit"

import_bootcode:
	cd sim/boot && objcopy --srec-len 1 --output-target=srec ${PULP_SDK_HOME}/install/bin/boot-pulpissimo boot-pulpissimo.s19
	cd sim/boot && s19toboot.py boot-pulpissimo.s19 pulpissimo

# This target is for continuous integration tests
sdk:
	if [ ! -e pulp-builder ]; then \
	  git clone https://github.com/pulp-platform/pulp-builder.git; \
	fi; \
	cd pulp-builder; \
	git checkout 7f26b4877f000940026788b4debbf89d86e18ff7; \
	. configs/pulpissimo.sh; \
	. configs/rtl.sh; \
	./scripts/clean; \
	./scripts/update-runtime; \
	./scripts/build-runtime; \
	./scripts/update-runner; \
	./scripts/build-runner;


all: checkout build install vopt sdk

test-checkout:
	./update-tests

test:
	cd pulp-builder; \
	. sdk-setup.sh; \
	. configs/pulpissimo.sh; \
	. configs/rtl.sh; \
	cd ..; \
	plptest --threads 16 --stdout

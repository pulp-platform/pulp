
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

# generic clean and build targets for the platform
clean:
	rm -rf $(VSIM_PATH)
	cd sim && $(MAKE) clean

build:
	cd sim && $(MAKE) lib build opt
	cp -r rtl/tb/* $(VSIM_PATH)

# sdk specific targets
install: $(INSTALL_HEADERS)

vopt:
	export VOPT_FLOW=1 && cd $(VSIM_PATH) && vsim -64 -c -do "source tcl_files/config/vsim.tcl; quit"

import_bootcode:
	cd sim/boot && objcopy --srec-len 1 --output-target=srec ${PULP_SDK_HOME}/install/bin/boot-pulpissimo boot-pulpissimo.s19
	cd sim/boot && s19toboot.py boot-pulpissimo.s19 pulpissimo

# JENKIN CI
# continuous integration on jenkins
all: checkout build install vopt sdk

sdk:
	if [ ! -e pulp-builder ]; then \
	  git clone --recurse https://github.com/pulp-platform/pulp-builder.git; \
	fi; \
	cd pulp-builder; \
	git checkout 83953d5ca4c545f4186bf3683d509566c3067012; \
	git checkout --recurse-submodules; \
	. configs/pulp.sh; \
	. configs/rtl.sh; \
	./scripts/clean; \
	./scripts/update-runtime; \
	./scripts/build-runtime; \
	./scripts/update-runner; \
	./scripts/build-runner;

test-checkout:
	./update-tests

test:
	cd pulp-builder; \
	. sdk-setup.sh; \
	. configs/pulp.sh; \
	. configs/rtl.sh; \
	cd ..; \
	cd tests && plptest --threads 16 --stdout

# GITLAB CI
# continuous integration on gitlab
sdk-gitlab:
	sdk-releases/get-sdk-2019.11.03-CentOS_7.py; \

# the gitlab runner needs a special configuration to be able to access the
# dependent git repositories
test-checkout-gitlab:
	./update-tests-gitlab

# test with sdk release
test-gitlab:
	source env/env-sdk-2019.11.03.sh; \
	source pkg/sdk/2019.11.03/configs/pulp.sh; \
	source pkg/sdk/2019.11.03/configs/platform-rtl.sh; \
	cd tests && plptest --threads 16 --stdout

# test with built sdk
test-gitlab2:
	cd pulp-builder; \
	source sdk-setup.sh; \
	source configs/pulp.sh; \
	source configs/rtl.sh; \
	cd ../tests && plptest --threads 16 --stdout


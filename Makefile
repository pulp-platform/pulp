
SHELL=bash

PKG_DIR ?= $(PWD)/pulp-runtime

export VSIM_PATH=$(PWD)/sim
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
	./update-ips

# generic clean and build targets for the platform
clean:
	rm -rf $(VSIM_PATH)
	cd sim && $(MAKE) clean

build:
#	cd sim && $(MAKE) lib build opt
#	cp -r rtl/tb/* $(VSIM_PATH)
	cd sim && $(MAKE) all

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

# simplified runtime for PULP that doesn't need the sdk
pulp-runtime:
	git clone https://github.com/pulp-platform/pulp-runtime.git -b v0.0.4

# the gitlab runner needs a special configuration to be able to access the
# dependent git repositories
test-checkout-gitlab:
	./update-regression-tests



# gitlab and local test runs
test-local-regressions: 
	mkdir -p regression_tests/riscv_tests_soc
	cp -r regression_tests/riscv_tests/* regression_tests/riscv_tests_soc
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 600 --yaml -o simplified-runtime.xml regression-tests.yaml

git-ci-ml-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-ml-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-ml-runtime.xml ml-tests.yaml

git-ci-riscv-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-riscv-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-riscv-runtime.xml riscv-tests.yaml

git-ci-s-bare-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-sbare-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-sbare-runtime.xml sequential-bare-tests.yaml

git-ci-p-bare-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-pbare-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-pbare-runtime.xml parallel-bare-tests.yaml

test-local-runtime: 
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	cd tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 600 --yaml -o simplified-runtime.xml runtime-tests.yaml



SHELL=bash

PKG_DIR ?= $(PWD)/pulp-runtime

export VSIM_PATH=$(PWD)/sim
export PULP_PATH=$(PWD)

export MSIM_LIBS_PATH=$(VSIM_PATH)/modelsim_libs

export IPS_PATH=$(PULP_PATH)/fe/ips
export RTL_PATH=$(PULP_PATH)/fe/rtl
export TB_PATH=$(PULP_PATH)/rtl/tb

export AEGIS_ROOT=$(PWD)/aegis
export AEGIS_FILE_PATH=$(PWD)

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

VLOG_ARGS += -suppress 2583 -suppress 13314 \"+incdir+\$$ROOT/rtl/includes\"
BENDER_SIM_BUILD_DIR = sim
BENDER_FPGA_SCRIPTS_DIR = fpga/pulp/tcl/generated

.PHONY: checkout
ifndef IPAPPROX
checkout: bender
	./bender update
	touch Bender.lock

Bender.lock: bender
	./bender update
	touch Bender.lock

else
checkout:
	./update-ips
endif
	$(MAKE) scripts

# generic clean and build targets for the platform
.PHONY: clean
clean:
	$(MAKE) -C sim IPAPPROX=$(IPAPPROX) clean


.PHONY: scripts
## Generate scripts for all tools
ifndef IPAPPROX
scripts: scripts-bender-vsim # scripts-bender-fpga

scripts-bender-vsim: | Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl

# scripts-bender-fpga: | Bender.lock
# 	mkdir -p fpga/pulp/tcl/generated
# 	./bender script vivado -t fpga -t xilinx > $(BENDER_FPGA_SCRIPTS_DIR)/compile.tcl

$(BENDER_SIM_BUILD_DIR)/compile.tcl: Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl

scripts-bender-vsim-vips: | Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test -t rt_dpi -t i2c_vip -t flash_vip -t i2s_vip -t hyper_vip -t use_vips \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl

scripts-bender-vsim-psram: | Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test -t psram_vip \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl
	sed -i 's/psram_fake.v/*.vp_modelsim/g' $(BENDER_SIM_BUILD_DIR)/compile.tcl # Workaround for unsupported file type in bender

else
scripts:
	./generate-scripts
endif

scripts-vips:
ifndef IPAPPROX
	$(MAKE) scripts-bender-vsim-vips
else
	./generate-scripts --rt-dpi --i2c-vip --flash-vip --i2s-vip --hyper-vip --use-vip --verbose
endif

scripts-psram:
ifndef IPAPPROX
	$(MAKE) scripts-bender-vsim-psram
else
	./generate-scripts --psram-vip
endif

.PHONY: build
## Build the RTL model for vsim
ifndef IPAPPROX
build: $(BENDER_SIM_BUILD_DIR)/compile.tcl
	@test -f Bender.lock || { echo "ERROR: Bender.lock file does not exist. Did you run make checkout in bender mode?"; exit 1; }
	@test -f $(BENDER_SIM_BUILD_DIR)/compile.tcl || { echo "ERROR: sim/compile.tcl file does not exist. Did you run make scripts in bender mode?"; exit 1; }
	$(MAKE) -C sim all
else
build:
	@[ "$$(ls -A ips/)" ] || { echo "ERROR: ips/ is an empty directory. Did you run ./update-ips?"; exit 1; }
	$(MAKE) -C sim IPAPPROX=$(IPAPPROX) all
endif

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
	git clone https://github.com/pulp-platform/pulp-runtime.git -b tcls

# the gitlab runner needs a special configuration to be able to access the
# dependent git repositories
test-checkout-gitlab:
	./update-regression-tests



# gitlab and local test runs
test-fast-regressions:
	mkdir -p regression_tests/riscv_tests_soc
	cp -r regression_tests/riscv_tests/* regression_tests/riscv_tests_soc
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-runtime.xml simple-regression-tests.yaml

test-local-regressions: 
	mkdir -p regression_tests/riscv_tests_soc
	cp -r regression_tests/riscv_tests/* regression_tests/riscv_tests_soc
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 1800 --yaml -o simplified-runtime.xml regression-tests.yaml

git-ci-ml-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-ml-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-ml-runtime.xml ml-tests.yaml

git-ci-riscv-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-riscv-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-riscv-runtime.xml riscv-tests.yaml

git-ci-s-bare-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-sbare-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-sbare-runtime.xml sequential-bare-tests.yaml

git-ci-p-bare-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-pbare-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-pbare-runtime.xml parallel-bare-tests.yaml

git-ci-periphs-regs:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-periph-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-periph-runtime.xml periph-tests.yaml

git-ci-psram:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/simplified-psram-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o simplified-psram-runtime.xml psram-test.yaml

git-boot:
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	touch regression_tests/boot-runtime.xml; \
	cd regression_tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 7200 --yaml -o boot-runtime.xml hello-test.yaml

test-local-runtime: 
	source setup/vsim.sh; \
	source pulp-runtime/configs/pulp.sh; \
	cd tests && ../pulp-runtime/scripts/bwruntests.py --proc-verbose -v --report-junit -t 600 --yaml -o simplified-runtime.xml runtime-tests.yaml


# Bender integration

.PHONY: bender-rm
BENDER_VERSION = 0.25.2

bender: 
ifeq (,$(wildcard ./bender))
	curl --proto '=https' --tlsv1.2 -sSf https://pulp-platform.github.io/bender/init \
		| bash -s -- $(BENDER_VERSION)
	touch bender
endif

bender-rm:
	rm -f bender

.PHONY: aegis-rm aegis-run aegis-publish aegis-test

aegis:
	git clone git@iis-git.ee.ethz.ch:bslk/aegis.git # -b 87c44f0fc0cd318f015dcea0932a761204a6abc8

aegis-rm:
	rm -rf aegis

aegis-run: 
	$(MAKE) -C aegis/freepdk45/synopsys clean
	$(MAKE) -C aegis/freepdk45/synopsys synth_pulp_cluster.ri5cy
	$(MAKE) -C aegis/freepdk45/synopsys synth_pulp_cluster.ibex

aegis-publish:
	rm -f $(AEGIS_ROOT)/frontend/data.json
	$(MAKE) -C aegis/frontend data.json gtable_pulp_cluster

aegis-test:
	$(MAKE) -C aegis/freepdk45/synopsys synth_pulp_cluster.ibex_test

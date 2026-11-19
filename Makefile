
SHELL=bash

export VSIM_PATH=$(PWD)/sim
export PULP_PATH=$(PWD)

export MSIM_LIBS_PATH=$(VSIM_PATH)/modelsim_libs

export IPS_PATH=$(PULP_PATH)/fe/ips
export RTL_PATH=$(PULP_PATH)/fe/rtl
export TB_PATH=$(PULP_PATH)/rtl/tb

ROOT_DIR = $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
TOOLCHAINS_DIR ?= /opt/riscv/
BENDER_GIT_DIR=$(PULP_PATH)/.bender/git/checkouts
BENDER_BIN ?= $(shell which bender)

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

TOOLCHAIN_IMAGE ?= ghcr.io/pulp-platform/deeploy-toolchain:latest
DEEPLOY_IMAGE ?= ghcr.io/pulp-platform/deeploy:latest
SSH_PRIVATE_KEY ?= ~/.ssh/nonfree_ed25519

CompileFlags := +acc -permissive -suppress 2583 -suppress 13314 -suppress vlog-1952

VENV := venv

.PHONY: checkout
ifndef IPAPPROX
Bender.lock: bender
	./bender checkout
	touch Bender.lock

checkout: bender
	./bender checkout
	touch Bender.lock
else
checkout:
	./update-ips
endif

# generic clean and build targets for the platform
.PHONY: clean
clean:
	$(MAKE) -C sim IPAPPROX=$(IPAPPROX) clean


.PHONY: scripts
## Generate scripts for all tools
ifndef IPAPPROX
scripts: scripts-bender-vsim scripts-bender-fpga

include bender-common.mk
include bender-synth.mk

scripts-bender-vsim-mchan: | Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test -t pulp -t mchan $(common_defs) $(common_targs) \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl \

scripts-bender-vsim: | Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test -t pulp -t idma $(common_defs) $(common_targs) \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl \

scripts-bender-fpga-mchan: | Bender.lock
	mkdir -p fpga/pulp/tcl/generated
	./bender script vivado -t fpga -t mchan -t rtl $(fpga_defs) $(common_defs) $(common_targs) -t xilinx > $(BENDER_FPGA_SCRIPTS_DIR)/compile.tcl
	sed -i '/TRACE_EXECUTION/d' $(BENDER_FPGA_SCRIPTS_DIR)/compile.tcl

scripts-bender-fpga: | Bender.lock
	mkdir -p fpga/pulp/tcl/generated
	./bender script vivado -t fpga -t idma -t rtl $(fpga_defs) $(common_defs) $(common_targs) -t xilinx > $(BENDER_FPGA_SCRIPTS_DIR)/compile.tcl
	sed -i '/TRACE_EXECUTION/d' $(BENDER_FPGA_SCRIPTS_DIR)/compile.tcl

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

$(BENDER_SIM_BUILD_DIR)/compile_lint.tcl:
	echo 'set ROOT $(ROOT_DIR)' > $(BENDER_SIM_BUILD_DIR)/compile_lint.tcl
	./bender script vsim --vlog-arg="$(VLOG_ARGS_LINT)" $(common_defs) $(common_targs) $(synth_targs) $(synth_defs) | grep -v "set ROOT" >> $@
	echo >> $(BENDER_SIM_BUILD_DIR)/compile_lint.tcl

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

idma_venv:
	python3 -m venv $(VENV) && \
	$(VENV)/bin/python -m pip install -U pip && \
	$(VENV)/bin/python -m pip install -r $(shell ./bender path idma)/requirements.txt

generate_idma_rtl: idma_venv
	. "$(VENV)/bin/activate" && $(MAKE) -C $(shell ./bender path idma) idma_hw_all

.PHONY: build
## Build the RTL model for vsim

# Init rules: choose to initialize the repo for RTL or FPGA

init: checkout generate_idma_rtl scripts-bender-vsim

init-fpga: checkout generate_idma_rtl scripts-bender-fpga

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

## Build the RTL model for QuestaONE
build_qone: $(BENDER_SIM_BUILD_DIR)/compile.tcl
	@test -f Bender.lock || { echo "ERROR: Bender.lock file does not exist. Did you run make checkout in bender mode?"; exit 1; }
	@test -f $(BENDER_SIM_BUILD_DIR)/compile.tcl || { echo "ERROR: sim/compile.tcl file does not exist. Did you run make scripts in bender mode?"; exit 1; }
	$(MAKE) -C sim all_qone


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

PULP_SDK_REMOTE := https://github.com/FondazioneChipsIT/pulp-sdk.git
PULP_SDK_COMMIT := 55fedf856aafa0a305c6bcd02b7e62b69bc74246

pulp_sdk:
	git clone ${PULP_SDK_REMOTE}; \
	cd pulp-sdk; \
	git checkout ${PULP_SDK_COMMIT}; \
	git submodule update --init --recursive;

# GVSoC is cloned from upstream. The changes this platform needs live on a branch of the
# gvsoc-pulp submodule, hosted on the same upstream remote: the Deeploy cluster memory
# sizes and the iDMA model of the cluster DMA.
GVSOC_URL ?= https://github.com/gvsoc/gvsoc.git
GVSOC_PULP_BRANCH ?= master
GVSOC_COMMIT ?= 753056fbf2da60a16be4d58eba5c38f70b8c6af8
# Cluster L1 size: the Deeploy tiled flow needs more than the 64 KiB PULP Open ships with
GVSOC_L1_SIZE ?= 0x00040000
# Cluster DMA: mchan | idma
GVSOC_DMA     ?= idma

gvsoc_venv:
	rm -rf $(VENV) && \
	python3.12 -m venv $(VENV) && \
	$(VENV)/bin/python -m pip install -U pip && \
	$(VENV)/bin/python -m pip install -r gvsoc/requirements.txt && \
	$(VENV)/bin/python -m pip install -r gvsoc/gvrun/requirements.txt && \
    $(VENV)/bin/python -m pip install -r gvsoc/config_tree/requirements.txt && \
    $(VENV)/bin/python -m pip install -r gvsoc/core/requirements.txt

gvsoc:
	git clone $(GVSOC_URL); \
	cd gvsoc; \
	git submodule update --init --recursive; \
	git fetch origin; \
	git checkout $(GVSOC_COMMIT)

build_gvsoc: gvsoc gvsoc_venv
	. "$(VENV)/bin/activate" && \
	cd gvsoc/pulp && \
	(git apply --reverse --check $(CURDIR)/setup/gvsoc_pulp_open.patch 2>/dev/null || \
	 git apply $(CURDIR)/setup/gvsoc_pulp_open.patch) && \
	cd .. && \
	source sourceme.sh && \
	$(MAKE) clean build TARGETS=pulp-open

build_gvsoc_mchan:
	$(MAKE) build_gvsoc GVSOC_DMA=mchan

DEEPLOY_REMOTE := https://github.com/FondazioneChipsIT/Deeploy.git
DEEPLOY_COMMIT := b20e5dd750f2c96d13017e0383f07e841ce22f08

deeploy:
	source setup/deeploy.sh; \
	git clone ${DEEPLOY_REMOTE}; \
	cd Deeploy; \
	git checkout ${DEEPLOY_COMMIT}; \
	git submodule update --init --recursive; \
	pip install -e . --extra-index-url=https://pypi.ngc.nvidia.com; \
	make minimalloc xtensor; \

# Build the final Deeploy image for chipsit CI
deeploy_container_CI:
	eval $$(ssh-agent) && \
	ssh-add $(SSH_PRIVATE_KEY) && \
	ssh-add -l && \
	DOCKER_BUILDKIT=1 docker build \
		--ssh default \
		--build-context pulp_root=/home/gitlab-runner/ \
		--build-context llvm_toolchain_dir=/opt/riscv/ \
		-f ${ROOT_DIR}/nonfree/new_testing_setup/Dockerfile.deeploy_container_CI \
		--build-arg BASE_IMAGE=$(TOOLCHAIN_IMAGE) \
		-t $(DEEPLOY_IMAGE) ..

deeploy_container_user:
	eval $$(ssh-agent) && \
	ssh-add $(SSH_PRIVATE_KEY) && \
	ssh-add -l && \
	podman build \
		--ssh default \
		--build-context pulp_root=${HOME} \
		--build-context llvm_toolchain_dir=${TOOLCHAINS_DIR} \
		-f ${ROOT_DIR}/nonfree/new_testing_setup/Dockerfile.deeploy_container_CI \
		--build-arg BASE_IMAGE=$(TOOLCHAIN_IMAGE) \
		-t $(DEEPLOY_IMAGE) ..

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

bender:
	ln -sf $(BENDER_BIN) bender

.PHONY: bender-rm
bender-rm:
	rm -f bender

compile_lint:
	$(MAKE) -C sim compile_lint

lint:
	$(MAKE) -C sim lint

cdc:
	$(MAKE) -C sim cdc

PULP_NONFREE_REMOTE ?= git@gitlab.chips.it:digitalresearchline/chips-restricted/pulp-nonfree.git
PULP_NONFREE_DIR	?= $(ROOT_DIR)/nonfree
PULP_NONFREE_COMMIT ?= b645f27f3133ad2f5aac2438133ea042afd0f22f

pulp_nonfree_init:
	git clone $(PULP_NONFREE_REMOTE) $(PULP_NONFREE_DIR)
	cd $(PULP_NONFREE_DIR) && git checkout $(PULP_NONFREE_COMMIT)

pulp_nonfree_clean:
	rm -rf $(PULP_NONFREE_DIR)


## Rule called by CI script to test Deeploy gvsoc regreession on the container
run_deeploy_container_gvsoc:
	podman run --rm \
	-e PULP_BRANCH \
	-v /tools:/tools:ro \
	-v /opt/riscv:/opt/riscv:ro \
	-v /opt/rh:/opt/rh \
	ghcr.io/pulp-platform/deeploy:latest \
	/bin/bash app/deeploy_gvsoc.sh

## Rule called by CI script to test Deeploy rtl regreession on the container
run_deeploy_container_rtl:
	podman run --rm \
	-e PULP_BRANCH \
	-v /tools:/tools:ro \
	-v /opt/riscv:/opt/riscv:ro \
	-v /opt/rh:/opt/rh \
	ghcr.io/pulp-platform/deeploy:latest \
	/bin/bash app/deeploy_rtl.sh

run_chipsit_deeploy_container_interactive:
	podman run --rm -it \
	-v /tools:/tools:ro \
	-v /opt/riscv:/opt/riscv:ro \
	-v /opt/rh:/opt/rh \
	ghcr.io/pulp-platform/deeploy:latest \
	/bin/zsh

#!/bin/bash

echo "exporting RISCV 32 bit with zfinx"

export PATH=/usr/pack/pulpsdk-1.0-kgf/artifactory/pulp-sdk-release/pkg/pulp_riscv_gcc/1.0.16/bin:$PATH

echo "exporting questa-2019"

export QUESTA=questa-2019.3-kgf
export VLOG="$QUESTA vlog"
export VLIB="$QUESTA vlib"
export VMAP="$QUESTA vmap"
export VCOM="$QUESTA vcom"
export VOPT="$QUESTA vopt"
export VSIM="$QUESTA vsim"
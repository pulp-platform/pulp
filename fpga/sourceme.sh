#!/bin/bash

export VIVADO_HOME=/opt/xilinx/Vivado/2018.2
source $VIVADO_HOME/settings64.sh

# either "zedboard" or "zc706" or "vcu118" or "zcu102"
if [ -z "$BOARD"  ]; then
    read -p "Which board you want to use: 1-zedboard 2-zcu102 3-vcu118 4-zc706 [4]: " BOARD

    if [ "$BOARD" = "1" ]; then
        export BOARD="zedboard"
        export XILINX_PART="xc7z020clg484-1"
        export XILINX_BOARD="em.avnet.com:zynq:zed:c"
    elif [ "$BOARD" = "2" ]; then
        export BOARD="zcu102"
        export XILINX_PART="xczu9eg-ffvb1156-2-e"
        export XILINX_BOARD="xilinx.com:zcu102:part0:3.2"
    elif [ "$BOARD" = "3" ]; then
        export BOARD="vcu118"
        export XILINX_PART="xcvu9p-flga2104-2L-e"
        export XILINX_BOARD="xilinx.com:vcu118:part0:2.0"
    else
        export BOARD="zc706"
        export XILINX_PART="xc7z045ffg900-2"
        export XILINX_BOARD="xilinx.com:zc706:part0:1.3"
    fi
fi

echo "$BOARD"
echo "XILINX_PART=$XILINX_PART"
echo "XILINX_BOARD=$XILINX_BOARD"

export VSIM_PATH=$PWD/sim

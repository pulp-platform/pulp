ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)
DEEPLOY_ROOT="$ROOT"/Deeploy

export MINIMALLOC_INSTALL_DIR=$DEEPLOY_ROOT/install/minimalloc
export PULP_SDK_HOME=$ROOT/pulp-sdk
export GVSOC_INSTALL_DIR=$ROOT/gvsoc/install
export LLVM_INSTALL_DIR=/opt/riscv/snitch-llvm-15.0.0-snitch-0.1.0/
export GCC_INSTALL_DIR=/opt/riscv/pulp-gcc-1.0.16/
export CMAKE=/usr/bin/cmake
export PATH=$ROOT/../../deeploy_gcc/gcc-11.4.0/bin/:$PATH
export PULP_OPEN_HOME=$ROOT

export CMAKE_BUILD_PARALLEL_LEVEL=8
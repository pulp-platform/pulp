ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)
source /usr/share/modules/init/bash
export MODULEPATH=/tools/utils/.modulefiles:/opt/riscv/.modulefiles:/tools/amd/.modulefiles:/tools/cadence/.modulefiles:/tools/siemens/.modulefiles:/tools/synopsys/.modulefiles:/tools/verilator/.modulefiles:${MODULEPATH}
module load bender/0.32.1
module load questa/2026.1_2
module load pulp-gcc/1.0.16
export PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv/pulp-gcc-1.0.16/
source setup/vsim.sh
export PATH=$ROOT/gvsoc/install/bin/:$PATH
export IS_CONTAINER=1
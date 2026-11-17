ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)
export VSIM_PATH="$ROOT"/sim
export TB_PATH="$ROOT"/rtl/tb

#!/bin/bash

trap "exit" INT TERM
trap "kill 0" EXIT


SCRIPTDIR=$(dirname $0)
UART_TTY=${PULP_GENESYS2_UART_TTY:=/dev/ttyUSB0}
UART_BAUDRATE=${PULP_GENESYS2_UART_BAUDRATE:=115200}

#Execute gdb and connect to openocd via pipe
$OPENOCD/bin/openocd -f $SCRIPTDIR/openocd-genesys2.cfg &
$PULP_RISCV_GCC_TOOLCHAIN_CI/bin/riscv32-unknown-elf-gdb -x $SCRIPTDIR/elf_run.gdb $1 &
sleep 3
minicom -D $UART_TTY -b $UART_BAUDRATE



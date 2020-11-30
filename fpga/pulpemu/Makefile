PROJECT:=pulpemu
PROBES?=0

all: ${BOARD}

vcu118: synth bootgen_vcu

zcu102: synth bootgen_zynq_mp

zc706: synth bootgen_zynq

synth:
	vivado-2018.2 vivado -mode batch -source tcl/run.tcl

impl:
	rm -rf .Xil
	vivado-2018.2 vivado -mode batch -source tcl/impl.tcl
	cp ${PROJECT}.runs/impl_1/${PROJECT}.bit .
	cp ${PROJECT}.runs/impl_1/*.dcp .

gui:
	vivado-2018.2 vivado -mode gui -source tcl/setup_impl.tcl &

gui-synth:
	vivado-2018.2 vivado -mode gui -source tcl/run.tcl &

gui-impl:
	vivado-2018.2 vivado -mode gui -source tcl/impl.tcl &

bootgen_zynq_mp:
	cp ${PROJECT}.runs/impl_1/${PROJECT}.bit board/${BOARD}/${PROJECT}.bit
	bootgen -image board/${BOARD}/output.bif -arch zynqmp -o board/${BOARD}/BOOT.bin -w on
	cp board/${BOARD}/BOOT.bin "board/${BOARD}/`./board/get-bitstream-name.sh`"

bootgen_zynq:
	cp ${PROJECT}.runs/impl_1/${PROJECT}.bit board/${BOARD}/${PROJECT}.bit
	bootgen -image board/${BOARD}/output.bif -arch zynq -o board/${BOARD}/BOOT.bin -w on
	cp board/${BOARD}/BOOT.bin "board/${BOARD}/`./board/get-bitstream-name.sh`"

bootgen_vcu:
	cp ${PROJECT}.runs/impl_1/${PROJECT}.bit board/${BOARD}/${PROJECT}.bit
	vivado-2018.2 vivado -mode tcl -source board/${BOARD}/bit_to_mcs.tcl
	cp board/${BOARD}/${PROJECT}.mcs "board/${BOARD}/`./board/get-bitstream-name.sh`"

program_fpga_vcu:
	vivado-2018.2 vivado -mode tcl -source board/${BOARD}/program_fpga.tcl

program_spi_vcu:
	bash board/${BOARD}/guide.sh
	vivado-2018.2 vivado -mode tcl -source board/${BOARD}/program_spi.tcl

qspiflash:
	program_flash -f board/BOOT.bin -offset 0 -flash_type \
	qspi_dual_parallel -fsbl board/${BOARD}/fsbl.elf \
	-cable type xilinx_tcf url TCP:127.0.0.1:3121

continue:
	vivado-2018.2 vivado -mode gui ${PROJECT}.xpr

clean-impl:
	rm -rf ${PROJECT}.runs/impl_1

clean:
	rm -rf ${PROJECT}.hw
	rm -rf ${PROJECT}.xpr
	rm -rf ${PROJECT}.data
	rm -rf ${PROJECT}.runs
	rm -rf ${PROJECT}.srcs
	rm -rf ps7_*
	rm -rf ${PROJECT}.sim
	rm -rf ${PROJECT}.sdk
	rm -rf ${PROJECT}.cache
	rm -rf ${PROJECT}.ioplanning
	rm -rf ${PROJECT}.hwdef
	rm -rf *.log
	rm -rf ulpsoc.txt
	rm -rf pulp_cluster.txt
	rm -rf component.xml
	rm -rf vivado*
	rm -rf xgui
	rm -rf .Xil
	rm -rf ps_clock*
	rm -rf ${PROJECT}*
	rm -rf ${PROJECT}.edf
	rm -rf board/BOOT.bin
	rm -rf board/${PROJECT}.bit

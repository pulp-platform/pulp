PROJECT:=xilinx_tcdm_bank_2048x32

all:
	vivado-2018.2 vivado -mode batch -source tcl/run.tcl
	mkdir -p ip
	cp -r ${PROJECT}.srcs/sources_1/ip/${PROJECT}/* ip/.
	cp ${PROJECT}.runs/${PROJECT}_synth_1/${PROJECT}.dcp ip/.

gui:
	vivado-2018.2 vivado -mode gui -source tcl/run.tcl &

clean:
	rm -rf ip/*
	mkdir -p ip
	rm -rf ${PROJECT}.*
	rm -rf component.xml
	rm -rf vivado*.jou
	rm -rf vivado*.log
	rm -rf vivado*.str
	rm -rf xgui
	rm -rf .Xil

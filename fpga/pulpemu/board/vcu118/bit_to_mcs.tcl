write_cfgmem -force -format mcs -size 256 -interface SPIx8 -loadbit {up 0x00000000 "./board/vcu118/pulpemu.bit" } -file "./board/vcu118/pulpemu.mcs"
exit

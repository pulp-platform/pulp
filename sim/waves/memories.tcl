set l2mem [find instances -recursive -bydu l2_ram_multi_bank -nodu]


add wave -group "L2_Mem"  -group "CutPriv0"                             $l2mem/bank_sram_pri0_i/*
add wave -group "L2_Mem"  -group "CutPriv1"                             $l2mem/bank_sram_pri1_i/*

add wave -group "L2_Mem"  -group "Cut0"                                 $l2mem/CUTS\[0\]//bank_i/*
add wave -group "L2_Mem"  -group "Cut1"                                 $l2mem/CUTS\[1\]//bank_i/*
add wave -group "L2_Mem"  -group "Cut2"                                 $l2mem/CUTS\[2\]//bank_i/*
add wave -group "L2_Mem"  -group "Cut3"                                 $l2mem/CUTS\[3\]//bank_i/*

# wave configuration
configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns

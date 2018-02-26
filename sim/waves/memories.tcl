set l2mem [find instances -recursive -bydu l2_ram_multi_bank -nodu]

add wave -group "L2_Mem"  -group "CutPriv0"                             $l2mem/bank_sram24k_scm8k_pri0_i/*
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM"                $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/*

add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut0"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[0\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut1"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[1\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut2"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[2\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut3"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[3\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut4"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[4\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut5"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[5\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut6"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[6\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut7"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[7\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut8"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[8\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut9"  $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[9\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut10" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[10\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut11" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[11\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut12" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[12\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut13" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[13\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut14" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[14\]/scm_i/MemContentxDP
add wave -group "L2_Mem"  -group "CutPriv0" -group "SCM" -group "Cut15" $l2mem/bank_sram24k_scm8k_pri0_i/scm_0/SCM_CUT\[15\]/scm_i/MemContentxDP

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

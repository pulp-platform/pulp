
# add cores
set apu [find instances -recursive -bydu apu_cluster]

if {$apu ne ""} {

    set naddsub [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/marx_addsub_i/NAPUS]
#    set nsqrt [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_sqrt/marx_sqrt_i/NAPUS]
#    set ndiv [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_div/marx_div_i/NAPUS]
    set nmult [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/marx_mult_i/NAPUS]
    set nmac [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/marx_mac_i/NAPUS]
    set ncast [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/marx_cast_i/NAPUS]
    set ndsp_mult [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_dsp/marx_dsp_mult_i/NAPUS]
    set ndivsqrt [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_divsqrt/marx_divsqrt_i/NAPUS]
#    set nint_mult [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_int_mult/marx_int_mult_i/NAPUS]
#    set nint_div [examine -radix d /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_int_div/marx_int_div_i/NAPUS]
    set nint_mult 0
    set nint_div 0
    set nsqrt 0
    set ndiv 0

    for {set i 0} {$i < $naddsub} {incr i} {
	set apu_str [format "APU Cluster"]
	set addsub_str [format "Addsub_%d" $i]
	add wave -group $apu_str -group $addsub_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/fp_addsub_wrap\[$i\]/fp_addsub_wrap_i/*
    }
    for {set i 0} {$i < $nmult} {incr i} {
	set apu_str [format "APU Cluster"]
	set mult_str [format "Mult_%d" $i]
	add wave -group $apu_str -group $mult_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/fp_mult_wrap\[$i\]/fp_mult_wrap_i/*
    }
    for {set i 0} {$i < $nsqrt} {incr i} {
	set apu_str [format "APU Cluster"]
	set sqrt_str [format "Sqrt_%d" $i]
	add wave -group $apu_str -group $sqrt_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_sqrt/fp_sqrt_wrap\[$i\]/fp_sqrt_wrap_i/*
    }
    for {set i 0} {$i < $ndiv} {incr i} {
	set apu_str [format "APU Cluster"]
	set div_str [format "Div_%d" $i]
	add wave -group $apu_str -group $div_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_div/fp_div_wrap\[$i\]/fp_div_wrap_i/*
    }
    for {set i 0} {$i < $nmac} {incr i} {
	set apu_str [format "APU Cluster"]
	set mac_str [format "Mac_%d" $i]
	add wave -group $apu_str -group $mac_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/fp_mac_wrap\[$i\]/fp_mac_wrap_i/*
    }
    for {set i 0} {$i < $ncast} {incr i} {
	set apu_str [format "APU Cluster"]
	set cast_str [format "Cast_%d" $i]
	add wave -group $apu_str -group $cast_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/fp_cast_wrap\[$i\]/fp_cast_wrap_i/*
    }
    for {set i 0} {$i < $ndivsqrt} {incr i} {
	set apu_str [format "APU Cluster"]
	set cast_str [format "DivSqrt_%d" $i]
	add wave -group $apu_str -group $cast_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_fpu/shared_fp_divsqrt/fp_divsqrt_wrap\[$i\]/fp_iter_divsqrt_wrap_i/*
    }
    for {set i 0} {$i < $ndsp_mult} {incr i} {
	set apu_str [format "APU Cluster"]
	set dsp_mult_str [format "DSP_Mult_%d" $i]
	add wave -group $apu_str -group $dsp_mult_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_dsp/dsp_mult_wrap\[$i\]/dsp_mult_wrap_i/*
    }
    for {set i 0} {$i < $nint_mult} {incr i} {
	set apu_str [format "APU Cluster"]
	set int_mult_str [format "Int_Mult_%d" $i]
	add wave -group $apu_str -group $int_mult_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_int_mult/int_mult_wrap\[$i\]/int_mult_wrap_i/*
    }
    for {set i 0} {$i < $nint_div} {incr i} {
	set apu_str [format "APU Cluster"]
	set int_div_str [format "Int_div_%d" $i]
	add wave -group $apu_str -group $int_div_str   /tb/i_dut/cluster_domain_i/cluster_i/apu_cluster_i/shared_int_div/int_div_wrap\[$i\]/int_div_i/*
    }
}
# add PAD
set gf22_FLL [find instances -recursive -bydu gf22_FLL -nodu]

if {$gf22_FLL ne ""} {
  add wave -group "gf22_FLL" -group "SOC"                            /tb/i_dut/pulpissimo_i/soc_domain_i/ulpsoc_i/i_clk_rst_gen/i_fll_soc/*
  add wave -group "gf22_FLL" -group "PER"                            /tb/i_dut/pulpissimo_i/soc_domain_i/ulpsoc_i/i_clk_rst_gen/i_fll_per/*
  add wave -group "gf22_FLL" -group "CLUSTER"                        /tb/i_dut/pulpissimo_i/soc_domain_i/ulpsoc_i/i_clk_rst_gen/i_fll_cluster/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
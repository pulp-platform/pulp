# add PAD
set gf22_FLL [find instances -recursive -bydu gf22_FLL -nodu]

if {$gf22_FLL ne ""} {
  add wave -group "gf22_FLL" -group "SOC"                            tb_pulp/i_dut/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fll_soc/*
  add wave -group "gf22_FLL" -group "PER"                            tb_pulp/i_dut/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fll_per/*
  add wave -group "gf22_FLL" -group "CLUSTER"                        tb_pulp/i_dut/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fll_cluster/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
# add PAD
set soc_clk_gen [find instances -recursive -bydu soc_clk_rst_gen -nodu]

if {$soc_clk_gen ne ""} {
  add wave -group "SOC_CLK_GEN"                              $soc_clk_gen/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
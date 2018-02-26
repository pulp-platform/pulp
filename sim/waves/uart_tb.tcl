# add PAD
set uart_tb [find instances -recursive -bydu uart_tb_rx -nodu]

if {$uart_tb ne ""} {
  add wave -group "TB_UART"                                     $uart_tb/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
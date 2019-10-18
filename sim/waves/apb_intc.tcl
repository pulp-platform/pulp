# add PAD
set apb_intc [find instances -recursive -bydu apb_interrupt_cntrl -nodu]

if {$apb_intc ne ""} {
  add wave -group "apb_intc"                              $apb_intc/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
# add PAD
set udma_subsystem [find instances -recursive -bydu udma_subsystem -nodu]

if {$udma_subsystem ne ""} {
  add wave -group "udma_subsystem"                                     $udma_subsystem/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
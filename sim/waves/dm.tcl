# add dm
set dm [find instances -recursive -bydu dm_top -nodu]
set dm_mem  [find instances -recursive -bydu dm_mem -nodu]
set dm_csrs [find instances -recursive -bydu dm_csrs -nodu]
set dm_sba  [find instances -recursive -bydu dm_sba -nodu]

if {$dm ne ""} {
  add wave -group "DM"                                     $dm/*
}
if {$dm_mem ne ""} {
  add wave -group "DM" -group "dm_mem"                     $dm_mem/*
}
if {$dm_csrs ne ""} {
  add wave -group "DM" -group "dm_csrs"                    $dm_csrs/*
}
if {$dm_sba ne ""} {
  add wave -group "DM" -group "dm_sba"                     $dm_sba/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns

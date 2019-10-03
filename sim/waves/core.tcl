# add fc
set rvcores [find instances -recursive -bydu riscv_core -nodu]
set fpuprivate [find instances -recursive -bydu fpu_private]
set rvpmp [find instances -recursive -bydu riscv_pmp]

if {$rvcores ne ""} {
  set rvprefetch [find instances -recursive -bydu riscv_prefetch_L0_buffer -nodu]

  add wave -group "Core"                                     $rvcores/*
  add wave -group "Core"  -group "IF Stage" -group "Hwlp Ctrl"              $rvcores/if_stage_i/hwloop_controller_i/*
  if {$rvprefetch ne ""} {
    add wave -group "Core"  -group "IF Stage" -group "Prefetch" -group "L0"   $rvcores/if_stage_i/prefetch_128/prefetch_buffer_i/L0_buffer_i/*
    add wave -group "Core"  -group "IF Stage" -group "Prefetch"               $rvcores/if_stage_i/prefetch_128/prefetch_buffer_i/*
  } {
    add wave -group "Core"  -group "IF Stage" -group "Prefetch" -group "FIFO" $rvcores/if_stage_i/prefetch_32/prefetch_buffer_i/fifo_i/*
    add wave -group "Core"  -group "IF Stage" -group "Prefetch"               $rvcores/if_stage_i/prefetch_32/prefetch_buffer_i/*
  }
  add wave -group "Core"  -group "IF Stage"                                 $rvcores/if_stage_i/*
  add wave -group "Core"  -group "ID Stage"                                 $rvcores/id_stage_i/*
  add wave -group "Core"  -group "RF"                                       $rvcores/id_stage_i/registers_i/riscv_register_file_i/mem
  add wave -group "Core"  -group "RF_FP"                                    $rvcores/id_stage_i/registers_i/riscv_register_file_i/mem_fp
  add wave -group "Core"  -group "Decoder"                                  $rvcores/id_stage_i/decoder_i/*
  add wave -group "Core"  -group "Controller"                               $rvcores/id_stage_i/controller_i/*
  add wave -group "Core"  -group "Int Ctrl"                                 $rvcores/id_stage_i/int_controller_i/*
  add wave -group "Core"  -group "Hwloop Regs"                              $rvcores/id_stage_i/hwloop_regs_i/*
  add wave -group "Core"  -group "EX Stage" -group "ALU"                    $rvcores/ex_stage_i/alu_i/*
  add wave -group "Core"  -group "EX Stage" -group "ALU_DIV"                $rvcores/ex_stage_i/alu_i/int_div/div_i/*
  add wave -group "Core"  -group "EX Stage" -group "MUL"                    $rvcores/ex_stage_i/mult_i/*
  if {$fpuprivate ne ""} {
    add wave -group "Core"  -group "EX Stage" -group "APU_DISP"             $rvcores/ex_stage_i/genblk1/apu_disp_i/*
    add wave -group "Core"  -group "EX Stage" -group "FPU"                  $rvcores/ex_stage_i/genblk1/genblk1/fpu_i/*
  }
  add wave -group "Core"  -group "EX Stage"                                 $rvcores/ex_stage_i/*
  add wave -group "Core"  -group "LSU"                                      $rvcores/load_store_unit_i/*
  if {$rvpmp ne ""} {
    add wave -group "Core"  -group "PMP"                                    $rvcores/RISCY_PMP/pmp_unit_i/*
  }
  add wave -group "Core"  -group "CSR"                                      $rvcores/cs_registers_i/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns

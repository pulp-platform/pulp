create_pblock pblock_cluster_i
add_cells_to_pblock [get_pblocks pblock_cluster_i] [get_cells -quiet [list ulpsoc_i/cluster_i]]
resize_pblock [get_pblocks pblock_cluster_i] -add {SLICE_X32Y62:SLICE_X143Y274}
resize_pblock [get_pblocks pblock_cluster_i] -add {DSP48_X2Y26:DSP48_X5Y109}
resize_pblock [get_pblocks pblock_cluster_i] -add {RAMB18_X3Y26:RAMB18_X6Y109}
resize_pblock [get_pblocks pblock_cluster_i] -add {RAMB36_X3Y13:RAMB36_X6Y54}

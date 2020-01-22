#
# Copyright (C) 2016-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

.PHONY: build clean lib

build:
	@make --no-print-directory -f $(mkfile_path)/ips/L2_tcdm_hybrid_interco.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/adv_dbg_if.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb2per.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb_adv_timer.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb_fll_if.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb_gpio.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb_node.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/apb_interrupt_cntrl.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/common_cells.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi_node.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice_dc.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/timer_unit.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_div_sqrt_mvp.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/fpnew.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/jtag_pulp.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/riscv.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/ibex.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/scm.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/generic_FLL.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/tech_cells_generic.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_core.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_uart.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2c.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2s.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_qspi.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_sdio.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_camera.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_filter.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/udma_external_per.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-ctrl.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-stream.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-mac-engine.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/riscv-dbg.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_soc.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi2mem.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi2per.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/per2axi.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/axi_size_conv.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_interconnect.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/event_unit_flex.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/mchan.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/hier-icache.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/icache-intc.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/icache_mp_128_pf.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/icache_private.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_peripherals.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_interco.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_cluster.mk build
	@make --no-print-directory -f $(mkfile_path)/ips/tbtools.mk build

lib:
	@make --no-print-directory -f $(mkfile_path)/ips/L2_tcdm_hybrid_interco.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/adv_dbg_if.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb2per.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb_adv_timer.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb_fll_if.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb_gpio.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb_node.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/apb_interrupt_cntrl.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/common_cells.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi_node.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice_dc.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/timer_unit.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_div_sqrt_mvp.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/fpnew.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/jtag_pulp.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/riscv.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/ibex.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/scm.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/generic_FLL.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/tech_cells_generic.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_core.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_uart.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2c.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2s.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_qspi.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_sdio.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_camera.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_filter.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/udma_external_per.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-ctrl.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-stream.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-mac-engine.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/riscv-dbg.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_soc.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi2mem.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi2per.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/per2axi.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/axi_size_conv.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_interconnect.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/event_unit_flex.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/mchan.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/hier-icache.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/icache-intc.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/icache_mp_128_pf.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/icache_private.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_peripherals.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_interco.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_cluster.mk lib
	@make --no-print-directory -f $(mkfile_path)/ips/tbtools.mk lib

clean:
	@make --no-print-directory -f $(mkfile_path)/ips/L2_tcdm_hybrid_interco.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/adv_dbg_if.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb2per.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb_adv_timer.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb_fll_if.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb_gpio.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb_node.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/apb_interrupt_cntrl.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/common_cells.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi_node.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi_slice_dc.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/timer_unit.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_div_sqrt_mvp.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/fpnew.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/jtag_pulp.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/riscv.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/ibex.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/scm.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/generic_FLL.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/tech_cells_generic.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_core.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_uart.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2c.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_i2s.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_qspi.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_sdio.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_camera.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_filter.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/udma_external_per.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-ctrl.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-stream.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/hwpe-mac-engine.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/riscv-dbg.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_soc.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi2mem.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi2per.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/per2axi.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/axi_size_conv.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_interconnect.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/event_unit_flex.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/mchan.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/hier-icache.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/icache-intc.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/icache_mp_128_pf.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/icache_private.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/cluster_peripherals.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/fpu_interco.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/pulp_cluster.mk clean
	@make --no-print-directory -f $(mkfile_path)/ips/tbtools.mk clean

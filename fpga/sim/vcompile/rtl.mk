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
	@make --no-print-directory -f $(mkfile_path)/rtl/tb.mk build
	@make --no-print-directory -f $(mkfile_path)/rtl/vip.mk build
	@make --no-print-directory -f $(mkfile_path)/rtl/pulpemu.mk build
	@make --no-print-directory -f $(mkfile_path)/rtl/pulp.mk build

lib:
	@make --no-print-directory -f $(mkfile_path)/rtl/tb.mk lib
	@make --no-print-directory -f $(mkfile_path)/rtl/vip.mk lib
	@make --no-print-directory -f $(mkfile_path)/rtl/pulpemu.mk lib
	@make --no-print-directory -f $(mkfile_path)/rtl/pulp.mk lib

clean:
	@make --no-print-directory -f $(mkfile_path)/rtl/tb.mk clean
	@make --no-print-directory -f $(mkfile_path)/rtl/vip.mk clean
	@make --no-print-directory -f $(mkfile_path)/rtl/pulpemu.mk clean
	@make --no-print-directory -f $(mkfile_path)/rtl/pulp.mk clean

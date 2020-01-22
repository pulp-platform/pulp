#!/bin/bash
tag=$(git describe --abbrev=0 --tags --exact-match 2> /dev/null)
if [ $? != 0 ]; then
  commit_hash=`git rev-parse --short HEAD`
  branch_name=`git rev-parse --abbrev-ref HEAD`
  name=emu-${branch_name}-${commit_hash}.bit.bin
else
  name=emu-${tag}.bit.bin
fi
echo $name


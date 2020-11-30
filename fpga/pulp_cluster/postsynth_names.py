#!/usr/bin/env python
import sys

with open("pulp_cluster_funcsim.v", "rb") as f:
    f_s = f.readlines()

with open("pulp_cluster_funcsim.v", "rb") as f:
    f_str = f.read()

module_list = []

for line in f_s:
    lsplit = line.split()
    try:
        if lsplit[0] == "module" and lsplit[1] != "pulp_cluster":
            module_list.append(lsplit[1])
    except IndexError:
        continue

print "Replacing postsynthesis names"
for mod in module_list:
    # print "   %s" % mod
    f_str = f_str.replace("%s "  % mod, "pulp_cluster_postsynth_%s "  % mod)
    f_str = f_str.replace("%s\n" % mod, "pulp_cluster_postsynth_%s\n" % mod)

with open("pulp_cluster_postsynt.v", "wb") as f:
    f.write(f_str)


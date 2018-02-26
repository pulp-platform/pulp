#!/usr/bin/env python3
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2016-2018 ETH Zurich, University of Bologna.
# All rights reserved.

# switch to "git@github.com" if you have an SSH public key deployed on GitHub
# and you want to push things there
DEFAULT_SERVER = "https://github.com"

#################################
## DO NOT EDIT BELOW THIS LINE ##
#################################

import sys,os,subprocess

devnull = open(os.devnull, 'wb')

class tcolors:
    OK      = '\033[92m'
    WARNING = '\033[93m'
    ERROR   = '\033[91m'
    ENDC    = '\033[0m'

def execute(cmd, silent=False):
    if silent:
        stdout = devnull
    else:
        stdout = None
    return subprocess.call(cmd.split(), stdout=stdout)

def execute_out(cmd, silent=False):
    p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    out, err = p.communicate()
    return out

# download latest IPApproX tools in ./ipstools and import them
if os.path.exists("ipstools") and os.path.isdir("ipstools"):
    cwd = os.getcwd()
    os.chdir("ipstools")
    execute("git pull", silent=True)
    os.chdir(cwd)
    import ipstools
else:
    execute("git clone https://github.com/pulp-platform/IPApproX ipstools")
    import ipstools


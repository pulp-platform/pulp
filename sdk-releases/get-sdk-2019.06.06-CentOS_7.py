#!/usr/bin/env python3

# This file has been auto-generated and can be used for downloading the SDK it has
# been generated for.

import os
import tarfile
import os.path
import argparse


src="59b44701b6ac8390a97936cbd049256fc2917212"

artefacts=[
  ["https://iis-artifactory.ee.ethz.ch/artifactory/release/CentOS_7/pulp/sdk/mainstream/ece475907719cc96278ee907e48c2b801994a75f/0/sdk.tar.bz2", "pkg/sdk/2019.06.06"],
  ["https://iis-artifactory.ee.ethz.ch/artifactory/release/CentOS_7/pulp/pulp_riscv_gcc/mainstream/1.0.13/0/pulp_riscv_gcc.tar.bz2", "pkg/pulp_riscv_gcc/1.0.13"]
]

exports=[
  ["PULP_SDK_HOME", "$PULP_PROJECT_HOME/pkg/sdk/2019.06.06"],
  ["PULP_SDK_INSTALL", "$PULP_SDK_HOME/install"],
  ["PULP_SDK_WS_INSTALL", "$PULP_SDK_HOME/install/ws"],
  ["PULP_RISCV_GCC_TOOLCHAIN_CI", "$PULP_PROJECT_HOME/pkg/pulp_riscv_gcc/1.0.13"],
  ["CROSS_COMPILE", "$PULP_PROJECT_HOME/pkg/pulp_riscv_gcc/1.0.13/bin/riscv32-unknown-elf-"],
  ["PULP_RISCV_GCC_VERSION", "3"],
  ["ZEPHYR_GCC_VARIANT", "cross-compile"]
]

sourceme=[
  ["$PULP_SDK_HOME/env/setup.sh", "$PULP_SDK_HOME/env/setup.csh"]
]

pkg=["sdk", "2019.06.06"]

parser = argparse.ArgumentParser(description='PULP downloader')

parser.add_argument('command', metavar='CMD', type=str, nargs='*',
                   help='a command to be execute')

parser.add_argument("--path", dest="path", default=None, help="Specify path where to install packages and sources")

args = parser.parse_args()

if len(args.command ) == 0:
    args.command = ['get']

if args.path != None:
    path = os.path.expanduser(args.path)
    if not os.path.exists(path):
        os.makedirs(path)
    os.chdir(path)

for command in args.command:

    if command == 'get' or command == 'download':

        dir = os.getcwd()

        if command == 'get':
            if not os.path.exists('pkg'): os.makedirs('pkg')

            os.chdir('pkg')

        for artefactDesc in artefacts:
            artefact = artefactDesc[0]
            path = os.path.join(dir, artefactDesc[1])
            urlList = artefact.split('/')
            fileName = urlList[len(urlList)-1]

            if command == 'download' or not os.path.exists(path):

                if os.path.exists(fileName):
                    os.remove(fileName)

                if os.system('wget --no-check-certificate %s' % (artefact)) != 0:
                    exit(-1)

                if command == 'get':
                    os.makedirs(path)
                    t = tarfile.open(os.path.basename(artefact), 'r')
                    t.extractall(path)
                    os.remove(os.path.basename(artefact))

        os.chdir(dir)

    if command == 'get' or command == 'download' or command == 'env':

        if not os.path.exists('env'):
            os.makedirs('env')

        filePath = 'env/env-%s-%s.sh' % (pkg[0], pkg[1])
        with open(filePath, 'w') as envFile:
            #envFile.write('export PULP_ENV_FILE_PATH=%s\n' % os.path.join(os.getcwd(), filePath))
            #envFile.write('export PULP_SDK_SRC_PATH=%s\n' % os.environ.get("PULP_SDK_SRC_PATH"))
            envFile.write('export %s=%s\n' % ('PULP_PROJECT_HOME', os.getcwd()))
            for export in exports:
                envFile.write('export %s=%s\n' % (export[0], export[1].replace('$PULP_PROJECT_HOME', os.getcwd())))
            for env in sourceme:
                envFile.write('source %s\n' % (env[0].replace('$PULP_PROJECT_HOME', os.getcwd())))
            #envFile.write('if [ -e "$PULP_SDK_SRC_PATH/init.sh" ]; then source $PULP_SDK_SRC_PATH/init.sh; fi')

        #filePath = 'env/env-%s-%s.csh' % (pkg[0], pkg[1])
        #with open(filePath, 'w') as envFile:
        #    envFile.write('setenv PULP_ENV_FILE_PATH %s\n' % os.path.join(os.getcwd(), filePath))
        #    envFile.write('setenv PULP_SDK_SRC_PATH %s\n' % os.environ.get("PULP_SDK_SRC_PATH"))
        #    for env in envFileStrCsh:
        #        envFile.write('%s\n' % (env.replace('@PULP_PKG_HOME@', os.getcwd())))
        #    envFile.write('if ( -e "$PULP_SDK_SRC_PATH/init.sh" ) then source $PULP_SDK_SRC_PATH/init.sh; endif')

    if command == 'src':

        if os.path.exists('.git'):
            os.system('git checkout %s' % (src))
        else:
            os.system('git init .')
            os.system('git remote add -t \* -f origin git@kesch.ee.ethz.ch:pulp-sw/pulp_pipeline.git')
            os.system('git checkout %s' % (src))


#!/bin/bash

set -e

echo ${POOL_USER:?'run this script with `POOL_USER` env variable'} >/dev/null
echo ${WORKER_NAME:?'run this script with `WORKER_NAME` env variable'} >/dev/null
echo ${WORKER_PASSWORD:?'run this script with `WORKER_PASSWORD` env variable'} >/dev/null

if [ "`whoami`" != "root" ]; then
  echo "this script requires superuser authority to setup cpuminer and invoker"
  exit 1
fi

################
#Setup me
################

wget -q https://raw.githubusercontent.com/dolpen/setup_zny_miner/dolpen/setup_dolpen.sh -O - | sh

################
#Setup cpuminer
################

cd /root/
wget -q https://raw.githubusercontent.com/dolpen/setup_zny_miner/develop/setup_miner.sh -O - | sh

################
#Setup invoker
################

cd /root/
wget -q https://raw.githubusercontent.com/dolpen/setup_zny_miner/develop/setup_invoker.sh -O - | sh

################
#Set variables
################

sed -i "s/POOL_USER=\"dolpen\"/POOL_USER=\"$POOL_USER\"/" /root/invoke.sh
sed -i "s/POOL_WORKER=\"dummy\"/POOL_WORKER=\"$WORKER_NAME\"/" /root/invoke.sh
sed -i "s/POOL_PASSWORD=\"dummy\"/POOL_PASSWORD=\"$WORKER_PASSWORD\"/" /root/invoke.sh


echo "# Welcome to minerd! ####################################"
echo
echo "## System information"
cat /proc/cpuinfo | grep "model name"
echo
echo "## Compile options"

CC="gcc"
OPT="-march=native"
NATIVE=$(echo | ${CC} -E -v ${OPT} - 2>&1 | grep cc1)
NOARCH=$(echo | ${CC} -E -v - 2>&1 | grep cc1)

for native in ${NATIVE} ; do
        FOUND=0
        for noarch in ${NOARCH} ; do
                if [ "${native}" = "${noarch}" -a "${native}" != "${OPT}" ] ; then
                        FOUND=1
                        break
                fi
        done
        if [ ${FOUND} -eq 0 ] ; then
                echo -n "${native} "
        fi
done
echo

sh /root/invoke.sh


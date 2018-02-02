#!/bin/bash

set -e

if [ "$REPOS" = "" ]; then
  echo "check REPOS variable";
exit 1

for i in `ps aux | grep minerd | grep -v grep | grep -v SCREEN | gawk '{print $2}'`
do
  kill $i;
done

################
#Setup cpuminer
################

cd /root/
wget -q https://raw.githubusercontent.com/dolpen/setup_zny_miner/develop/setup_drill.sh -O - | REPOS=$REPOS sh

sh /root/invoke.sh

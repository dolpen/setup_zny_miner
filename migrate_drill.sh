#!/bin/bash

set -e

if [ "$REPOS" = "" ]; then
  echo "check REPOS variable";
exit 1

for i in `ps aux | grep minerd | grep -v grep | grep -v SCREEN | gawk '{print $2}'`
do
  kill $i;
done

cd /opt
rm -rf cpuminer
git clone $REPOS
cd cpuminer
sh ./autogen.sh
sh ./configure CFLAGS="-O3 -march=native -mtune=native -funroll-loops -fomit-frame-pointer"
make clean
make

sh /root/invoke.sh

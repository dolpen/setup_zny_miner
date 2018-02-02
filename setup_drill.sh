#!/bin/bash
# do as root

if [ "$REPOS" = "" ]; then
  echo "check REPOS variable";
exit 1

yum -y groupinstall "Development Tools"
yum -y install epel-release git screen
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
yum -y install jansson-devel libcurl-devel
cd /opt
rm -rf cpuminer
git clone $REPOS
cd cpuminer
sh ./autogen.sh
sh ./configure CFLAGS="-O3 -march=native -funroll-loops -fomit-frame-pointer"
make

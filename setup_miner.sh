#!/bin/bash
# do as root

yum -y groupinstall "Development Tools"
yum -y install epel-release git screen
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
yum -y install jansson-devel libcurl-devel
cd /opt

## install minerd / yescrypt 0.5 (bitzeny)
git clone https://github.com/macchky/cpuminer.git
cd cpuminer
sh ./autogen.sh
sh ./configure CFLAGS="-O3 -march=native -funroll-loops -fomit-frame-pointer"
make

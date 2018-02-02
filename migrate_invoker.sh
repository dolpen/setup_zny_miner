#!/bin/bash

################
#Setup invoker
################

for i in `ps aux | grep minerd | grep -v grep | grep -v SCREEN | gawk '{print $2}'`
do
  kill $i;
done

cd /root/
wget -q https://raw.githubusercontent.com/dolpen/setup_zny_miner/develop/setup_invoker.sh -O - | POOL_STARTUM=$POOL_STARTUM POOL_USER=$POOL_USER WORKER_NAME=$WORKER_NAME WORKER_PASSWORD=$WORKER_PASSWORD sh

sh /root/invoke.sh

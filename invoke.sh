#!/bin/bash

# num of core
LIMIT=1

MINER_PATH="/opt/cpuminer"
MINER_PROC="minerd"

# please rewrite
POOL_STARTUM="stratum+tcp://stratum.misosi.ru:16002"
POOL_USER="dolpen"
POOL_WORKER="dummy"
POOL_PASSWORD="dummy"

if [ "$POOL_USER" = "" ]; then
  echo "check POOL_USER variable";
  exit 1
fi
if [ "$POOL_WORKER" = "" ]; then
  echo "check POOL_WORKER variable";
  exit 1
fi
if [ "$POOL_PASSWORD" = "" ]; then
  echo "check POOL_PASSWORD variable";
  exit 1
fi


MINER_PARAMS="-a yescrypt -t $LIMIT -o $POOL_STARTUM -u $POOL_USER.$POOL_WORKER -p $POOL_PASSWORD"
MINER_INVOCATION="$MINER_PATH/$MINER_PROC $MINER_PARAMS"

echo "find old processes..."
for i in `ps aux | grep $MINER_PROC | grep -v grep | grep -v SCREEN | gawk '{print $2}'`
do
    TIME=`ps -o lstart --noheader -p $i`;
    START=`date +%s -d "$TIME"`;
    NOW=`date +%s`;
    PASSTIME=`expr $NOW - $START`;
    if [ $PASSTIME -gt 86400 ]; then
        kill $i;
        echo "kill $i at "`date`;
    fi
done


echo "checking process..."
count=`ps aux | grep $MINER_PROC | grep -v grep | grep -v SCREEN | wc -l`
if [ $count = 0 ]; then
    echo "starting new process..."
    echo "$MINER_INVOCATION"
    screen -AmdS miner $MINER_INVOCATION
    echo "started."
else
    echo "found running process."
fi

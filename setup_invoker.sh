#!/bin/bash

if [ "$POOL_STARTUM" = "" ]; then
  echo "check POOL_STARTUM variable";
  exit 1
fi
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

# now bit for mask
CPU_FLAG=1
# of physical cpu cores
CPU_PHYS=0
# affinity mask (only physical core works)
CPU_MASK=0

CPU_INFO=`grep "core id" /proc/cpuinfo | sed -e "s/core\sid\s\t:\s//"`
while read cid; do
  if [ ${cid} = "0" ]; then # main thread (non HT/SMT)
    CPU_MASK=`expr $CPU_MASK + $CPU_FLAG`
    CPU_PHYS=`expr $CPU_PHYS + 1`
  fi
  CPU_FLAG=`expr $CPU_FLAG + $CPU_FLAG`
done <<< "`echo -e "$CPU_INFO"`"

cat << EOT > /root/invoke.sh

#!/bin/bash

# cpu setting
CPU_LIMIT=$CPU_PHYS
CPU_AFFINITY=$CPU_MASK

# process setting
MINER_PATH="/opt/cpuminer"
MINER_PROC="minerd"

# pool setting
POOL_STARTUM="$POOL_STARTUM"
POOL_USER="$POOL_USER"
POOL_WORKER="$POOL_WORKER"
POOL_PASSWORD="$POOL_PASSWORD"

MINER_PARAMS="-a yescrypt -t \$CPU_LIMIT --cpu-affinity \$CPU_AFFINITY -o \$POOL_STARTUM -u \$POOL_USER.\$POOL_WORKER -p \$POOL_PASSWORD"
MINER_INVOCATION="\$MINER_PATH/\$MINER_PROC \$MINER_PARAMS"

echo "find old processes..."
for i in \`ps aux | grep \$MINER_PROC | grep -v grep | grep -v SCREEN | gawk '{print \$2}'\`
do
    TIME=\`ps -o lstart --noheader -p \$i\`;
    START=\`date +%s -d "\$TIME"\`;
    NOW=\`date +%s\`;
    PASSTIME=`expr \$NOW - \$START`;
    if [ \$PASSTIME -gt 86400 ]; then
        kill $i;
        echo "kill \$i at "\`date\`;
    fi
done

echo "checking process..."
count=\`ps aux | grep \$MINER_PROC | grep -v grep | grep -v SCREEN | wc -l\`
if [ \$count = 0 ]; then
    echo "starting new process..."
    echo "\$MINER_INVOCATION"
    screen -AmdS miner \$MINER_INVOCATION
    echo "started."
else
    echo "found running process."
fi

EOT

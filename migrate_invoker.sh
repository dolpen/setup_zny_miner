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

for i in `ps aux | grep minerd | grep -v grep | grep -v SCREEN | gawk '{print $2}'`
do
  kill $i;
done

CPU_INFO=`grep "core id" /proc/cpuinfo | sed -e "s/core\sid\s\t:\s//"`
# now bit for mask
CPU_FLAG=1
# of all cpu cores (includes HT/SMT)
CPU_VIRT=0
# of physical cpu cores
CPU_PHYS=0
# affinity mask
CPU_MASK=0
CPU_USES=0

# count cores
while read cid; do
  if [ ${cid} = "0" ]; then
    CPU_PHYS=`expr $CPU_PHYS + 1`
  fi
  CPU_VIRT=`expr $CPU_VIRT + 1`
done <<< "`echo -e "$CPU_INFO"`"
# calc cpu affinity(works only core id = 0, limits all core - 1)
while read cid; do
  if [ ${cid} = "0" ]; then # main thread (non HT/SMT)
    CPU_USES=`expr $CPU_USES + 1`
    if [ ${CPU_VIRT} -gt ${CPU_USES} ]; then
      CPU_MASK=`expr $CPU_MASK + $CPU_FLAG`
    fi
  fi
  CPU_FLAG=`expr $CPU_FLAG + $CPU_FLAG`
done <<< "`echo -e "$CPU_INFO"`"
if [ ${CPU_USES} -eq ${CPU_VIRT} ]; then
  CPU_USES=`expr $CPU_USES - 1`
fi
cat << EOT > /root/invoke.sh
#!/bin/bash
# cpu setting
CPU_LIMIT=$CPU_USES
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
#MINER_PARAMS="-a yescrypt -t 1 --cpu-affinity 1 -o \$POOL_STARTUM -u \$POOL_USER.\$POOL_WORKER -p \$POOL_PASSWORD"
MINER_INVOCATION="\$MINER_PATH/\$MINER_PROC \$MINER_PARAMS"
echo "find old processes..."
for i in \`ps aux | grep \$MINER_PROC | grep -v grep | grep -v SCREEN | gawk '{print \$2}'\`
do
    TIME=\`ps -o lstart --noheader -p \$i\`
    START=\`date +%s -d "\$TIME"\`
    NOW=\`date +%s\`
    PASSTIME=\`expr \$NOW - \$START\`
    if [ \$PASSTIME -gt 86400 ]; then
        kill \$i
        echo "kill \$i at "\`date\`
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

sh /root/invoke.sh

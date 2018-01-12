#!/bin/bash

cd /root

wget https://raw.githubusercontent.com/dolpen/setup_zny_miner/develop/invoke.sh

cat << EOT > /var/spool/cron/root
*/10 * * * * sh /root/invoke.sh

EOT

service crond restart


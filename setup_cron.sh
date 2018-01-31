#!/bin/bash

cat << EOT > /var/spool/cron/root
0 * * * * touch /tmp/write_test || /sbin/reboot
0 * * * * ping -W 1 -c 1 8.8.8.8 || /sbin/reboot
*/10 * * * * sh /root/invoke.sh > /dev/null

EOT

chmod 600 /var/spool/cron/root
service crond restart


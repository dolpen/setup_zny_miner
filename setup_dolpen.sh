#!/bin/bash

cat << EOT > /etc/sudoers.d/base
dolpen ALL=(ALL) ALL
%dolpen ALL=(ALL) NOPASSWD: ALL
Defaults:dolpen !requiretty
EOT

chmod 440 /etc/sudoers.d/base
useradd dolpen

mkdir /home/dolpen/.ssh
chown dolpen:dolpen /home/dolpen/.ssh
chmod 755 /home/dolpen/.ssh

cat << EOT > /home/dolpen/.ssh/authorized_keys
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM00pdbmU5T0w1FNKhXvRxFOY0Uj/dyvE2s63PlJAXaGwZo/WApia1DCnXB6zpNQB5xreb5jNdRR3fpnJmkrQ3Y= dolpen@dolpen.net
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAje5AzaJgX02bMD/tuRhyqYwDXsyMg0c1NrxlQWRXGb41hViGsbQltQRGJo8rbVTNZJfMEUBmj0PtrwSp18q+avoSuNDNlDn8MmoLuYIMKIVCZuNvJWz5OQ5bVWA5hUoWq58Gp1/3ZQ3Oj9/owRelCwLXf9aohdhsYthXuEGfhsqAGnA7BSV9I29XF1YWI/xmY/hVVqlIFUBkziu9YWLhU8E35f+UBM8vX2YtjqaeXiQPaGz5RIF7SXsCi3fSj3F/jFKaCHbMtPcK1voqpiRveOm36HayCGmMlniVpvPQ8czREKrrjE7cRoxB87b5S4B+7DcLE9gKnrijoC9k/UKPKw==
EOT

chown dolpen:dolpen /home/dolpen/.ssh/authorized_keys
chmod 644 /home/dolpen/.ssh/authorized_keys

sed -i 's/#Port\ 22/Port\ 11422/' /etc/ssh/sshd_config
service sshd restart

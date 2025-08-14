#!/bin/bash -eux

echo "==> remove SSH keys used for building"
rm -f /home/centos/.ssh/authorized_keys
rm -f /root/.ssh/authorized_keys

echo "==> Clear out machine id"
truncate -s 0 /etc/machine-id

echo "==> Remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "==> Truncate any logs that have built up during the install"
find /var/log -type f -exec truncate -s 0 {} \;

echo "==> Cleanup bash history"
rm -f ~/.bash_history

echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "==> remove /var/cache"
find /var/cache -type f -exec rm -f {} \;

echo "==> Cleanup yum cache"
yum -y autoremove
yum clean all
rm -rf /var/cache/yum/*

echo "==> force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "==> Clear the history so our install isn't there"
rm -f /root/.wget-hsts

export HISTSIZE=0
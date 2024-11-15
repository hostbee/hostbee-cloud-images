#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/akatsukiro/centos7-eol-repo-fix/main/CentOS-Base.repo

echo "==> updating yum cache"
sudo yum makecache -q

echo "==> upgrade yum packages"
sudo yum update -y -q

echo "==> installing common packages"
sudo yum install -y -q qemu-guest-agent wget vim

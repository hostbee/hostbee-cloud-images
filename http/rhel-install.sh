#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
if [ "$CN_FLAG" == "true" ]; then
    echo "use CN sources"
    sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
    sudo sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
else
    echo "use global sources"
    sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/akatsukiro/centos7-eol-repo-fix/main/CentOS-Base.repo
fi

echo "==> updating yum cache"
sudo yum makecache -q

echo "==> upgrade yum packages"
sudo yum update -y -q

echo "==> installing common packages"
sudo yum install -y -q qemu-guest-agent wget vim

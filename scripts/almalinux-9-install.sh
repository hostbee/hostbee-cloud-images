#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
if [ "$CN_FLAG" == "true" ]; then
    echo "use CN sources"
    sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#\s*baseurl=https://repo.almalinux.org/almalinux|baseurl=https://mirrors.nju.edu.cn/almalinux|g' \
        -i.bak \
        /etc/yum.repos.d/almalinux*.repo
else
    echo "use default sources"
fi

echo "==> updating yum cache"
sudo yum makecache

echo "==> upgrade yum packages"
sudo yum update -y

echo "==> installing common packages"
sudo yum install -y qemu-guest-agent wget vim

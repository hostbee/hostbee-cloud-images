#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
if [ "$CN_FLAG" == "true" ]; then
    echo "use CN sources"
    sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources
    sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
else
    echo "use default sources"
fi

echo "==> updating apt cache"
sudo apt-get update

echo "==> upgrade apt packages"
sudo apt-get upgrade -y

echo "==> installing qemu-guest-agent"
sudo apt-get install -y qemu-guest-agent

echo "==> installing common packages"
sudo apt-get install -y curl wget git unzip vim

#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
if [ "$CN_FLAG" == "true" ]; then
    echo "use CN sources"
    sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

    sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian.list
    sudo sed -i -e 's|security.debian.org/\? |security.debian.org/debian-security |g' \
                -e 's|security.debian.org|mirrors.ustc.edu.cn|g' \
                -e 's|deb.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' \
                /etc/apt/mirrors/debian-security.list
    sudo sed -i '/^ - package-update-upgrade-install$/d' /etc/cloud/cloud.cfg
    sudo sed -i '/^ - apt-configure$/d' /etc/cloud/cloud.cfg
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

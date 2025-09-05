#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> change repo souces"
if [ "$CN_FLAG" == "true" ]; then
    echo "use CN sources"
    CN_MIRROR="mirrors.ustc.edu.cn"
    MAIN_MIRROR_FILE="/etc/apt/mirrors/debian.list"
    SECURITY_MIRROR_FILE="/etc/apt/mirrors/debian-security.list"
    sudo sed -i "s/deb.debian.org/${CN_MIRROR}/g" "$MAIN_MIRROR_FILE"
    sudo sed -i -e "s|security.debian.org/debian-security|${CN_MIRROR}/debian-security|g" \
                -e "s|deb.debian.org/debian-security|${CN_MIRROR}/debian-security|g" \
                -e "s|security.debian.org|${CN_MIRROR}|g" "$SECURITY_MIRROR_FILE"
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

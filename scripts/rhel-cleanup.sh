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

echo "==> Creating systemd service to remove builder user immediately on boot"
cat > /etc/systemd/system/remove-builder-user.service << 'EOF'
[Unit]
Description=Remove builder user on boot
Before=sshd.service

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c '\
    if id "builder" >/dev/null 2>&1; then \
        echo "Removing builder user..."; \
        pkill -u builder || true; \
        userdel -rf builder; \
        systemctl disable remove-builder-user.service; \
        rm -f /etc/systemd/system/remove-builder-user.service; \
    fi'

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable remove-builder-user.service

export HISTSIZE=0

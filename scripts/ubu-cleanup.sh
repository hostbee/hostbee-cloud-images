#!/bin/bash -eux
echo "==> remove SSH keys used for building"
rm -f /home/ubuntu/.ssh/authorized_keys
rm -f /root/.ssh/authorized_keys

echo "==> Clear out machine id"
truncate -s 0 /etc/machine-id

echo "==> Remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "==> Truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "==> Cleanup bash history"
rm -f ~/.bash_history

echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "==> remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "==> Cleanup apt"
apt-get -y autoremove
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "==> force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "==> Clear the history so our install isn't there"
rm -f /root/.wget-hsts

echo "==> Creating init script to remove builder user immediately on boot"
cat >/etc/init.d/remove-builder-user <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          remove-builder-user
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    ssh
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Remove builder user
### END INIT INFO

case "$1" in
  start)
    if id "builder" >/dev/null 2>&1; then
      echo "Removing builder user..."
      pkill -u builder || true
      userdel -rf builder
      update-rc.d remove-builder-user remove
      rm -f /etc/init.d/remove-builder-user
    fi
    ;;
  *)
    exit 0
    ;;
esac
exit 0
EOF

chmod +x /etc/init.d/remove-builder-user
update-rc.d remove-builder-user defaults 10

export HISTSIZE=0

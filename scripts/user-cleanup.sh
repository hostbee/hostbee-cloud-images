#!/bin/bash -eux

echo "==> Write cleanup.sh for final cleanup"

cat > /root/cleanup.sh <<EOL
#!/bin/bash -eux

echo "==> Remove users from /etc/passwd and /etc/shadow"

USER_TO_REMOVE=(ec2-user fedora rocky almalinux debian ubuntu centos rhel builder)
for user in "${USER_TO_REMOVE[@]}"; do
    sed -i "/$user/d" /etc/passwd
    sed -i "/$user/d" /etc/shadow
done

echo "==> Remove cleanup.sh"
rm -f /root/cleanup.sh

echo "==> Shutdown"
shutdown -P now

EOL

chmod 777 /root/cleanup.sh

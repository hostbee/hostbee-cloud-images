#!/bin/bash -eux

USER_TO_REMOVE="builder ec2-user fedora rocky almalinux debian ubuntu centos rhel"

echo "==> Remove users from /etc/passwd and /etc/shadow"

for user in $USER_TO_REMOVE; do
    sed -i "/$user/d" /etc/passwd
    sed -i "/$user/d" /etc/shadow
done

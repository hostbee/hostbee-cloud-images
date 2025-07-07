#cloud-config
ssh_pwauth: false
disable_root: false

users:
  - name: builder
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
  - name: debian
    state: absent
    remove: yes
  - name: ubuntu
    state: absent
    remove: yes
  - name: centos
    state: absent
    remove: yes
  - name: almalinux
    state: absent
    remove: yes
  - name: rocky
    state: absent
    remove: yes
  - name: fedora
    state: absent
    remove: yes
  - name: ec2-user
    state: absent
    remove: yes

version: 2
network:
  version: 2
  renderer: auto
  ethernets:
    eth0:
      dhcp4: yes
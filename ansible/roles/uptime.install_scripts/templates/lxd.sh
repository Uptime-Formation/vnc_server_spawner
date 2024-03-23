#!/bin/bash

set -eux

cd /tmp

# sudo apt install -y sshpass lxc
sudo apt install -y lxc

mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc

sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-daily.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/daily
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'

sudo apt update
sudo apt install -y incus

cat /opt/lxd_config.yaml | incus admin init --preseed

set +eux

incus launch images:centos/7/amd64 centos1 
incus launch images:ubuntu/focal/amd64 ubu1

sleep 5 # wait for the network to boot in containers

set -eux

incus exec centos1 -- yum update -y
incus exec centos1 -- yum install -y openssh-server sudo
incus exec centos1 -- systemctl start sshd
incus exec centos1 -- sed -i 's@\(%wheel.*\)ALL@\1 NOPASSWD: ALL@' /etc/sudoers

set +eux

incus exec centos1 -- useradd -m -s /bin/bash -G wheel stagiaire
set -eux
incus exec centos1 -- bash -c "(echo 'devops101'; echo 'devops101') | passwd stagiaire --force"
# sshpass -p "devops101" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_stagiaire.pub stagiaire@$(incus list -c4 --format csv centos1 | cut -d' ' -f1)
ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_stagiaire.pub stagiaire@$(incus list -c4 --format csv centos1 | cut -d' ' -f1)
incus publish --force --alias centos_ansible centos1 && incus delete --force centos1

incus exec ubu1 -- apt update
incus exec ubu1 -- apt install -y openssh-server sudo
incus exec ubu1 -- sed -i 's@\(%sudo.*\)ALL@\1 NOPASSWD: ALL@' /etc/sudoers
set +eux
incus exec ubu1 -- useradd -m -s /bin/bash -G sudo stagiaire
set -eux
incus exec ubu1 -- bash -c "(echo 'devops101'; echo 'devops101') | passwd stagiaire"
ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_stagiaire.pub stagiaire@$(incus list -c4 --format csv ubu1 | cut -d' ' -f1)
# sshpass -p "devops101" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_stagiaire.pub stagiaire@$(incus list -c4 --format csv ubu1 | cut -d' ' -f1)
incus publish --force --alias ubuntu_ansible ubu1 && incus delete --force ubu1
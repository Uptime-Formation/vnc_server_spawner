#!/bin/bash
set -eu

sudo apt update && sudo apt upgrade -y

sudo apt install -y git ansible wireguard openssh-server


# get your wg1.conf first from the teacher, put it in /etc/wireguard then
sudo systemctl start wg-quick@wg1.service
sudo systemctl enable wg-quick@wg1.service

cd ansible

# In host_vars/localhost change stagiaire (2 times) by your user name then:
sudo ansible-playbook playbooks/vnc_localhost.yml

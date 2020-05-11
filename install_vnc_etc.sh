#!/bin/bash

apt update
apt upgrade -y
apt install -y sudo vim htop

echo "#### Configure firewall for SSH"
systemctl enable ufw
ufw allow 22/tcp

echo "#### Install Ubuntu Desktop"
apt install -y ubuntu-desktop

echo "#### Install x11vnc"
apt install -y x11vnc


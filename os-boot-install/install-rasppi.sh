#!/bin/bash
# Copy files
# cp config.txt /boot/config.txt
# cp ssh /boot/ssh
# cp cmdline.txt /boot/cmdline.txt
# Update raspi
sudo apt-get update
sudo rpi-update
# disable swap
sudo dphys-swapfile swapoff
# install zram
sudo apt-get install -y zram-tools
echo "[TODO] Edit file : sudo nano /etc/default/zramswap"
echo "Uncomment line : **PERCENTAGE** and set to "
echo "`PERCENTAGE=50`"
#
sudo systemctl enable zramswap
sudo systemctl restart zramswap
grep zram /proc/swaps
# SET TIME ZONE :
sudo timedatectl set-timezone Europe/Paris
#
# Enabling legacy iptables on Raspbian Buster
#
sudo iptables -F
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
# sudo reboot
echo "*********************************"
echo "You may reboot now"
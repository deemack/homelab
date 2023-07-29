#!/bin/sh
sudo apt update && sudo apt upgrade 
sudo apt-get install virtualbox -y
wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb
git clone https://github.com/deemack/homelab.git
cd homelab
#vagrant init bento/ubuntu-22.04 
vagrant up
printf "%s" "Waiting for virtual machine to be ready"
while ! ping -c 1 -n -w 1 192.168.56.10 &> /dev/null
do
 printf "%c" "."
done
printf "\n%s\n" "Virtual machine is ready"

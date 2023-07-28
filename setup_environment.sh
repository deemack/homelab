#!/bin/sh
sudo apt update && sudo apt upgrade 
sudo apt-get install virtualbox -y
wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb
mkdir ~/homelab
cd ~/homelab
vagrant init bento/ubuntu-22.04 
vagrant up

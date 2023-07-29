#!/bin/sh
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
printf "{$GREEN}Updating and Upgrading Linux{$NC}"
sudo apt update && sudo apt upgrade -y

printf "{$GREEN}Installing git{$NC}"
sudo apt install git -y

printf "{$GREEN}Installing virtualbox{$NC}"
sudo apt-get install virtualbox -y

printf "{$GREEN}Installing Vagrant deb package{$NC}"
wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb

printf "{$GREEN}Cloning homelab repository{$NC}"
git clone https://github.com/deemack/homelab.git

printf "{$GREEN}Creating Anisble VM with vagrant{$NC}"
cd homelab
vagrant up
printf "%s" "{$YELLOW}Waiting for virtual machine to be ready{$NC}"
while ! ping -c 1 -n -w 1 192.168.56.10 &> /dev/null
do
 printf "%c" "{$YELLOW}.{$NC}"
done
printf "\n%s\n" "{$GREEN}Virtual machine is ready{$NC}"

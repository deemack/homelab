#!/bin/sh
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
printf "${GREEN}Updating and Upgrading Linux${NC}\n"
sudo apt update && sudo apt upgrade -y

printf "${GREEN}Installing sshpass${NC}\n"
sudo apt-get install sshpass -y

printf "${GREEN}Installing git${NC}\n"
sudo apt install git -y

printf "${GREEN}Installing virtualbox${NC}\n"
sudo apt-get install virtualbox -y

printf "${GREEN}Installing Vagrant deb package${NC}\n"
wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb
sudo rm ./vagrant_2.2.19_x86_64.deb

printf "${GREEN}Creating vagrant user${NC}\n"
sudo useradd -m -p $(openssl passwd -1 vagrant) vagrant

printf "${GREEN}Creating ssh key-pair for vagrant user${NC}\n"
sudo mkdir /home/vagrant/.ssh
yes '' | sudo ssh-keygen -f /home/vagrant/.ssh/beelink-ssh-key -N '' > /dev/null

printf "${GREEN}Copying public key to shared vagrant folder${NC}\n"
sudo cp /home/vagrant/.ssh/beelink-ssh-key.pub .

printf "${GREEN}Cloning homelab repository${NC}\n"
git clone https://github.com/deemack/homelab.git

printf "${GREEN}Creating Ansible VM with vagrant${NC}\n"
cd homelab
vagrant up
printf "${YELLOW}Waiting for virtual machine to be ready${NC}\n"
while ! ping -c 1 -n -w 1 192.168.56.10 &> /dev/null
do
 printf "${YELLOW}.${NC}\n"
done
printf "${GREEN}Virtual machine is ready${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "hostname"

printf "${GREEN}Copying public key from shared folder to virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo cp /vagrant/beelink-ssh-key.pub /home/vagrant/.ssh/beelink-ssh-key.pub"

printf "${GREEN}Installing Ansible to virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo apt-get install -y ansible -y"

printf "${GREEN}Adding host IP to hosts file on virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "cat <<EOF | sudo tee /home/vagrant/hosts
[homelab]
192.168.1.100
EOF"

printf "${GREEN}Testing ping/pong connection from virtual machine to host${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "ansible -i hosts all -m ping"



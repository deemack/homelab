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
sudo useradd -s /bin/bash -m -p $(openssl passwd -1 vagrant) vagrant

printf "${GREEN}Creating ssh key-pair for vagrant user on beelink${NC}\n"
sudo mkdir /home/vagrant/.ssh
yes '' | sudo ssh-keygen -f /home/vagrant/.ssh/beelink-ssh-key -N '' > /dev/null
sudo touch /home/vagrant/.ssh/known_hosts
sudo touch /home/vagrant/.ssh/authorized_keys

printf "${GREEN}Copying public key from host to shared vagrant folder${NC}\n"
sudo cp /home/vagrant/.ssh/beelink-ssh-key.pub .

printf "${GREEN}Creating Ansible VM with vagrant${NC}\n"
vagrant up

printf "${YELLOW}Waiting for virtual machine to be ready${NC}\n"
while ! ping -c 1 -n -w 1 192.168.56.10 &> /dev/null
do
 printf "${YELLOW}.${NC}\n"
done
printf "${GREEN}Virtual machine is ready${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "hostname"

printf "${YELLOW}Public keys Beelink to VM${NC}\n"
printf "${GREEN}Copying beelink public key file contents to virtual machine authorized_keys file${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo cat /vagrant/beelink-ssh-key.pub >> /home/vagrant/.ssh/authorized_keys"
printf "${GREEN}Copying beelink public key file contents to virtual machine known_hosts file${NC}\n"
#sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo cat /vagrant/beelink-ssh-key.pub >> /home/vagrant/.ssh/known_hosts"
sshpass -p vagrant ssh vagrant@192.168.56.10 "ssh-keyscan -H -p 22 -t ecdsa 192.168.1.100 >> ~/.ssh/known_hosts"

printf "${YELLOW}Public keys VM to Beelink${NC}\n"
printf "${GREEN}Copying virtual machine public key file to shared folder${NC}\n"
#sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant/vm-ssh-key.pub"
sshpass -p vagrant scp vagrant@192.168.56.10:/home/vagrant/.ssh/id_rsa.pub ./vm-ssh-key.pub
printf "${GREEN}Copying virtual machine public key file content to known_hosts file ${NC}\n"
cat ./vm-ssh-key.pub | sudo tee -a /home/vagrant/.ssh/known_hosts
printf "${GREEN}Copying virtual machine public key file content to authorized_keys file${NC}\n"
#cat ./vm-ssh-key.pub | sudo tee -a /home/vagrant/.ssh/authorized_keys
ssh-keyscan -H -p 22 -t ecdsa 192.168.56.10 | sudo tee -a /home/vagrant/.ssh/known_hosts

printf "${YELLOW}Setting ssh key ownerships and permissions${NC}\n"
printf "${GREEN}Beelink${NC}\n"
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chmod 600 /home/vagrant/.ssh/known_hosts
printf "${GREEN}VM${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo chown -R vagrant:vagrant /home/vagrant/.ssh"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo chmod 700 /home/vagrant/.ssh"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo chmod 600 /home/vagrant/.ssh/authorized_keys"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo chmod 600 /home/vagrant/.ssh/known_hosts"

printf "${GREEN}Installing Ansible to virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "sudo apt-get install -y ansible -y"

printf "${GREEN}Adding host IP to hosts file on virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "cat <<EOF | sudo tee /home/vagrant/hosts
[homelab]
192.168.1.100
EOF"

printf "${GREEN}Testing ping/pong connection from virtual machine to host${NC}\n"
sshpass -p vagrant ssh vagrant@192.168.56.10 "ansible -i hosts all -m ping"



#!/bin/sh
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BEELINK="192.168.1.100"
ANSIBLE_VM="192.168.56.10"
VAGRANT_MAJOR="2.3.7"
VAGRANT_VER="$VAGRANT_MAJOR-1"

printf "${GREEN}Add entry to fstab for SSD${NC}\n"
uuid=$(lsblk -no uuid /dev/sda)
fstab_entry="UUID=""$uuid"" /mnt/storage ntfs permissions,locale=en_US.utf8 0 2"
echo $fstab_entry | sudo tee -a /etc/fstab

printf "${GREEN}Updating hosts file on Beelink${NC}\n"
echo "$ANSIBLE_VM ansible" | sudo tee -a /etc/hosts
echo "$BEELINK beelink" | sudo tee -a /etc/hosts

printf "${GREEN}Updating and Upgrading Linux${NC}\n"
sudo apt update && sudo apt upgrade -y

printf "${GREEN}Installing python${NC}\n"
sudo apt-get install python3 -y

printf "${GREEN}Installing sshpass${NC}\n"
sudo apt-get install sshpass -y

printf "${GREEN}Installing git${NC}\n"
sudo apt install git -y

printf "${GREEN}Installing virtualbox${NC}\n"
sudo apt-get install virtualbox -y

printf "${GREEN}Installing Vagrant deb package${NC}\n"
wget https://releases.hashicorp.com/vagrant/${VAGRANT_MAJOR}/vagrant_${VAGRANT_VER}_amd64.deb
sudo apt install ./vagrant_${VAGRANT_VER}_amd64.deb
sudo rm ./vagrant_${VAGRANT_VER}_amd64.deb

printf "${GREEN}Creating vagrant user${NC}\n"
sudo useradd -s /bin/bash -m -p $(openssl passwd -1 vagrant) vagrant

printf "${GREEN}Creating ssh key-pair for vagrant user on beelink${NC}\n"
sudo mkdir /home/vagrant/.ssh
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
sudo -u vagrant bash -c "ssh-keygen -f ~/.ssh/id_rsa -N ''"
sudo touch /home/vagrant/.ssh/known_hosts
sudo touch /home/vagrant/.ssh/authorized_keys

printf "${GREEN}Copying public key from host to shared vagrant folder${NC}\n"
sudo cp /home/vagrant/.ssh/id_rsa.pub .

printf "${GREEN}Creating Ansible VM with vagrant${NC}\n"
vagrant up

printf "${YELLOW}Waiting for virtual machine to be ready${NC}\n"
while ! ping -c 1 -n -w 1 $ANSIBLE_VM &> /dev/null
do
 printf "${YELLOW}.${NC}\n"
done
printf "${GREEN}Virtual machine is ready${NC}\n"

printf "${GREEN}Updating known_hosts file on Beelink${NC}\n"
ssh-keyscan -H -p 22 -t ecdsa ansible >> /home/dave/.ssh/known_hosts

printf "${GREEN}Updating hosts file on VM${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "echo "$ANSIBLE_VM ansible" | sudo tee -a /etc/hosts"
sshpass -p vagrant ssh vagrant@ansible "echo "$BEELINK beelink" | sudo tee -a /etc/hosts"

printf "${YELLOW}Public keys Beelink to VM${NC}\n"
printf "${GREEN}Copying beelink public key file contents to virtual machine authorized_keys file${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "sudo cat /vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
printf "${GREEN}Copying beelink public key file contents to virtual machine known_hosts file${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "ssh-keyscan -H -p 22 -t ecdsa beelink >> ~/.ssh/known_hosts" >/dev/null

printf "${YELLOW}Public keys VM to Beelink${NC}\n"
printf "${GREEN}Copying virtual machine public key file to shared folder${NC}\n"
sshpass -p vagrant scp vagrant@ansible:/home/vagrant/.ssh/id_rsa.pub ./vm-ssh-key.pub
printf "${GREEN}Copying virtual machine public key file content to known_hosts file ${NC}\n"
ssh-keyscan -H -p 22 -t ecdsa ansible | sudo tee -a /home/vagrant/.ssh/known_hosts >/dev/null
printf "${GREEN}Copying virtual machine public key file content to authorized_keys file${NC}\n"
cat ./vm-ssh-key.pub | sudo tee -a /home/vagrant/.ssh/authorized_keys >/dev/null

printf "${YELLOW}Setting ssh key ownerships and permissions${NC}\n"
printf "${GREEN}Beelink${NC}\n"
sudo chown -R vagrant:vagrant /home/vagrant/
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chmod 600 /home/vagrant/.ssh/known_hosts
printf "${GREEN}VM${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "sudo chown -R vagrant:vagrant /home/vagrant/"
sshpass -p vagrant ssh vagrant@ansible "sudo chmod 700 /home/vagrant/.ssh"
sshpass -p vagrant ssh vagrant@ansible "sudo chmod 600 /home/vagrant/.ssh/authorized_keys"
sshpass -p vagrant ssh vagrant@ansible "sudo chmod 600 /home/vagrant/.ssh/known_hosts"

printf "${GREEN}Updating and Upgrading Linux on VM${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "sudo apt update && sudo apt upgrade -y"

printf "${GREEN}Upgrading Linux and installing latest Ansible to virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "sudo apt remove ansible -y"
sshpass -p vagrant ssh vagrant@ansible "sudo apt --purge autoremove -y"
sshpass -p vagrant ssh vagrant@ansible "sudo apt -y install software-properties-common -y"
sshpass -p vagrant ssh vagrant@ansible "sudo apt-add-repository ppa:ansible/ansible -y"
sshpass -p vagrant ssh vagrant@ansible "sudo apt install ansible -y"

printf "${GREEN}Installing ansible-galaxy collection: community.general${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "ansible-galaxy collection install community.general"

printf "${GREEN}Copy ansible folder from shared folder to home directory${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "sudo cp -r /vagrant/ansible ."

printf "${GREEN}Adding host IP to hosts file on virtual machine${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "cat <<EOF | sudo tee /home/vagrant/hosts
[homelab]
beelink
EOF"

printf "${GREEN}Testing ping/pong connection from virtual machine to host${NC}\n"
sshpass -p vagrant ssh vagrant@ansible "ansible -i hosts all -m ping"

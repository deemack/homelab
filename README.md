# homelab
* This project creates an ansible VM on your Server, so that it can be used to provision the Server.
* ssh via public keys is configured from the Server to the VM and vice versa, for the user 'vagrant:vagrant'
* Clone the repo, navigate into the homelab directory and run the setup_environment script:
----
      git clone https://github.com/deemack/homelab.git && cd homelab && sudo chmod +x setup_environment.sh && bash setup_environment.sh
----
* Once the installation has completed, run the following commands:
----
      sudo apt install python3-pip -y
      sudo usermod -aG sudo vagrant
      su vagrant
      ssh vagrant@ansible
      cd ansible
      ansible-playbook -i inventory playbooks/site.yml
      sudo usermod -a -G microk8s dave
      newgrp microk8s
      sudo apt-get install samba -y
      sudo nano /etc/samba/smb.conf
      
      add these lines to smb.conf
      [share]
        path = /mnt/storage
        writeable = yes
        browseable = yes
        public = yes
        create mask = 0644
        directory mask = 0755
        force directory mode = 2770
        

       sudo systemctl restart smbd
      
----
      
### Notes
- The ansible VM is set to have an IP of 192.168.56.10
- It is assumed the Server has an IP of 192.168.1.100
- VirtualBox is used as the VM manager

### Ansible Directory Structure
```
playbooks/
  roles/
    role1/
      tasks/
        main.yml
site.yml
```

### Accessing the Kubernetes Dashboard
* Run the following command on the Server hosting K8s  
----
    token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
    microk8s kubectl -n kube-system describe secret $token
----
* Navigate to \<ServerIP>:32075
* Use the token to log in

* You can also save this **cat /var/snap/microk8s/current/credentials/client.config** to file and use it to login as a **kubeconfig**


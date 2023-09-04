# homelab
* This project creates an ansible VM on your Physical Host, so that it can be used to provision the Physical Host.
* ssh via public keys is configured from the Physical Host to the VM and vice versa, for the user 'vagrant:vagrant'

* Install Ubuntu server to your Physical Host using a USB or PXE-Boot installation https://github.com/deemack/pxe
* Run the following command to clone the repo, navigate into the homelab directory and run the setup_environment script:
```
git clone https://github.com/deemack/homelab.git && cd homelab && sudo chmod +x setup_environment.sh && bash setup_environment.sh
```
### Notes
- The ansible VM is set to have an IP of 192.168.56.10
- It is assumed the Physical Host has an IP of 192.168.1.100
- VirtualBox is installed to the Physical Host and is used as the VM manager

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
* Run the following command on the Physical Host  
```
    token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
    microk8s kubectl -n kube-system describe secret $token
```
* Navigate to \<Physical Host IP>:32075
* Use the token to log in

* You can also save this **cat /var/snap/microk8s/current/credentials/client.config** to file and use it to login as a **kubeconfig**

### Restarting the minidlna service in the container to update the database.
* Run the following commands to kill the pod, and kubernetes will re-create it.
```
microk8s kubectl get pods -n dlna-ns
microk8s kubectl exec -it -n dlna-ns dlna-b8775f74b-6lrsb -- /bin/bash -c "kill 1"
```

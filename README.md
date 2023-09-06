![aaa](https://github.com/deemack/homelab/assets/72137221/d3dc9bea-c7f1-4f9d-ae20-69321e95b24d)# homelab
This project deploys a MicroK8s cluster along with some containers to a Physical Host.

## Physical Host
* Beelink SEi12 Mini PC
  * Intel i5-1235U
  * 16GB Ram
  * 500GB NVMe SSD
  * 2TB SATA SSD
## Installation Steps
### Provision the Physical Host
* Install Ubuntu server to your Physical Host using a USB or PXE-Boot installation https://github.com/deemack/pxe
* Give the Physical Host an IP address of 192.168.1.100.
* Run the following command to clone the repo and begin the setup script:
```
git clone https://github.com/deemack/homelab.git && cd homelab && sudo chmod +x setup_environment.sh && bash setup_environment.sh
```
* Once complete, a MicroK8s cluster will be running on the Physical Host.
### Accessing the Kubernetes Dashboard from an external PC
* Run the following command on the Physical Host  
```
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token
```
* Navigate to \<Physical Host IP>:32075
* Use the token to log in
* You can also save this **cat /var/snap/microk8s/current/credentials/client.config** contents to file on your computer and use it to login as a **kubeconfig**

## Containers and Services
### Minidlna
A Mini dlna server will be installed as a container in the MicroK8s cluster. It can be used to store TV Shows and Movies that are stored on the 2TB SSD mounted at **/mnt/storage/Movies** and **/mnt/storage/TV**
#### Restarting the minidlna service in the container to update the database.
This is useful if you have saved some new media straight onto the 2TB SSD and want the MiniDLNA server to update its content.
* Run the following commands to kill the pod, and kubernetes will re-create it.
```
microk8s kubectl get pods -n dlna-ns
microk8s kubectl exec -it -n dlna-ns dlna-b8775f74b-6lrsb -- /bin/bash -c "kill 1"
```
### SAMBA file share
The contents of **/mnt/storage** are shared over the network. The share can be accessed in File Explorer via **\\192.168.1.100\share**
Media can be copied into the **TV** and **Movies** folders for playback by the miniDLNA container.
The backups for **wikijs** are also available on the share.
### Wikijs
The Wikijs uses a postgresql database. After a fresh installtion, you might want to restore your content from GitHub or backup on the Physical Hosts 2TB SSD.
#### Backing up the Postgres database
- Log into the Kubernetes Dashboard
- Click Pods then Right-Click on the wikijs postgres pod and Click Execute
- In the terminal run the following command
```
pg_dump wikijs -U wikijs -F c > /var/lib/postgresql/data/wikibackup
```
- This will create a backup of the database and it can be retrieved from the wikijs share on the 2TB SSD.
#### Restoring the Database after a fresh installation



### Ansible Directory Structure
```
playbooks/
  roles/
    role1/
      tasks/
        main.yml
site.yml
```

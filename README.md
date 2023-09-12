# homelab
This project deploys a MicroK8s cluster along with some containers to a Physical Host.

## Physical Host
* Beelink SEi12 Mini PC
  * Intel i5-1235U (10 Cores 12 Threads)
  * 16GB Ram
  * 500GB NVMe SSD
  * 2TB SATA SSD (formatted as NTFS with the /mnt/storage folder structure created)
## Installation Steps
### Provision the Physical Host
* Install Ubuntu server to your Physical Host using a USB or PXE-Boot installation https://github.com/deemack/pxe
* Give the Physical Host an IP address of 192.168.1.100.
* Run the following command to clone the repo and begin the setup script:
```
git clone https://github.com/deemack/homelab.git && cd homelab && sudo chmod +x setup_environment.sh && bash setup_environment.sh
```
* Once complete, a MicroK8s cluster will be running on the Physical Host with the following container/services
  * miniDLNA
  * Samba Share
  * wikijs
  * Kubernetes Dashboard
    
### Access the Kubernetes Dashboard from an external PC
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
----
### SAMBA file share
The contents of **/mnt/storage** are shared over the network. The share can be accessed in File Explorer via **\\192.168.1.100\share**
Media can be copied into the **TV** and **Movies** folders for playback by the miniDLNA container.
The backups for **wikijs** are also available on the share.

----
### Wikijs
- Access WikiJs via **192.168.1.100:30331**
- The Wikijs uses a postgresql database. After a fresh installtion, you might want to restore your content from GitHub or backup on the Physical Hosts 2TB SSD.
#### Backing up the Postgres database
- Log into the Kubernetes Dashboard
- Click Pods then Right-Click on the wikijs postgres pod and Click Execute
- In the terminal run the following command
```
pg_dump wikijs -U wikijs -F t > /var/lib/postgresql/data/wikibackup.tar
```
- This will create a backup of the database and it can be retrieved from the wikijs share on the 2TB SSD.
#### Restoring the WikiJS Database after a fresh installation
- Copy the wikibackup.dump file to the /mnt/storage/wikijs/postgres/ directory on the Physical Host
- Log into the Kubernetes Dashboard
- Click Pods then Right-Click on the wikijs postgres pod and Click Execute
- In the terminal run the following command
```
dropdb -U wikijs wikijs -f
createdb -U wikijs wikijs
pg_restore -U wikijs -d wikijs /var/lib/postgresql/data/wikibackup.tar
```
- Next goto Deployments, and restart the **wikijs** deployment

----



### Ansible Directory Structure
```
playbooks/
  roles/
    role1/
      tasks/
        main.yml
site.yml
```

apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-deployment-one
data:
  index.html: |
    <html>
      <head>
        <title>Brians Week 18 Project</title>
      </head>
      <body>
        <h1>This is Deployment One</h1>
      </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-deployment-two
data:
  index.html: |
    <html>
      <head>
        <title>Brians Week 18 Project</title>
      </head>
      <body>
        <h1>This is Deployment Two</h1>
      </body>
    </html>
	
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brians-deployment1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: brians-config-volume-1
          mountPath: /usr/share/nginx/html
      volumes:
      - name: brians-config-volume-1
        configMap:
          name: configmap-deployment-one
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brians-deployment2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: brians-config-volume-2
          mountPath: /usr/share/nginx/html
      volumes:
      - name: brians-config-volume-2
        configMap:
          name: configmap-deployment-two


apiVersion: v1
kind: Service
metadata:
  name: brians-service
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30001		  

# homelab
* This project creates an ansible VM on your Server, so that it can be used to provision the Server.
* ssh via public keys is configured from the Server to the VM and vice versa, for the user 'vagrant:vagrant'
* Clone the repo, navigate into the homelab directory and run:
----
      sudo chmod +x setup_environment.sh && bash setup_environment.sh
----

### Notes
- The ansible VM is set to have an IP of 192.168.56.10
- It is assumed the Server has an IP of 192.168.1.100
- VirtualBox is used as the VM manager

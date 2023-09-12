#!/bin/bash

# This script will run as a cron job to backup the wikijs database each night.
# It will create a backup with a time stamp, which will be copied to /mnt/storage/backups/wikijs/ 
# A separate cron job will remove old backups after a specified time

# Get the name of the wikijs postgres pod
#microk8s kubectl get pods -n wikijs -l=app=pgsql --no-headers -o custom-columns=":metadata.name"
pod_str=$(microk8s kubectl get pods -n wikijs -l=app=pgsql --no-headers -o custom-columns=":metadata.name")

# Create backup and append date stamp
d=$(date +%Y-%m-%d-%H.%M.%S)
microk8s kubectl exec -it -n wikijs $pod_str -- /bin/bash -c "pg_dump wikijs -U wikijs -F t > /var/lib/postgresql/data/$d-wikibackup.tar"

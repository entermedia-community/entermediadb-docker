#!/bin/bash -x

USER=$1
ENDPOINT=/media/emsites/op-b/data/assets/catalog/useruploads

#sudo groupadd sftp_users
#sudo mkdir /sftpdata
#sudo chmod 701 $ENDPOINT


sudo useradd -g sftp_users -d /upload -s /sbin/nologin $USER
sudo passwd $USER
sudo mkdir -p $ENDPOINT/$USER/uploads
sudo chmod 755 $ENDPOINT/$USER
sudo chown root: $ENDPOINT/$USER
sudo chown -R $USER:sftp_users $ENDPOINT/$USER/uploads


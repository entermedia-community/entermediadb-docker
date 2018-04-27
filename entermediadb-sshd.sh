#!/bin/bash 
HOME_CLIENT="/home/client"

# Install sshd 
yum install -y openssh-server

# Generate host ssh keys 
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
ssh-keygen -A

# Generate client SSH key with empty password
ssh-keygen -t rsa -C "client@entermediadb.org" -f "/media/services/client.pk" -q -N ""
mv /media/services/client.pk.pub /media/services/client.pub

# Create user client and set primary group to entermedia
useradd client -g entermedia

#Create .ssh dir with required files
mkdir $HOME_CLIENT/.ssh
chmod -v 755 $HOME_CLIENT/.ssh
cat /media/services/client.pub > $HOME_CLIENT/authorized_keys
chmod -v 644 $HOME_CLIENT/authorized_keys
chown -R client:entermedia $HOME_CLIENT/.ssh
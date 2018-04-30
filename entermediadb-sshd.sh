#!/bin/bash -x
HOME_CLIENT="/home/client"

# Install sshd 
yum install -y openssh-server

# Generate host ssh keys 
echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
echo -e  'y\n' | ssh-keygen -A

# Generate client SSH key with empty password

if [ ! -f /media/services/client.pk ]; then
    ssh-keygen -t rsa -C "client@entermediadb.org" -f "/media/services/client.pk" -q -N ""
	mv /media/services/client.pk.pub /media/services/client.pub
fi

# Create user client and set primary group to entermedia
useradd client -g entermedia

#Create .ssh dir with required files
mkdir $HOME_CLIENT/.ssh
chmod -v 755 $HOME_CLIENT/.ssh
cat /media/services/client.pub > $HOME_CLIENT/.ssh/authorized_keys
chmod -v 644 $HOME_CLIENT/.ssh/authorized_keys
chown -R client:entermedia $HOME_CLIENT/.ssh
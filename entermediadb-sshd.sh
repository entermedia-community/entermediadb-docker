#!/bin/bash -x
HOME_CLIENT="/media/services/client"

# Install sshd 
yum install -y openssh-server wget

# Generate host ssh keys 
echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
echo -e  'y\n' | ssh-keygen -A

# Generate client SSH key with empty password
if [ ! -d "$HOME_CLIENT" ]; then
  mkdir -p $HOME_CLIENT/.ssh
fi

if [ ! -f $HOME_CLIENT/.ssh/client.pk ]; then
    ssh-keygen -t rsa -C "client@entermediadb.org" -f "$HOME_CLIENT/.ssh/client.pk" -q -N ""
	mv $HOME_CLIENT/.ssh/client.pk.pub $HOME_CLIENT/.ssh/client.pub
fi

# Create user client and set primary group to entermedia
useradd client -g entermedia
# Set client's home
usermod -m -d $HOME_CLIENT client

#Create .ssh dir with required files
#mkdir $HOME_CLIENT/.ssh
chmod -v 755 $HOME_CLIENT/.ssh
cat $HOME_CLIENT/.ssh/client.pub > $HOME_CLIENT/.ssh/authorized_keys
chmod -v 644 $HOME_CLIENT/.ssh/authorized_keys
chown -R client:entermedia $HOME_CLIENT/.ssh

# Get SSH daemon starter script
wget https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/services/startsshd.sh
chmod +x /media/service/startsshd.sh
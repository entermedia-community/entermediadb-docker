#!/bin/bash -x
HOME_CLIENT="/media/services/client"

# Create client's home if doesn't exist
if [ ! -d "$HOME_CLIENT" ]; then
	# Install sshd
	yum install -y openssh-server
	
	# Generate host ssh keys 
	echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
	echo -e  'y\n' | ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
	echo -e  'y\n' | ssh-keygen -A

 	mkdir -p $HOME_CLIENT/.ssh
 	chmod -v 755 $HOME_CLIENT/.ssh
	
	# Get bash config files from entermedia user
	cp /home/entermedia/.bash_profile $HOME_CLIENT && cp /home/entermedia/.bashrc $HOME_CLIENT

	# Generate client SSH key with empty password and set authorized_keys
	if [ ! -f $HOME_CLIENT/.ssh/client.pk ]; then
	    ssh-keygen -t rsa -C "client@entermediadb.org" -f "$HOME_CLIENT/.ssh/client.pk" -q -N ""
		mv $HOME_CLIENT/.ssh/client.pk.pub $HOME_CLIENT/.ssh/client.pub
		cat $HOME_CLIENT/.ssh/client.pub > $HOME_CLIENT/.ssh/authorized_keys
		chmod -v 644 $HOME_CLIENT/.ssh/authorized_keys
	fi
fi

# Create user client and set primary group to entermedia
if [ ! id "client" >/dev/null 2>&1 ]; then
	useradd client -g entermedia -u 777
	# Set client's home
	usermod -m -d $HOME_CLIENT client
fi

# Set owner and group for SSH dir
chown -R client:entermedia $HOME_CLIENT/.ssh
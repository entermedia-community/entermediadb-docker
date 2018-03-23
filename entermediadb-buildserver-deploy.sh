#!/bin/bash -x

yum install -y openssh-server git wget
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
ssh-keygen -A
/usr/sbin/sshd -D &

cd /home/entermedia/
mkdir .ssh
chmod 755 .ssh/
cd .ssh/
touch authorized_keys
chmod 644 authorized_keys
ssh-keygen -t rsa -C "entermedia@entermediadb.org" -f /home/entermedia/.ssh/buildserver.pk
cat /home/entermedia/.ssh/buildserver.pk.pub > /home/entermedia/.ssh/authorized_keys
chown -R entermedia. /home/entermedia/.ssh
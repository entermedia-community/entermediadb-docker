#!/bin/bash -x

yum install -y openssh-server git wget
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
ssh-keygen -A
/usr/sbin/sshd -D &

cd /root
mkdir .ssh
chmod 755 .ssh/
cd .ssh/
touch authorized_keys
chmod 644 authorized_keys
ssh-keygen -t rsa -C "entermedia@entermediadb.org" -f /root/.ssh/buildserver.pk
cat /root/.ssh/buildserver.pk.pub > /root/.ssh/authorized_keys

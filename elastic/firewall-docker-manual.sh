#!/bin/bash -x

LOCAL_NETWORK=192.168.100.0
ES_NODE=$1
ES_IP=$2

#csf -x
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

#iptables -A INPUT -i lo -j ACCEPT


#Allow everyone to these ports
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

#Allow all local networks connections in
#iptables -A INPUT -p tcp -s $LOCAL_NETWORK/24 -j ACCEPT

# Docker manual routing
iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o docker0 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Elastic inter-server
iptables -A INPUT -s $ES_IP -p tcp --dport 93$ES_NODE -j ACCEPT
iptables -A OUTPUT -d $ES_IP -p tcp --sport 93$ES_NODE -j ACCEPT

iptables -A INPUT  -s $ES_IP -p tcp --dport 92$ES_NODE -j ACCEPT
iptables -A OUTPUT  -d $ES_IP -p tcp --sport 92$ES_NODE -j ACCEPT

# Create DOCKER CHAIN
iptables -N DOCKER
# Drop not allowed IP to ES
iptables -A DOCKER -i eth0 ! -s $ES_IP -j DROP

#advanced tcp connection stuff
iptables -A INPUT -m conntrack -j ACCEPT  --ctstate RELATED,ESTABLISHED
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow Backupserver to ping
#SERVER_IP=""
#iptables -A INPUT -p icmp -s $SERVER_IP -j ACCEPT

#finally, drop everyone else
iptables -A INPUT -j DROP


#iptables-save > /etc/sysconfig/iptables

sudo service docker restart

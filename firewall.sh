#!/bin/bash -x

LOCAL_NETWORK=192.168.100.0

csf -x
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT

#Allow everyone to these ports
iptables -A INPUT -p tcp -m tcp -m multiport --dports 80,443,22 -j ACCEPT

#Allow all local networks connections in
iptables -A INPUT -p tcp -s $LOCAL_NETWORK/24 -j ACCEPT

#advanced tcp connection stuff
iptables -A INPUT -m conntrack -j ACCEPT  --ctstate RELATED,ESTABLISHED
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow Backupserver to ping
#SERVER_IP=""
#iptables -A INPUT -p icmp -s $SERVER_IP -j ACCEPT

#Finally, drop everyone else
iptables -A INPUT -i eth0 -j DROP

#restart docker
service docker restart

#only allow subnet connections
iptables -I DOCKER-USER -i eth0 ! -s $LOCAL_NETWORK/24 -j DROP

#save iptables
iptables-save > /etc/sysconfig/iptables

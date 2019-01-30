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
iptables -A INPUT -p tcp -m tcp -m multiport --dports 22,80,443 -j ACCEPT

#Allow all local networks connections in
iptables -A INPUT -p tcp -s $LOCAL_NETWORK/24 -j ACCEPT

#advanced tcp connection stuff
iptables -A INPUT -m conntrack -j ACCEPT  --ctstate RELATED,ESTABLISHED
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow Backupserver to ping
#SERVER_IP=""
#iptables -A INPUT -p icmp -s $SERVER_IP -j ACCEPT

#iptables -A INPUT -p tcp --sport 2520 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 2520 -j ACCEPT

#Finally, drop everyone else
#iptables -A INPUT -i eth0 -j DROP
iptables -A INPUT -i eth3 -j DROP

#Redirects ports to LAN hosts ports
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9200 -d 172.19.0.19 -j ACCEPT
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9200 -d 172.19.0.20 -j ACCEPT
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9200 -d 172.19.0.21 -j ACCEPT
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9300 -d 172.19.0.19 -j ACCEPT
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9300 -d 172.19.0.20 -j ACCEPT
iptables -A FORWARD -s [ALLOWED_PUB_IP] -p tcp --dport 9300 -d 172.19.0.21 -j ACCEPT
iptables -A FORWARD -j DROP
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9219 -j DNAT --to-destination 172.19.0.19:9200
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9220 -j DNAT --to-destination 172.19.0.20:9200
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9221 -j DNAT --to-destination 172.19.0.21:9200
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9319 -j DNAT --to-destination 172.19.0.19:9300
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9320 -j DNAT --to-destination 172.19.0.20:9300
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9321 -j DNAT --to-destination 172.19.0.21:9300

#restart docker
service docker restart

#only allow subnet connections  -- use firewall-iptables.conf instead: sudo iptables-restore -n firewall-iptables.conf
#iptables -I DOCKER-USER -i eth0 ! -s $LOCAL_NETWORK/24 -j DROP

#save iptables
iptables-save > /etc/sysconfig/iptables

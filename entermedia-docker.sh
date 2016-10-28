#!/bin/bash 

if [ -z $BASH ]; then
  echo Using Bash...
  exec "/bin/bash" $0 $@
  exit
fi
  
# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

# Setup
SITE=$1
PORT=$2

# For dev
BRANCH=latest

ALREADY=$(docker ps -aq --filter name=$SITE$PORT)
[[ $ALREADY ]] && docker stop $ALREADY && docker rm -f $ALREADY

NODENUMBER=`echo $PORT | cut -c3-4`
IP_ADDR="172.101.0.1$NODENUMBER"

ENDPOINT=/media/emsites/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.101.0.0/16 entermedia
fi

# Pull latest images
docker pull entermediadb/entermediadb9:$BRANCH

# TODO: support upgrading, start, stop and removing

# Initialize site root 
mkdir -p ${ENDPOINT}/{webapp,data,$PORT,elastic}
INSTANCE=$SITE$PORT

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$PORT
echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash ${SCRIPTROOT}/entermedia-docker.sh $SITE $PORT" > ${SCRIPTROOT}/update.sh
echo "sudo docker exec -it -u 0 $INSTANCE entermediadb-update.sh" > ${SCRIPTROOT}/updatedev.sh
cp  $0  ${SCRIPTROOT}/ 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

# Fix permissions
chown -R entermedia. "${ENDPOINT}"

LISTEN_ON=172.101.0.1
set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
        --restart unless-stopped \
        --net entermedia \
        --ip $IP_ADDR \
        --name $INSTANCE \
        -e USERID=$USERID \
        -e GROUPID=$GROUPID \
        -e CLIENT_NAME=$SITE \
        -e INSTANCE_PORT=$PORT \
        -v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
        -v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
        -v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
        -v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	-v ${ENDPOINT}/services:/media/services \
        entermediadb/entermediadb9:$BRANCH

echo ""
echo "Once you are ready to go live add these lines to your firewall script:"
echo "iptables -A INPUT -p tcp -m tcp -m multiport --dports $PORT,60$NODENUMBER -j ACCEPT
iptables -A INPUT -p udp -m udp -m multiport --dports 60$NODENUMBER -j ACCEPT
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $PORT -j DNAT --to $IP_ADDR:8080
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 60$NODENUMBER -j DNAT --to $IP_ADDR:6001
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 60$NODENUMBER -j DNAT --to $IP_ADDR:6001"
echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"

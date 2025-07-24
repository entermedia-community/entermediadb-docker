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

if [ "$#" -ne 2 ]; then
    echo "usage: sitename nodenumber"
    exit 1
fi

# Setup
SITE=$1
NODENUMBER=$2

if [ ${#NODENUMBER} -ge 4 ]; then echo "Node Number must be between 100-250" ; exit
else echo "Using Node Number: $NODENUMBER"
fi


INSTANCE=$SITE$NODENUMBER

# Pull latest images
docker pull wowzamedia/wowza-streaming-engine-linux:latest

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="172.162.0.$NODENUMBER"

ENDPOINT=/media/wowza/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep wowza) ]]; then
  docker network create --subnet 172.162.0.0/16 wowza
fi

# Initialize site root 
mkdir -p ${ENDPOINT}/$NODENUMBER
chown entermedia. ${ENDPOINT} 

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER
echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/wowza-docker.sh $SITE $NODENUMBER" > ${SCRIPTROOT}/update.sh


# Fix File Limits
echo "fs.file-max = 10000000" >> /etc/sysctl.conf
echo "entermedia      soft    nofile  409600" >> /etc/security/limits.conf
echo "entermedia      hard    nofile  1024000" >> /etc/security/limits.conf
sysctl -p


# Fix permissions
chown -R entermedia. "${ENDPOINT}/$NODENUMBER"
rm -rf "/tmp/$NODENUMBER"  2>/dev/null
mkdir -p "/tmp/$NODENUMBER" 
chown entermedia. "/tmp/$NODENUMBER"

set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
	--restart unless-stopped \
        --net wowza \
        --ip $IP_ADDR \
        --name $INSTANCE \
        --log-opt max-size=100m --log-opt max-file=2 \
	--cap-add=SYS_PTRACE \
        -e USERID=$USERID \
        -e GROUPID=$GROUPID \
        -e CLIENT_NAME=$SITE \
        -e INSTANCE_PORT=$NODENUMBER \
	--expose 1935/tcp \
	--expose 8086/tcp \
	--expose 8087/tcp \
	--expose 8088/tcp \
	--publish 1935:1935 \
	--publish 8086:8086 \
	--publish 8087:8087 \
	--publish 8088:8088 \
	--env WSE_MGR_USER="admin" \
	--env WSE_MGR_PASS="admin" \
	--env WSE_LIC="EDEV4-Qy3yh-yuJCH-4V6f4-8akXT-VEeU7-9N9QyxNWBXc3" \
	--entrypoint /sbin/entrypoint.sh \
        wowzamedia/wowza-streaming-engine-linux:latest


echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""



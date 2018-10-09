#!/bin/bash

#
# Launch EnterMediadb SMTP-Postfix instance
#

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

# For dev
BRANCH=latest

# Pull latest images
docker pull entermediadb/smtp:latest

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="172.99.0.$NODENUMBER"

ENDPOINT=/media/emsites/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep entermedia-smtp) ]]; then
  docker network create --subnet 172.99.0.0/16 entermedia-smtp
fi


# Initialize site root
mkdir -p ${ENDPOINT}/$NODENUMBER
chown -R entermedia. ${ENDPOINT}
chown entermedia. ${ENDPOINT}/{$NODENUMBER}

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER

echo "sudo docker start postfix-$INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 postfix-$INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 postfix-$INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it postfix-$INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/entermedia-docker-smtp.sh $SITE $NODENUMBER" > ${SCRIPTROOT}/rebuild.sh

#-
cp  $0  ${SCRIPTROOT}/entermedia-docker-smtp.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh
chown entermedia. ${SCRIPTROOT}/*.sh

# Fix File Limits
if grep -Fxq "entermedia" /etc/security/limits.conf
then
	# code if found
	echo ""
else
	# code if not found
	echo "fs.file-max = 10000000" >> /etc/sysctl.conf
	echo "entermedia      soft    nofile  409600" >> /etc/security/limits.conf
	echo "entermedia      hard    nofile  1024000" >> /etc/security/limits.conf
	sysctl -p
fi

echo "Review the following URL to get the full TZ list"
echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
echo "Default time zone(TZ) will be US Eastern time"

# Create Docker SMTP Instance
set -e
docker run -t -d \
  --restart unless-stopped \
  --net entermedia-smtp \
  --ip $IP_ADDR \
	--name postfix-$INSTANCE \
  -e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=$NODENUMBER \
  -p 2520:25 \
  -e SMTP_SERVER=smtp.entermediadb.org \
  -e SMTP_USERNAME=smtp@entermediadb.org \
  -e SMTP_PASSWORD=em2018smtp \
  -e SERVER_HOSTNAME=smtp.entermediadb.org \
  -e TZ="America/New_York" \
  --log-opt max-size=100m --log-opt max-file=2 \
	--cap-add=SYS_PTRACE \
  entermediadb/smtp:latest

echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""

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
docker pull entermediadb/jenkins:latest

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="172.42.0.$NODENUMBER"

ENDPOINT=/media/jenkins/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep jenkins) ]]; then
  docker network create --subnet 172.42.0.0/16 jenkins
fi

# Initialize site root
mkdir -p ${ENDPOINT}/{jenkins_home,$NODENUMBER,services}
chown entermedia. ${ENDPOINT}
chown entermedia. ${ENDPOINT}/{services,$NODENUMBER}
chown centos. ${ENDPOINT}/jenkins_home

cp -rf /home/entermedia/.ssh /${ENDPOINT}/services


# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER
echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it -u root $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
cp  $0  ${SCRIPTROOT}/jenkins-docker.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

# Fix File Limits
echo "fs.file-max = 10000000" >> /etc/sysctl.conf
echo "entermedia      soft    nofile  409600" >> /etc/security/limits.conf
echo "entermedia      hard    nofile  1024000" >> /etc/security/limits.conf
sysctl -p


# Fix permissions
chown -R entermedia. "${ENDPOINT}/$NODENUMBER"

set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
		    --restart unless-stopped \
        --net jenkins \
        --ip $IP_ADDR \
        --name $INSTANCE \
        --log-opt max-size=100m --log-opt max-file=2 \
        -e CLIENT_NAME=$SITE \
        -e INSTANCE_PORT=$NODENUMBER \
        -v ${ENDPOINT}/jenkins_home:/var/jenkins_home \
	      -e JENKINS_OPTS="--prefix=/jenkins" \
		    -v ${ENDPOINT}/services:/media/services \
        entermediadb/jenkins:latest

echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""

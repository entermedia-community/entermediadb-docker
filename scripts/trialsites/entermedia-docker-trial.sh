#!/bin/bash
set -x

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
    echo "usage: sitename subnet"
    exit 1
fi

# Setup
DOCKERPROJECT=entermediadb
DOCKERIMAGE=entermedia
BRANCH=latest
SITE=$1
SUBNET=$2

INSTANCE=$SITE

docker inspect $INSTANCE > /dev/null
if [ $? -eq 0 ]; then
	echo "Container already exists"
	exit 0;
fi


# Pull latest images
# This script is downloaded each time from Github: https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/scripts/trialsites/entermedia-docker-trial.sh
docker pull $DOCKERPROJECT/$DOCKERIMAGE:$BRANCH

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

ENDPOINT=/media/trialsites/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep entermediatrial$SUBNET) ]]; then
  docker network create --subnet 172.$SUBNET.0.0/16 entermediatrial$SUBNET
fi

# Initialize site root
mkdir -p ${ENDPOINT}/{webapp,data,elastic,services}
chown -R entermedia. ${ENDPOINT}


# Create custom scripts
SCRIPTROOT=${ENDPOINT}
echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker stop -t 60 $INSTANCE && sudo docker start $INSTANCE" > ${SCRIPTROOT}/restart.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/entermedia-docker.sh $SITE $SUBNET" > ${SCRIPTROOT}/update.sh


# Versions
#VERSIONS_FILE=${ENDPOINT}/services/versions.sh
#curl -XGET -o ${ENDPOINT}/services/versions.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/services/versions.sh  > /dev/null
#chmod +x ${ENDPOINT}/services/versions.sh
#chown entermedia. ${ENDPOINT}/services/versions.sh
#V_DOCKER=$(docker -v | head -n 1 | awk '{print $3}' | sed 's/,//')
#sed -i "s/V_DOCKER_EXT/$V_DOCKER/g;" $VERSIONS_FILE

cp  $0  ${SCRIPTROOT}/entermedia-docker.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
  --restart unless-stopped \
  --net entermediatrial$SUBNET \
  --name $INSTANCE \
  --hostname=${INSTANCE}_${SUBNET} \
  --log-opt max-size=10m --log-opt max-file=2 \
  --cap-add=SYS_PTRACE \
  -e USERID=$USERID \
  -e GROUPID=$GROUPID \
  -e CLIENT_NAME=$SITE \
  -v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
  -v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
  -v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
  -v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
  -v ${ENDPOINT}/services:/media/services \
  --cpus="4.0" \
  $DOCKERPROJECT/$DOCKERIMAGE:$BRANCH \
  /usr/bin/entermediadb-deploy.sh

echo ""
echo "Node is running: curl http://$INSTANCE:8080 in $SCRIPTROOT"
echo ""



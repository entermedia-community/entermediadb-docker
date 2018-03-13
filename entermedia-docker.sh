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

# For dev
BRANCH=latest

# Pull latest images
docker pull entermediadb/entermediadb9:$BRANCH

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="172.18.0.$NODENUMBER"

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
  docker network create --subnet 172.18.0.0/16 entermedia
fi

# TODO: support upgrading, start, stop and removing

# Initialize site root 
mkdir -p ${ENDPOINT}/{webapp,data,$NODENUMBER,elastic,services}
chown entermedia. ${ENDPOINT} 
chown entermedia. ${ENDPOINT}/{webapp,data,$NODENUMBER,elastic,services}

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER
echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/entermedia-docker.sh $SITE $NODENUMBER" > ${SCRIPTROOT}/update.sh
echo "sudo docker exec -it -u 0 $INSTANCE entermediadb-update.sh" > ${SCRIPTROOT}/updatedev.sh
# Versions
VERSIONS_FILE=${ENDPOINT}/services/versions.sh
if [ ! -f $VERSIONS_FILE ]; then
	curl -XGET -o ${ENDPOINT}/services/versions.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/services/versions.sh  > /dev/null
	chmod +x ${ENDPOINT}/services/versions.sh
	chown entermedia. ${ENDPOINT}/services/versions.sh
fi
V_DOCKER=$(docker -v | head -n 1 | awk '{print $3}')
sed -i "s/V_DOCKER_EXT/$V_DOCKER/g" $VERSIONS_FILE
#-
cp  $0  ${SCRIPTROOT}/entermedia-docker.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

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
        --net entermedia \
        --ip $IP_ADDR \
        --name $INSTANCE \
        --log-opt max-size=100m --log-opt max-file=2 \
        -e USERID=$USERID \
        -e GROUPID=$GROUPID \
        -e CLIENT_NAME=$SITE \
        -e INSTANCE_PORT=$NODENUMBER \
        -v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
        -v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
        -v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
        -v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
		-v ${ENDPOINT}/services:/media/services \
		-v /tmp/$NODENUMBER:/tmp \
        entermediadb/entermediadb9:$BRANCH \
		/usr/bin/entermediadb-deploy.sh

echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""


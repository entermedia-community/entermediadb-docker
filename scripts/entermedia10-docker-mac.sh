#!/bin/bash -x

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

if [ "$#" -ne 3 ]; then
    echo "usage: sitename nodenumber macUsername"
    exit 1
fi

# Setup
SITE=$1
NODENUMBER=$2
MACUSER=$3
DOCKERIMG=entermedia10

if [ ${#NODENUMBER} -ge 4 ]; then echo "Node Number must be between 100-250" ; exit
else echo "Using Node Number: $NODENUMBER"
fi
INSTANCE=$SITE$NODENUMBER

# For dev
BRANCH=latest

# Pull latest images
docker pull entermediadb/$DOCKERIMG:$BRANCH

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="172.18.0.$NODENUMBER"
ENDPOINT=/Users/admin/Public/emsites/$SITE
#/Users/entermedia/emsites/$SITE

USERID=$(id -u $MACUSER)
GROUPID=$(dscl . -read /Groups/staff gid | awk '{print $2}')

# Docker networking
if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.18.0.0/16 entermedia
fi

# Initialize site root
mkdir -p ${ENDPOINT}/{webapp,data,$NODENUMBER,$NODENUMBER/tomcat,elastic,services/extensions}
chown -R $MACUSER:staff ${ENDPOINT}

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER

if [ -e $SCRIPTROOT/update.sh ]; then
    rm $SCRIPTROOT/update.sh
fi
if [ -e $SCRIPTROOT/updatedev.sh ]; then
    rm $SCRIPTROOT/updatedev.sh
fi

echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker stop -t 60 $INSTANCE && sudo docker start $INSTANCE" > ${SCRIPTROOT}/restart.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/entermedia-docker.sh $SITE $NODENUMBER" > ${SCRIPTROOT}/rebuild.sh
echo 'sudo docker exec -it -u 0 '$INSTANCE' entermediadb-update.sh $1 $2' > ${SCRIPTROOT}/update-em9dev.sh
echo 'sudo docker exec -it -u 0 '$INSTANCE' entermediadb-update-em9.sh $1 $2' > ${SCRIPTROOT}/update-em9.sh
echo 'sudo docker exec -it -u 0 '$INSTANCE' entermediadb-update-em10.sh $1 $2' > ${SCRIPTROOT}/update-em10dev.sh

# Health check
echo "#!/bin/bash +x" > ${SCRIPTROOT}/health.sh
echo "IP=http://$IP_ADDR:9200" >> ${SCRIPTROOT}/health.sh
wget -O - https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/elastic/health-base.sh >> ${SCRIPTROOT}/health.sh

# Versions
VERSIONS_FILE=${ENDPOINT}/services/versions.sh
curl -XGET -o ${ENDPOINT}/services/versions.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/tomcat/services/versions.sh > /dev/null
chmod +x ${ENDPOINT}/services/versions.sh
chown $MACUSER:staff ${ENDPOINT}/services/versions.sh
V_DOCKER=$(docker -v | head -n 1 | awk '{print $3}' | sed 's/,//')
sed -i '' -e "s/V_DOCKER_EXT/$V_DOCKER/g;" $VERSIONS_FILE
#-
cp  $0  ${SCRIPTROOT}/entermedia-docker.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

### Fix File Limits
##if grep -Fq "entermedia" /etc/security/limits.conf
##then
##	# code if found
##	echo ""
##else
##	# code if not found
##	echo "fs.file-max = 10000000" >> /etc/sysctl.conf
##	echo "entermedia      soft    nofile  409600" >> /etc/security/limits.conf
##	echo "entermedia      hard    nofile  1024000" >> /etc/security/limits.conf
##  echo "entermedia      soft    nproc   100000" >> /etc/security/limits.conf
##  echo "entermedia      hard    nproc   100000" >> /etc/security/limits.conf
##sysctl -p
##fi

# Fix permissions
# chown -R $MACUSER:staff "${ENDPOINT}/$NODENUMBER"
# rm -rf "/tmp/$NODENUMBER"  2>/dev/null
# mkdir -p "/tmp/$NODENUMBER"
# chown $MACUSER:staff "/tmp/$NODENUMBER"

echo "Review the following URL to get the full TZ list"
echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
echo "Default time zone(TZ) will be US Eastern time"

set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
    --restart unless-stopped \
    --net entermedia \
    --ip $IP_ADDR \
    --name $INSTANCE \
    --log-opt max-size=10m --log-opt max-file=10 \
    --cap-add=SYS_PTRACE \
    -e TZ="America/New_York" \
    -e USERID=$USERID \
    -e GROUPID=$GROUPID \
    -e CLIENT_NAME=$SITE \
    -e INSTANCE_PORT=$NODENUMBER \
    -p 8081:8080 \
    -v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
    -v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
    -v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
    -v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
    -v ${ENDPOINT}/services:/media/services \
    entermediadb/$DOCKERIMG:$BRANCH \
    /usr/bin/entermediadb-deploy.sh


# Fix /etc/resolv.conf to independently reflect Cloudflare and Google DNS
exit 0;
docker exec -d $INSTANCE sudo sh -c "truncate -s 0 /etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'nameserver 1.1.1.1' >>/etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'nameserver 8.8.8.8' >>/etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'options ndots:0' >>/etc/resolv.conf"


echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""

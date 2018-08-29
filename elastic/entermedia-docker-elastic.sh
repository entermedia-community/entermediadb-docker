#!/bin/bash

#
# Launch a Elastic-only Data Node 
#
# Run sample:
# entermedia-docker-elastic.sh NODE_ID NOTE_NAME CLUSTER_NAME ELASTIC_MASTERS(quoted comma separated) PUBLISH_HOST
# entermedia-docker-elastic.sh 37 un337 entermedia_cluster ""172.18.0.36"" 172.18.0.37

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser
  exit 1
fi

if [ -z "$1" ]
  then
    echo "No Node argument supplied"
  exit 1
fi
if [ -z "$2" ]
  then
    echo "No Node Name argument supplied"
  exit 1
fi
if [ -z "$3" ]
  then
    echo "No Cluster Name argument supplied"
  exit 1
fi

if [ -z "$4" ]
  then
    echo "No Elastic Masters addresses supplied"
  exit 1
fi

if [ -z "$5" ]
  then
    echo "No Node IP argument supplied"
  exit 1
fi

# Pull latest images
docker pull entermediadb/entermedia-elasticnode

NODENUMBER=$1
NODENAME=$2
CLUSTER_NAME=$3
ELASTIC_MASTERS=$4
PUBLISH_HOST=$5

IP_ADDR=172.18.0."$NODENUMBER"
INSTANCE_NAME="$CLUSTER_NAME-$NODENUMBER"-elastic
BASE_PATH=/media/cluster/$CLUSTER_NAME
REPO_PATH=$BASE_PATH/repos
CONFIG_PATH=$BASE_PATH/$NODENUMBER/config
DATA_PATH="$BASE_PATH"/$NODENUMBER/data
LOGS_PATH="$BASE_PATH"/$NODENUMBER/logs

if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
        groupadd entermedia > /dev/null
        useradd -g entermedia entermedia > /dev/null
fi

USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

mkdir -p $BASE_PATH/$NODENUMBER/{config,data,logs}

chown -R entermedia:entermedia "$BASE_PATH"
TMP_PATH=/tmp/$NODENUMBER
rm -rf "$TMP_PATH"  2>/dev/null
mkdir -p "$TMP_PATH"
chown entermedia:entermedia "/tmp/$NODENUMBER"


if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.18.0.0/16 entermedia
fi

echo "Instance name:" "$INSTANCE_NAME"
echo "Publish Host:" "$PUBLISH_HOST"
echo "Elastic Masters:" "$ELASTIC_MASTERS"
echo "Config PATH=""$CONFIG_PATH"
echo "Data PATH=""$DATA_PATH"
echo "Repo PATH=""$REPO_PATH"
echo "Logs PATH=""$LOGS_PATH"
echo "TMP PATH=""$TMP_PATH"

# Create custom scripts
SCRIPTROOT=$BASE_PATH/$NODENUMBER
echo "sudo docker start $INSTANCE_NAME" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE_NAME" > ${SCRIPTROOT}/stop.sh
echo "sudo docker logs -f --tail 500 $INSTANCE_NAME"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE_NAME bash"  > ${SCRIPTROOT}/bash.sh

# Health check
echo "#!/bin/bash +x" > ${SCRIPTROOT}/health.sh
echo "NODE=$NODENUMBER" >> ${SCRIPTROOT}/health.sh
wget -O - https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/elastic/health-base.sh >> ${SCRIPTROOT}/health.sh 


cp  $0  ${SCRIPTROOT}/entermedia-docker-elastic.sh 2>/dev/null
chown entermedia. ${SCRIPTROOT}/*.sh
chmod 755 ${SCRIPTROOT}/*.sh


docker run -d \
        -e USERID=$USERID \
        -e GROUPID=$GROUPID \
        -e CLUSTER_NAME="$CLUSTER_NAME" \
        -e ELASTIC_MASTERS="$ELASTIC_MASTERS" \
        -e PUBLISH_HOST="$PUBLISH_HOST" \
	-e NODENUMBER="$NODENUMBER" \i
	-e NODENAME="$NODENAME" \
        --name "$INSTANCE_NAME" \
        --net entermedia \
        --ip "$IP_ADDR" \
	-p 93$NODENUMBER:9300 \
	-p 92$NODENUMBER:9200 \
        -v "$CONFIG_PATH":/etc/elasticsearch \
        -v "$DATA_PATH":/var/lib/elasticsearch \
	-v DOCKERVOLUME:/opt/entermediadb/webapp/WEB-INF/elastic/repos \
        -v "$LOGS_PATH":/var/log/elasticsearch \
        -v "$TMP_PATH":/tmp \
        entermediadb/entermedia-elasticnode

echo "Verify Node: curl $IP_ADDR:9200"

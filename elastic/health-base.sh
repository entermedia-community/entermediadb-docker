
IP=172.18.0.$NODE:9200

if [ -z "$1" ]
  then
    curl $IP/_cluster/health?pretty
  exit 1
else
	if [ $1 == "health" ]
	then
		curl $IP/_cluster/health?pretty
	elif [ $1 == "nodes_health" ]
	then
		curl $IP/_nodes/_all/?pretty
	elif [ $1 == "allocation" ]
	then
		curl $IP/_cat/allocation?v
	elif [ $1 == "shards" ]
	then
		curl $IP/_cat/shards?v
	elif [ $1 == "nodes" ]
	then
		curl $IP/_nodes
	elif [ $1 == "master" ]
	then
		curl $IP/_cat/master?v
	elif [ $1 == "masters" ]
	then
		curl $IP/_cat/nodes?v&h=id,ip,port,v,m
 	elif [ $1 == "setmasters" ]
 	then
		curl -XPUT $IP/_cluster/settings -d '{ "persistent" : { "discovery.zen.minimum_master_nodes" : '$2' } }'
  elif [ $1 == "watermark" ]
  then
    curl -XPUT $IP/_cluster/settings -d ' "transient" : { "cluster.routing.allocation.disk.watermark.low" : "5gb","cluster.routing.allocation.disk.watermark.high" : "2gb" } }'
	else
		echo "Bad argument. Use health.sh [health | nodes_health | allocation | shards | nodes | master | masters | setmasters | watermark]"
		exit 1
	fi
fi

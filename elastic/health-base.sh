
IP=172.18.0.$NODE:9200

if [ -z "$1" ]
  then
    echo "No argument supplied"
  exit 1
else
	if [ $1 == "health" ]
	then
		curl $IP/_cluster/health?pretty
	elif [ $1 == "nodes" ]
	then
		curl $IP/_nodes/_all/?pretty
	elif [ $1 == "allocation" ]
	then
		curl $IP/_cat/allocation?v
	elif [ $1 == "shards" ]
	then
		curl $IP/_cat/shards?v
	else
		echo "Bad argument"
		exit 1
	fi
fi

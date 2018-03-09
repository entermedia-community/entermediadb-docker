

IP=172.18.0.$NODE:9200

if [ -z "$1" ]
  then
    echo "No argument supplied"
  exit 1
else
	if [$1 == "health"]
	then
		curl $IP/_cluster/health?pretty
	elseif [$1 == "nodes"]
		curl -XGET '$IP/_nodes/_all/?pretty'
	elseif [$1 == "allocation"]
		curl $IP/_cat/allocation?v
	elseif [$1 == "shards"]
		curl $IP/_cat/shards?v
	else
		echo "Bad argument"
		exit 1
	fi
fi

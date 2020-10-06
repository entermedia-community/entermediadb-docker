#!/bin/bash 


if [ "$1" ]; then
  DEBUG=$1
else
  DEBUG="false"
fi
declare -A globaldns
globaldns["US1"]="134.209.172.124"
globaldns["US2"]="165.227.4.225"
globaldns["EU1"]="206.189.113.193"
globaldns["EU2"]="159.89.21.156"
globaldns["AS1"]="139.59.0.94"


#globaldns=(${US1} ${US2} ${EU1} ${EU2} ${AS1} )

for SERVER in "${!globaldns[@]}"
do
    IP=${globaldns[${SERVER}]}
    HOST="global.unitednations.entermediadb.net"
    sed -i "/$HOST/ s/.*/$IP\t$HOST/g" /etc/hosts
    if [ ${DEBUG} == "true" ]
    then
        echo "Verifying: ${SERVER} (${IP})"
    fi
    for url in `curl -s https://news.un.org/en/ | sed -En '/<img/s/.*src="(https\:\/\/global\.unitednations\.entermediadb\.net[^"]*)".*/\1/p'`
    do
        response=`curl -A "entermediadb-scanner" -s --head --request GET ${url} | grep HTTP/1.1 |  awk {'print $2'};`
        if [ ${DEBUG} == "true" ]
        then
            echo "${response} ${url}"
            
        fi
        if [ ${response} -ne "200" ]
         then
#               echo "404 ${url}"
            echo ""
        fi
    done
done



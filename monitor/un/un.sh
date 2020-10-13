#!/bin/bash

if [ "$1" ]; then LOGLEVEL=$1; else LOGLEVEL=0; fi

declare -A globaldns
globaldns["US1"]="134.209.172.124"
globaldns["US2"]="165.227.4.225"
globaldns["EU1"]="206.189.113.193"
globaldns["EU2"]="159.89.21.156"
globaldns["AS1"]="139.59.0.94"

#globaldns=(${US1} ${US2} ${EU1} ${EU2} ${AS1} )

cp -f /etc/hosts /etc/hosts.orig
start=$(date +%s)
echo -e "134.209.172.124\tglobal.unitednations.entermediadb.net" >>/etc/hosts # this will add it in case I don't have it

function PRINT() {
    if [ $LOGLEVEL == 1 ]; then
        if [ $1 == 1 ]; then echo "DEBUG: $2"; fi
    fi
    if [ $LOGLEVEL -ge 1 ]; then
        if [ $1 == 2 ]; then echo "INFO: $2"; fi
    fi

    if [ $1 == 0 ]; then echo "ERROR: $2"; fi

}

for SERVER in "${!globaldns[@]}"; do
    IP=${globaldns[${SERVER}]}
    HOST="global.unitednations.entermediadb.net"
    sed -i "/$HOST/ s/.*/$IP\t$HOST/g" /etc/hosts
    PRINT 2 "Verifying: ${SERVER} (${IP})"
    startip=$(date +%s)
    for url in $(curl -s https://news.un.org/en/ | sed -En '/<img/s/.*src="(https\:\/\/global\.unitednations\.entermediadb\.net[^"]*)".*/\1/p'); do
        response=$(curl -A "entermediadb-scanner" -s --head --request GET ${url} | grep HTTP/1.1 | awk {'print $2'})
        if [ -z $response ]; then
            resp="curl -i ${url}"
            $resp
            exitCode=$?
            if [ $exitCode -eq "60" ]; then
                PRINT 0 "code: $exitCode"
                PRINT 0 "curl failed to verify the legitimacy of the server"
            fi
        else
            PRINT 1 "${response} ${url}"
            if [ ${response} -ne "200" ]; then
                echo "ERROR: failed $HOSTNAME - $URL"
            fi
        fi
    done
    endip=$(date +%s)
    PRINT 2 "$IP takes: $((endip - startip)) seconds"
done

end=$(date +%s)
runtime=$((end - start))
PRINT 2 "Total Time Verification: $runtime seconds"

cp /etc/hosts.orig /etc/hosts

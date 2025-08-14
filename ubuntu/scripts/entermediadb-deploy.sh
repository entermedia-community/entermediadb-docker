#!/bin/bash -x

# Deploy entermediadb 
# emubuntu scripts/entermediadb-deploy.sh
# TODO: change parameters to only rely on NODE ID instead of client name and instance port
# Variables CLIENT_NAME and INSTANCE_PORT should be coming from Docker ENV

EMCOMMON=/usr/share/entermediadb
EMTARGET=/opt/entermediadb
WEBAPP=$EMTARGET/webapp

#Finish install
if [[ ! $(id -u) -eq 0 ]]; then
	echo You must run this script as a superuser.
	exit 1
fi
if [[ ! $(id -u entermedia 2>/dev/null) ]]; then
	groupadd -g $GROUPID entermedia
	useradd -ms /bin/bash entermedia -g entermedia -u $USERID
fi

if [[ ! -f $WEBAPP/index.html ]]; then
	echo "Initial Deploy to $WEBAPP"

	mkdir -p $WEBAPP
	#cp -rp $EMCOMMON/webapp/*.* $WEBAPP/
	rsync -ar --chown=entermedia:entermedia $EMCOMMON/webapp/ $WEBAPP/
else
	#In case they got removed docker will re-create them but owned by root (Not -R to avoid slow restarts)
	chown entermedia:entermedia $WEBAPP/WEB-INF/data
	chown entermedia:entermedia $WEBAPP/WEB-INF/elastic
	chown entermedia:entermedia /tmp
	chown -R entermedia:entermedia $WEBAPP/WEB-INF/base
	chown -R entermedia:entermedia $WEBAPP/WEB-INF/lib
fi

if [[ ! -d $WEBAPP/WEB-INF/data ]]; then
	mkdir -p $WEBAPP/WEB-INF/data
	chown -R entermedia:entermedia $WEBAPP/WEB-INF/data
fi

if [[ ! -d $WEBAPP/WEB-INF/data/system ]]; then
	rsync -ar $EMCOMMON/webapp/WEB-INF/data/system $WEBAPP/WEB-INF/data/
	chown -R entermedia:entermedia $WEBAPP/WEB-INF/data/system
fi

#Always replace the base and lib folders on new container
if [[ ! -d $WEBAPP/WEB-INF/base ]]; then
	rsync -ar --delete --chown=entermedia:entermedia --exclude '/WEB-INF/data' --exclude '/WEB-INF/encrypt.properties' --exclude '/WEB-INF/pluginoverrides.xml' --exclude '/WEB-INF/classes' --exclude '/WEB-INF/elastic' $EMCOMMON/webapp/WEB-INF $WEBAPP/
fi

#Rotate Logs
if [[ ! -f /etc/logrotate.d/tomcat_$CLIENT_NAME ]]; then
	cp $EMCOMMON/resources/logrotate.conf /etc/logrotate.d/tomcat_$CLIENT_NAME
fi

#Always upgrade
rsync -ar --delete --chown=entermedia:entermedia $EMCOMMON/webapp/WEB-INF/bin $WEBAPP/WEB-INF/
rsync -a --chown=entermedia:entermedia $EMCOMMON/webapp/WEB-INF/web.xml $WEBAPP/WEB-INF/web.xml
rsync -a --chown=entermedia:entermedia $EMCOMMON/conf/im/ /usr/local/etc/ImageMagick-7

#Make links and copy stuff
if [[ ! -d $EMTARGET/tomcat/conf ]]; then
	mkdir -p "$EMTARGET/tomcat"/{logs,temp}
	cp -rp "$EMCOMMON/tomcat/conf" "$EMTARGET/tomcat"
	cp -rp "$EMCOMMON/tomcat/bin" "$EMTARGET/tomcat"
	echo "export CATALINA_BASE=\"$EMTARGET/tomcat\"" >>"$EMTARGET/tomcat/bin/setenv.sh"
	sed "s/%PORT%/8080/g;s/%NODE_ID%/${CLIENT_NAME}${INSTANCE_PORT}/g" <"$EMCOMMON/tomcat/conf/server.xml.cluster" >"$EMTARGET/tomcat/conf/server.xml"
	sed "s/%NODE_ID%/${CLIENT_NAME}${INSTANCE_PORT}/g" <"$EMCOMMON/tomcat/bin/catalina.sh.cluster" >"$EMTARGET/tomcat/bin/catalina.sh"
	sed "s/%CLUSTER_NAME%/${CLIENT_NAME}-cluster/g" <"$EMCOMMON/conf/node.xml.cluster" >"$EMTARGET/tomcat/conf/node.xml"
	chmod 755 "$EMTARGET/tomcat/bin/*.sh"
fi

#Deletes all logs
rsync -ar --delete --chown=entermedia:entermedia --exclude '/tomcat/conf/server.xml' --exclude '/tomcat/logs/*' --exclude '/tomcat/conf/node.xml' $EMCOMMON/tomcat $EMTARGET/
mkdir -p "$EMTARGET/tomcat"/{logs,temp}
chown -R entermedia:entermedia $EMTARGET/tomcat

#Remove old node.xml and link new one
rm $WEBAPP/WEB-INF/node.xml
ln -s $EMTARGET/tomcat/conf/node.xml $WEBAPP/WEB-INF/node.xml


if [ ! -f /media/services/startup.sh ]; then
	wget -O /media/services/startup.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/scripts/startup.sh
	chmod +x /media/services/startup.sh
fi

# Execute arbitrary scripts if provided
if [[ -d /media/services ]]; then
	echo ""
	echo "Executing script /media/services/$script"
	for script in $(ls /media/services/*.sh); do
		bash $script
	done
fi

# Execute arbitrary scripts if provided
rm -rf /tmp/unpacked
sudo -u entermedia /usr/bin/entermediadb-extensions-deploy.sh

#Run command
echo Starting EnterMedia ...
pid=0

#SIGTERM-handler
term_handler() {
	pid=$(pgrep -f "$CATALINA_BASE/conf/logging.properties")
	if [[ ! -z $pid ]]; then
		if [ $pid -ne 0 ]; then
			echo "Deployment shutdown start"
			sudo -u entermedia sh -c "$EMTARGET/tomcat/bin/catalina.sh stop"
			kill -SIGTERM "$catalinapid"
			while [ -e /proc/$pid ]; do
				printf .
				sleep 1
			done
		fi
	fi
	exit 143 # 128 + 15 -- SIGTERM
}

#SIGKILL
# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

#Run application
sudo -u entermedia sh -c "$EMTARGET/tomcat/bin/catalina.sh run" &
catalinapid=0
while [ $catalinapid -eq "0" ]; do
	catalinapid=$(pgrep -f "$EMTARGET/tomcat/bin/catalina.sh run")
	sleep 1
done

wait $catalinapid

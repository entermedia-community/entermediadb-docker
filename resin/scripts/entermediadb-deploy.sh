#!/bin/bash -x

# TODO: change parameters to only rely on NODE ID instead of client name and instance port
# Variables CLIENT_NAME and INSTANCE_PORT should be coming from Docker ENV
EMCOMMON=/usr/share/entermediadb
EMTARGET=/opt/entermediadb
WEBAPP=$EMTARGET/webapp
#Finish install
if [[ ! `id -u` -eq 0 ]]; then
	echo You must run this script as a superuser.
	exit 1
fi
if [[ ! `id -u entermedia 2> /dev/null` ]]; then
	groupadd -g $GROUPID entermedia
	useradd -ms /bin/bash entermedia -g entermedia -u $USERID
fi
if [[ ! -d /home/entermedia/.ffmpeg ]]; then
	mkdir /home/entermedia/.ffmpeg
	curl -X GET https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux$EMCOMMON/conf/ffmpeg/libx264-normal.ffpreset?reload=true > /home/entermedia/.ffmpeg/libx264-normal.ffpreset
	chown -R entermedia. /home/entermedia/.ffmpeg
	curl -X GET https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux$EMCOMMON/conf/im/delegates.xml?reload=true > /etc/ImageMagick-6/delegates.xml
	ln -s /opt/libreoffice5.0/program/soffice /usr/bin/soffice
fi
#Copy the starting data


if [[ ! -d $WEBAPP/assets/emshare ]]; then
	mkdir -p $WEBAPP
	rsync -ar $EMCOMMON/webapp/assets $WEBAPP/
fi

if [[ ! -f $WEBAPP/index.html ]]; then
        cp -rp $EMCOMMON/webapp/*.* $WEBAPP/
        cp -rp $EMCOMMON/webapp/media $WEBAPP/
        cp -rp $EMCOMMON/webapp/theme $WEBAPP/
fi

if [[ ! -d $WEBAPP/WEB-INF/data ]]; then
	mkdir -p $WEBAPP/WEB-INF/data
	chown -R entermedia. $WEBAPP/WEB-INF/data
fi

if [[ ! -d $WEBAPP/WEB-INF/data/system ]]; then
        rsync -ar $EMCOMMON/webapp/WEB-INF/data/system $WEBAPP/WEB-INF/data/
	chown -R entermedia. $WEBAPP/WEB-INF/data/system
fi

##Always replace the base and lib folders on new container

if [[ ! -d $WEBAPP/WEB-INF/base ]]; then
	rsync -ar --delete --exclude '/WEB-INF/data'  --exclude '/WEB-INF/encrypt.properties'  --exclude '/WEB-INF/pluginoverrides.xml' --exclude '/WEB-INF/classes' --exclude '/WEB-INF/elastic'  $EMCOMMON/webapp/WEB-INF $WEBAPP/
fi

##always upgrade
rsync -ar --delete $EMCOMMON/webapp/WEB-INF/bin $WEBAPP/WEB-INF/
rsync -a $EMCOMMON/webapp/WEB-INF/web.xml $WEBAPP/WEB-INF/web.xml


if [[ ! -d $EMTARGET/resin/conf ]]; then
	# make links and copy stuff
	mkdir -p "$EMTARGET/resin"/{conf,bin}
        cp  "$EMCOMMON/resin/bin/resin.sh" "$EMTARGET/resin/bin/resin.sh"
	sed "s/%PORT%/8080/g;s/%NODE_ID%/${CLIENT_NAME}${INSTANCE_PORT}/g" <"$EMCOMMON/resin/conf/resin.xml.template" >"$EMTARGET/resin/conf/resin.xml"
	sed "s/%CLUSTER_NAME%/${CLIENT_NAME}-cluster/g" <"$EMCOMMON/conf/node.xml.cluster" >"$EMTARGET/resin/conf/node.xml"
        chmod 755 "$EMTARGET/resin/bin/*.sh"
fi

#rsync -ar --delete --exclude '/resin/conf/resin.conf' --exclude '/resin/logs/*' --exclude '/resin/conf/node.xml'  $EMCOMMON/resin $EMTARGET/
#mkdir -p "$EMTARGET/resin"/{logs,temp}

# Remove old node.xml and link new one
rm $WEBAPP/WEB-INF/node.xml
ln -s $EMTARGET/resin/conf/node.xml $WEBAPP/WEB-INF/node.xml

# Fix permissions

# Not sure why needed, Weird docker thing with exiting sites
chown -R entermedia. /home/entermedia/.ffmpeg

chown -R entermedia. $WEBAPP/WEB-INF/lib
chown -R entermedia. $WEBAPP/WEB-INF/base
chown -R entermedia. $WEBAPP/WEB-INF/bin
chown -R entermedia. $WEBAPP/WEB-INF/tmp
chown -R entermedia. /tmp
chmod 777 /tmp
chown  entermedia. $WEBAPP/WEB-INF
chown  entermedia. $WEBAPP/WEB-INF/*.*
chown  entermedia. $WEBAPP
chown  entermedia. $WEBAPP/*.*
chown -R entermedia. $WEBAPP/assets
chown -R entermedia. $WEBAPP/media
chown -R entermedia. $WEBAPP/theme
chown -R entermedia. $WEBAPP/WEB-INF/elastic
chown -R entermedia. $EMTARGET/resin


# Execute arbitrary scripts if provided
if [[ -d /media/services ]]; then
  chown entermedia. /media/services
  for script in $(ls /media/services/*.sh); do
    bash $script;
  done
fi

#Run command
echo Starting EnterMedia ...

pid=0

# SIGTERM-handler
term_handler() {
  pid=`pgrep -f "resin start"`
if [[ ! -z $pid ]]; then
  if [ $pid -ne 0 ]; then
	echo "Deployment shutdown start"
    kill -SIGTERM "$pid"
	while [ -e /proc/$pid ]
	do
		printf .
		sleep 1
	done    
  fi
fi
  exit 143; # 128 + 15 -- SIGTERM
}

#SIGKILL

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# run application

sudo -u entermedia sh -c "mkdir -p $WEBAPP/WEB-INF/logs/;touch $WEBAPP/WEB-INF/logs/stdout.log"


sudo -u entermedia sh -c "$EMTARGET/resin/bin/resin.sh start"

#pid="$!"


# wait forever
while true
do
  tail -f $WEBAPP/WEB-INF/logs/stdout.log & wait ${!}
done



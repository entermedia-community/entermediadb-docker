#!/bin/bash -x
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
fi

if [[ ! -d $WEBAPP/WEB-INF/data/system ]]; then
        rsync -ar $EMCOMMON/webapp/WEB-INF/data/system $WEBAPP/WEB-INF/data/
fi

##Always replace the base and lib folders on new container
rsync -ar --delete --exclude '/WEB-INF/data' --exclude '/WEB-INF/elastic'  $EMCOMMON/webapp/WEB-INF $WEBAPP/


if [[ ! -d $EMTARGET/tomcat/conf ]]; then
	# make links and copy stuff
	mkdir -p "$EMTARGET/tomcat"/{logs,temp}
        cp -rp "$EMCOMMON/tomcat/conf" "$EMTARGET/tomcat"
        cp -rp "$EMCOMMON/tomcat/bin" "$EMTARGET/tomcat"
	echo "export CATALINA_BASE=\"$EMTARGET/tomcat\"" >> "$EMTARGET/tomcat/bin/setenv.sh"
	sed "s/%PORT%/8080/g;s/%NODE_ID%/${CLIENT_NAME}${INSTANCE_PORT}/g" <"$EMCOMMON/tomcat/conf/server.xml.cluster" >"$EMTARGET/tomcat/conf/server.xml"
	sed "s/%CLUSTER_NAME%/${CLIENT_NAME}-cluster/g" <"$EMCOMMON/conf/node.xml.cluster" >"$EMTARGET/tomcat/conf/node.xml"
        chmod 755 "$EMTARGET/tomcat/bin/*.sh"
	chown -R entermedia. $EMTARGET/tomcat
fi
rm $WEBAPP/WEB-INF/node.xml
ln -s $EMTARGET/tomcat/conf/node.xml $WEBAPP/WEB-INF/node.xml
chown -R entermedia. $WEBAPP/WEB-INF/lib
chown -R entermedia. $WEBAPP/WEB-INF/base
chown -R entermedia. $WEBAPP/WEB-INF/bin
chown -R entermedia. $WEBAPP/WEB-INF/tmp
chown  entermedia. $WEBAPP/WEB-INF
chown  entermedia. $WEBAPP/WEB-INF/*.*
chown  entermedia. $WEBAPP
chown  entermedia. $WEBAPP/*.*
chown -R entermedia. $WEBAPP/assets
chown -R entermedia. $WEBAPP/media
chown -R entermedia. $WEBAPP/theme
chown -R entermedia. $WEBAPP/WEB-INF/elastic
chown entermedia. /media/services


# Execute arbitrary scripts if provided
if [[ -d /media/services ]]; then
  for script in $(ls /media/services/*.sh); do
    bash $script
  done
fi

#Run command
echo Starting EnterMedia ...
sudo -u entermedia sh -c "$EMTARGET/tomcat/bin/catalina.sh run"

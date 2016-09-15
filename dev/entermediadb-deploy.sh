#!/bin/bash -x
# Variables CLIENT_NAME and INSTANCE_PORT should be coming from Docker ENV
#Finish install
if [[ ! -d /home/entermedia ]]; then
	groupadd -g $GROUPID entermedia
	useradd -ms /bin/bash entermedia -g entermedia -u $USERID
	mkdir /home/entermedia/.ffmpeg
	wget -O /home/entermedia/.ffmpeg/libx264-normal.ffpreset https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux/usr/share/entermediadb/conf/ffmpeg/libx264-normal.ffpreset?reload=true
	chown -R entermedia. /home/entermedia/.ffmpeg
	/usr/bin/wget -O /etc/ImageMagick-6/delegates.xml https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux/usr/share/entermediadb/conf/im/delegates.xml?reload=true
	ln -s /opt/libreoffice5.0/program/soffice /usr/bin/soffice
fi
#Copy the starting data


if [[ ! -d /opt/entermediadb/webapp/assets/emshare ]]; then
	mkdir -p /opt/entermediadb/webapp
	rsync -ar /usr/share/entermediadb/webapp/assets /opt/entermediadb/webapp/
fi

if [[ ! -f /opt/entermediadb/webapp/index.html ]]; then
        cp -rp /usr/share/entermediadb/webapp/*.* /opt/entermediadb/webapp/
        cp -rp /usr/share/entermediadb/webapp/media /opt/entermediadb/webapp/
        cp -rp /usr/share/entermediadb/webapp/theme /opt/entermediadb/webapp/
fi


if [[ ! -d /opt/entermediadb/webapp/WEB-INF/data/system ]]; then
        rsync -ar /usr/share/entermediadb/webapp/WEB-INF/data/system /opt/entermediadb/webapp/WEB-INF/data/
fi

##Always replace the base and lib folders on new container
rsync -ar --delete --exclude '/WEB-INF/data' --exclude '/WEB-INF/elastic'  /usr/share/entermediadb/webapp/WEB-INF /opt/entermediadb/webapp/


if [[ ! -d /opt/entermediadb/tomcat/conf ]]; then
	# make links and copy stuff
	mkdir -p "/opt/entermediadb/tomcat"/{logs,temp}
        cp -rp "/usr/share/entermediadb/tomcat/conf" "/opt/entermediadb/tomcat"
        cp -rp "/usr/share/entermediadb/tomcat/bin" "/opt/entermediadb/tomcat"
	echo "export CATALINA_BASE=\"/opt/entermediadb/tomcat\"" >> "/opt/entermediadb/tomcat/bin/setenv.sh"
	sed "s/%PORT%/${INSTANCE_PORT}/g;s/%NODE_ID%/${CLIENT_NAME}${INSTANCE_PORT}/g" <"/usr/share/entermediadb/tomcat/conf/server.xml.cluster" >"/opt/entermediadb/tomcat/conf/server.xml"
	sed "s/%CLUSTER_NAME%/${CLIENT_NAME}-cluster/g" <"/usr/share/entermediadb/conf/node.xml.cluster" >"/opt/entermediadb/tomcat/conf/node.xml"
        chmod 755 "/opt/entermediadb/tomcat/bin/*.sh"
	chown -R entermedia. /opt/entermediadb/tomcat
fi
rm /opt/entermediadb/webapp/WEB-INF/node.xml
ln -s /opt/entermediadb/tomcat/conf/node.xml /opt/entermediadb/webapp/WEB-INF/node.xml
chown -R entermedia. /opt/entermediadb/webapp/WEB-INF/lib
chown -R entermedia. /opt/entermediadb/webapp/WEB-INF/base
chown  entermedia. /opt/entermediadb/webapp/WEB-INF
chown  entermedia. /opt/entermediadb/webapp/WEB-INF/*.*
chown  entermedia. /opt/entermediadb/webapp
chown  entermedia. /opt/entermediadb/webapp/*.*
chown -R entermedia. /opt/entermediadb/webapp/assets
chown -R entermedia. /opt/entermediadb/webapp/media
chown -R entermedia. /opt/entermediadb/webapp/theme


#Run command
echo Starting EnterMedia ...
sudo -u entermedia sh -c "/opt/entermediadb/tomcat/bin/catalina.sh run"

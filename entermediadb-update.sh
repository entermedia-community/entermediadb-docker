#!/bin/bash 
curl -XGET -o /tmp/ROOT.war http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war > /dev/null
#rm -rf /opt/entermediadb/webapp/WEB-INF/{base,lib}
rm -rf /tmp/unzip
mkdir /tmp/unzip

unzip /tmp/ROOT.war 'WEB-INF/*' -d /tmp/unzip > /dev/null

rsync -ar --delete /tmp/unzip/lib /opt/entermediadb/webapp/WEB-INF/
rsync -ar --delete /tmp/unzip/bin /opt/entermediadb/webapp/WEB-INF/
rsync -ar --delete /tmp/unzip/base /opt/entermediadb/webapp/WEB-INF/


chmod 755 /usr/share/entermediadb/webapp/WEB-INF/bin/linux/*.sh

rm /tmp/ROOT.war
rm -rf /tmp/unzip
pid=`pgrep -f "entermediadb-deploy.sh"`
kill -SIGTERM $pid
echo "Docker restarting"


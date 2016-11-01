#!/bin/bash 
curl -XGET -o /tmp/ROOT.war http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war > /dev/null
rm -rf /usr/share/entermediadb/webapp/WEB-INF/{base,lib,bin}
unzip /tmp/ROOT.war 'WEB-INF/base/*' -d /usr/share/entermediadb/webapp/ > /dev/null
unzip /tmp/ROOT.war 'WEB-INF/lib/*' -d /usr/share/entermediadb/webapp/ > /dev/null
unzip /tmp/ROOT.war 'WEB-INF/bin/*' -d /usr/share/entermediadb/webapp/ > /dev/null
chmod 755 /usr/share/entermediadb/webapp/WEB-INF/bin/linux/*.sh
rm /tmp/ROOT.war
pid=`pgrep -f "entermediadb-deploy.sh"`
kill -SIGTERM $pid
echo "Docker restarting"


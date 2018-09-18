#!/bin/bash

key="$1"
BUILD_NUMBER=""
case $key in
    -b|--build)
    BUILD_NUMBER="$2"
    ;;
esac

if [ -z "$BUILD_NUMBER" ]; then
  curl -XGET -o /tmp/ROOT.war http://dev.entermediasoftware.com/jenkins/view/EM9/job/em9_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war > /dev/null
  status=$?
  if [ $status -ne 0 ]; then
    echo "Cannot download the latest WAR on EM9DEV branch"
    exit $status
  fi
else
  curl -XGET -o /tmp/ROOT.war http://dev.entermediasoftware.com/jenkins/view/EM9/job/em9_demoall/"$BUILD_NUMBER"/artifact/deploy/ROOT.war > /dev/null
  status=$?
  if [ $status -ne 0 ]; then
    echo "Cannot download the WAR for build #$BUILD_NUMBER on EM9DEV branch"
    exit $status
  fi
fi

#rm -rf /opt/entermediadb/webapp/WEB-INF/{base,lib}
rm -rf /tmp/unzip
mkdir /tmp/unzip

unzip /tmp/ROOT.war 'WEB-INF/*' -d /tmp/unzip > /dev/null

rsync -ar --delete /tmp/unzip/WEB-INF/lib /opt/entermediadb/webapp/WEB-INF/
rsync -ar --delete /tmp/unzip/WEB-INF/bin /opt/entermediadb/webapp/WEB-INF/
rsync -ar --delete /tmp/unzip/WEB-INF/base /opt/entermediadb/webapp/WEB-INF/
rsync -ar --delete /tmp/unzip/WEB-INF/version.txt /opt/entermediadb/webapp/WEB-INF/

chmod 755 /usr/share/entermediadb/webapp/WEB-INF/bin/linux/*.sh

rm /tmp/ROOT.war
rm -rf /tmp/unzip
pid=`pgrep -f "entermediadb-deploy.sh"`
kill -SIGTERM $pid
echo "Docker restarting"

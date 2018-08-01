#! /bin/sh
#
# See contrib/init.resin for /etc/rc.d/init.d startup script
#
# resin.sh         -- execs resin in the foreground
# resin.sh start   -- starts resin in the background
# resin.sh stop    -- stops resin
# resin.sh restart -- restarts resin
#
# resin.sh will return a status code if the wrapper detects an error, but
# some errors, like bind exceptions or Java errors, are not detected.
#
# To install, you'll need to configure JAVA_HOME and RESIN_HOME and
# copy contrib/init.resin to /etc/rc.d/init.d/resin.  Then
# use "unix# /sbin/chkconfig resin on"


JAVA_HOME="/usr/lib/jvm/jre-1.8.0"
RESIN_HOME="/usr/share/entermediadb/resin"
RESIN_ROOT="/opt/entermediadb/resin"
java=$JAVA_HOME/bin/java

export JAVA_HOME
export RESIN_HOME
export RESIN_ROOT


if test -n "${JAVA_HOME}"; then
  if test -z "${JAVA_EXE}"; then
    JAVA_EXE=$JAVA_HOME/bin/java
  fi
fi

if test -z "${JAVA_EXE}"; then
  JAVA_EXE=java
fi  


cd "${RESIN_HOME}"

exec $JAVA_EXE -jar ${RESIN_HOME}/lib/resin.jar -conf "$RESIN_ROOT/conf/resin.xml" -root-directory "$RESIN_ROOT" -log-directory "$RESIN_ROOT/logs"  $@

#!/bin/bash -x
#
# generate_netreport       Generate real time network reports
#
# chkconfig: 2345 95 05
# description: Create NGINX usage real time HTML report.
#

DIRECTORY="/media/emsites/un3/webapp/report"

if [ ! -d "$DIRECTORY" ]; then
	mkdir $DIRECTORY
fi

sudo goaccess /var/log/nginx/access.log -o $DIRECTORY/report.html --real-time-html &

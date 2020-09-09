#!/bin/bash -x
SITE=$1
NODE=$2

curl -o /media/emsites/$SITE/services/extensions/app-insights.zip http://dev.entermediadb.org/jenkins/job/app-insights/lastSuccessfulBuild/artifact/deploy/app-insights.zip
/media/emsites/$SITE/$NODE/update-em10dev.sh

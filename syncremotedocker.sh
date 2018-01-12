#!/bin/bash -x

#$1 - For remote: username@domain.com:/media/emsites/clientname   -  For Local: /media/emsites/clientname
SOURCE=$1

./stop.sh
rsync -zavh --delete --exclude originals/ --exclude dataexport/ --exclude generated/   $SOURCE/data/ ../data/
rsync -zavh --delete --exclude WEB-INF/ $SOURCE/webapp/ ../webapp/
rsync -zavh --delete  $SOURCE/elastic/repos/ ../elastic/repos/
./start.sh




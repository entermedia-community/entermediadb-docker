#!/bin/bash +x

##
#$1 - username@domain.com
#$2 - remote folder root (docker folder)

./stop.sh
rsync -zavh --delete --exclude originals/ --exclude dataexport/ --exclude generated/   $1/data/ ../data/
rsync -zavh --delete --exclude WEB-INF/ $1/webapp/ ../webapp/
rsync -zavh --delete  $1/elastic/repos/ ../elastic/repos/
./start.sh




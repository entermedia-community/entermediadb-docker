#!/bin/bash -x
DATE=`date '+%Y-%m-%d %H:%M:%S'`
GLOBALDIR="/home/entermedia/globalssl"
CERTSDIR="/home/entermedia/sslcerts"

if [ ! -d "$GLOBALDIR" ]; then
	mkdir $GLOBALDIR
fi

# Get new cert fromb editing-b
scp -i /home/entermedia/.ssh/keys/mediadb31.pk -r entermedia@mediadb31.entermediadb.net:$CERTSDIR $GLOBALDIR

if [ ! -f "$GLOBALDIR/update-globalssl.sh" ]; then
	curl -XGET -o $GLOBALDIR/update-globalssl.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/ssl/update-globalssl.sh
	chmod +x $GLOBALDIR/update-globalssl.sh
fi

# Update cert on node
if sudo $GLOBALDIR/update-globalssl.sh; then
  echo "$DATE - SSL cert renewal success" >> $GLOBALDIR/sucess.log
else
  echo "$DATE - SSL cert renewal failed" >> $GLOBALDIR/error.log
fi

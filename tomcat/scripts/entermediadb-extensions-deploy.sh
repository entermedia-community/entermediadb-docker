#!/bin/bash

DIR="/media/services/extensions"
TMP="/tmp/unpacked"

mkdir -p /tmp/unpacked/extensions

chown -R entermedia. $DIR
if [ "$(ls -A $DIR)" ]; then
  rm -rf $TMP
  for zip in $(ls $DIR/*.zip); do
    mkdir $TMP;
    unzip -o $zip -d $TMP/;
		if [[ -f $TMP/install.xml ]]; then
			ant update-dependencies -f $TMP/install.xml;
			ant unwar -f $TMP/install.xml;
			ant upgrade -f $TMP/install.xml;
			ant extend -f $TMP/install.xml;
		fi
    rm -rf $TMP
  done
fi

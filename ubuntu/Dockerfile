FROM emubuntu
LABEL maintainer="EnterMedia <help@entermediadb.org>"


#Need this?
#epel-release
#gimp

##NOT FOUND
#resilio-sync
#ufraw
#perl-Compress-Zlib  Found: zlib, same?
#libav
#libGL

#imagemagick is 6.9.10


#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh

CMD ["/usr/bin/entermediadb-deploy.sh"]

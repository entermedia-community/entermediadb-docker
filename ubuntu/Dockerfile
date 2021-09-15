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



ADD ./scripts /usr/bin
RUN mkdir -p /tmp/untar && cd /tmp/untar/ && wget http://packages.entermediadb.org/repo/src/entermediadb_em10dev-10.0.tar.gz && tar -xzf entermediadb_em10dev-10.0.tar.gz
RUN cp -rp /tmp/untar/entermediadb_em10dev-10.0/usr/share/entermediadb /usr/share/
RUN rm -rf /tmp/untar
RUN chmod 755

#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh

CMD ["/usr/bin/entermediadb-deploy.sh"]

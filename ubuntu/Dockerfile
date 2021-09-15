FROM entermediadb/emubuntu
#FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

ADD ./scripts /usr/bin
RUN mkdir /tmp/untar
RUN cd /tmp/untar/ ; wget http://packages.entermediadb.org/repo/src/entermediadb_em10dev-10.0.tar.gz
RUN cd /tmp/untar/ ; tar -xzf entermediadb_em10dev-10.0.tar.gz
RUN cp -rp /tmp/untar/entermediadb_em10dev-10.0/usr/share/entermediadb /usr/share/
#RUN rm -rf /tmp/untar

#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh

CMD ["/usr/bin/entermediadb-deploy.sh"]

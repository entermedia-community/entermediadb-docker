FROM entermediadb/emubuntu:latest
LABEL maintainer="EnterMedia <help@entermediadb.org>"

#Environment
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Entermedia server
ADD ./scripts /usr/bin
RUN mkdir /tmp/untar && cd /tmp/untar/ && wget -q http://packages.entermediadb.org/repo/src/entermediadb_em11-11.0.tar.gz && \
    cd /tmp/untar/ && tar -xzf entermediadb_em11-11.0.tar.gz && \
    cp -rp /tmp/untar/entermediadb_em11-11.0/usr/share/entermediadb /usr/share/ && \
    rm -rf /tmp/*

# Resources
COPY ./resources/* /usr/share/entermediadb/resources/
COPY ./resources/delegates.xml /usr/local/share/ImageMagick-7/delegates.xml
COPY ./resources/sysctl.conf /etc/sysctl.conf
COPY ./resources/limits.conf /etc/security/limits.conf
COPY ./resources/nproc.conf /etc/security/limits.d/20-nproc.conf

CMD ["/usr/bin/entermediadb-deploy.sh"]

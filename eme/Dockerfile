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

ARG CACHE_BREAKER=1
RUN mkdir /tmp/untar && cd /tmp/untar/ && wget --no-cache -q http://dev.entermediasoftware.com/jenkins/view/EM12/job/eme-lib/ws/deploy/eme-lib.tar.gz && \
    cd /tmp/untar/ && tar -xzf *.gz && \
    mv  * /usr/share/eme-lib && \
    cp /usr/share/eme-lib/resources/delegates.xml /usr/local/share/ImageMagick-7/delegates.xml && \
    cp /usr/share/eme-lib/resources/sysctl.conf /etc/sysctl.conf && \
    cp /usr/share/eme-lib/resources/limits.conf /etc/security/limits.conf && \
    cp /usr/share/eme-lib/resources/nproc.conf /etc/security/limits.d/20-nproc.conf && \
    rm -rf /tmp/*

CMD ["/usr/bin/entermediadb-deploy.sh"]

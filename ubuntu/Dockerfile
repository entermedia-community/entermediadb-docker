FROM entermediadb/emubuntu
#FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

#Environment
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Entermedia server
ADD ./scripts /usr/bin
RUN mkdir /tmp/untar
RUN cd /tmp/untar/ ; wget http://packages.entermediadb.org/repo/src/entermediadb_em10dev-10.0.tar.gz && \
    cd /tmp/untar/ ; tar -xzf entermediadb_em10dev-10.0.tar.gz && \
    cp -rp /tmp/untar/entermediadb_em10dev-10.0/usr/share/entermediadb /usr/share/ && \
    rm -rf /tmp/*

## faceprofiling
COPY binaries/ binaries
RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && \
    tar -xzvf /binaries/compare.tar.gz --directory /usr/bin && \
    rm -rf /binaries/compare* && \
    cat /binaries/profile/profile* >/binaries/profile.tar.gz && \
    tar -xvzf /binaries/profile.tar.gz --directory /usr/bin && \
    rm -rf /binaries/profile*

# Resources
COPY entermediadb-deploy.sh /usr/bin/
COPY ./resources/* /usr/share/entermediadb/resources/
COPY ./resources/sysctl.conf /etc/sysctl.conf
COPY ./resources/limits.conf /etc/security/limits.conf
COPY ./resources/nproc.conf /etc/security/limits.d/20-nproc.conf

# Run
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
# RUN groupdel dialout
CMD ["/usr/bin/entermediadb-deploy.sh"]

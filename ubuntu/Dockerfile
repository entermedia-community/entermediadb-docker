FROM entermediadb/emubuntu
#FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

ADD ./scripts /usr/bin
RUN mkdir /tmp/untar
RUN cd /tmp/untar/ ; wget http://packages.entermediadb.org/repo/src/entermediadb_em10dev-10.0.tar.gz
RUN cd /tmp/untar/ ; tar -xzf entermediadb_em10dev-10.0.tar.gz
RUN cp -rp /tmp/untar/entermediadb_em10dev-10.0/usr/share/entermediadb /usr/share/
#RUN rm -rf /tmp/untar
RUN apt install -y ant

COPY ./resources/ant.sh /etc/profile.d/ant.sh
COPY binaries/ binaries
RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && \
    tar -xzvf /binaries/compare.tar.gz --directory /usr/bin && \
    rm -rf /binaries/compare* && \
    cat /binaries/profile/profile* >/binaries/profile.tar.gz && \
    tar -xvzf /binaries/profile.tar.gz --directory /usr/bin && \
    rm -rf /binaries/profile*

#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
COPY ./resources/* /usr/share/entermediadb/resources/
COPY ./resources/sysctl.conf /etc/sysctl.conf
COPY ./resources/limits.conf /etc/security/limits.conf
COPY ./resources/nproc.conf /etc/security/limits.d/20-nproc.conf

RUN chmod 755 /usr/bin/entermediadb-deploy.sh
CMD ["/usr/bin/entermediadb-deploy.sh"]

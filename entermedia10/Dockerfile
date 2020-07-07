FROM entermediadb/centos:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum makecache fast && yum clean all && yum -y install unzip entermediadb_em9
ADD ./scripts /usr/bin
COPY ./conf/ant.sh /etc/profile.d/ant.sh
RUN wget https://www-us.apache.org/dist//ant/binaries/apache-ant-1.9.15-bin.zip && unzip apache-ant-1.9.15-bin.zip && rm -f apache-ant-1.9.15-bin.zip && mv apache-ant-1.9.15 /opt/ant && ln -s /opt/ant/bin/ant /usr/bin/ant && chmod +x /etc/profile.d/ant.sh && source /etc/profile.d/ant.sh
COPY ./conf/sysctl.conf /etc/sysctl.conf
COPY ./conf/limits.conf /etc/security/limits.conf
COPY ./insync.tar.gz /usr/bin/
COPY ./gs/gs /usr/bin/
COPY binaries/ binaries
RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && tar -xzvf /binaries/compare.tar.gz --directory /usr/bin
RUN cat /binaries/profile/profile* >/binaries/profile.tar.gz && tar -xvzf /binaries/profile.tar.gz --directory /usr/bin
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
CMD ["/usr/bin/entermediadb-deploy.sh"]

FROM entermediadb/centos:latest
LABEL maintainer="EnterMedia <help@entermediadb.org>"
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum makecache fast && yum clean all && yum -y install unzip entermediadb_em10dev
ADD ./scripts /usr/bin

COPY ./resources/ant.sh /etc/profile.d/ant.sh
COPY binaries/ binaries
RUN unzip /binaries/apache-ant-1.9.15-bin.zip && rm -f apache-ant-1.9.15-bin.zip && mv apache-ant-1.9.15 /opt/ant && ln -f -s /opt/ant/bin/ant /usr/bin/ant && chmod +x /etc/profile.d/ant.sh && source /etc/profile.d/ant.sh
RUN mkdir -p /usr/share/entermediadb/resources
COPY ./resources/* /usr/share/entermediadb/resources/
COPY ./resources/sysctl.conf /etc/sysctl.conf
COPY ./resources/limits.conf /etc/security/limits.conf
COPY ./gs/gs /usr/bin/
RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && tar -xzvf /binaries/compare.tar.gz --directory /usr/bin && cat /binaries/profile/profile* >/binaries/profile.tar.gz && tar -xvzf /binaries/profile.tar.gz --directory /usr/bin
CMD ["/usr/bin/entermediadb-deploy.sh"]

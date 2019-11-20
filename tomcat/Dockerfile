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
ADD ./scripts/entermediadb-deploy.sh /usr/bin/entermediadb-deploy.sh
ADD ./scripts/entermediadb-update.sh /usr/bin/entermediadb-update.sh
ADD ./scripts/entermediadb-update-em9.sh /usr/bin/entermediadb-update-em9.sh
ADD ./scripts/entermediadb-sshd.sh /usr/bin/entermediadb-sshd.sh
ADD ./scripts/entermediadb-buildserver-deploy.sh /usr/bin/entermediadb-buildserver-deploy.sh
ADD ./scripts/entermediadb-extensions-deploy.sh /usr/bin/entermediadb-extensions-deploy.sh
#ADD ./services/startresiliosync.sh /usr/bin/startresiliosync.sh
#ADD ./services/startdropbox.sh /usr/bin/startdropbox.sh
#ADD ./services/startsshd.sh /usr/bin/startsshd.sh
COPY ./conf/ant.sh /etc/profile.d/ant.sh
RUN wget https://www-us.apache.org/dist//ant/binaries/apache-ant-1.9.14-bin.zip && unzip apache-ant-1.9.14-bin.zip && rm -f apache-ant-1.9.14-bin.zip && mv apache-ant-1.9.14 /opt/ant && ln -s /opt/ant/bin/ant /usr/bin/ant && chmod +x /etc/profile.d/ant.sh && source /etc/profile.d/ant.sh
COPY ./conf/sysctl.conf /etc/sysctl.conf
COPY ./conf/limits.conf /etc/security/limits.conf
COPY ./insync.tar.gz /usr/bin/
COPY ./gs/gs /usr/bin/
#RUN su - entermedia -c "pip install awscli --upgrade --user"
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
CMD ["/usr/bin/entermediadb-deploy.sh"]

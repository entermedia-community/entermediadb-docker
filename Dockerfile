FROM entermediadb/centos:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum clean all && yum -y install unzip entermediadb_em9
ADD ./entermediadb-deploy.sh /usr/bin/entermediadb-deploy.sh
ADD ./entermediadb-update.sh /usr/bin/entermediadb-update.sh
ADD ./sysctl.conf /etc/sysctl.conf
ADD ./insync.tar.gz /usr/bin/
ADD ./gs/gs /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
CMD ["/usr/bin/entermediadb-deploy.sh"]


FROM entermediadb/centos:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  
ADD ./sysctl.conf /etc/sysctl.conf
ADD ./rundocker.sh /usr/bin/runelastic.sh
RUN chmod 755 /usr/bin/runelastic.sh
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum clean all && yum -y install unzip elasticdb
CMD ["/usr/bin/rundocker.sh"]


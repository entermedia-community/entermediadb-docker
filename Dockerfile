FROM entermediadb/centos:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum -y install unzip entermediadb_em9
ADD ./entermediadb-deploy.sh /usr/bin/entermediadb-deploy.sh
ADD ./entermediadb-update.sh /usr/bin/entermediadb-update.sh
ADD ./insync.tar.gz /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
RUN /usr/bin/entermediadb-deploy.sh
USER entermedia
CMD ["/bin/java -Djava.util.logging.config.file=/opt/entermediadb/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -d64 -Xms256m -Xmx3024m -XX:+UseG1GC -Djava.security.egd=file:///dev/urandom -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -classpath /usr/share/entermediadb/tomcat/bin/bootstrap.jar:/opt/entermediadb/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/opt/entermediadb/tomcat -Dcatalina.home=/usr/share/entermediadb/tomcat -Djava.io.tmpdir=/opt/entermediadb/tomcat/temp org.apache.catalina.startup.Bootstrap start"]

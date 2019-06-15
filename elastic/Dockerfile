FROM centos:7

ENV USERID=1001
ENV GROUPID=1001
RUN /usr/bin/curl -X GET -o /etc/yum.repos.d/entermedia.repo http://packages.entermediadb.org/repo/centos/7/x86_64/entermedia.repo
RUN curl -XGET -o /etc/yum.repos.d/resilio-sync.repo https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/resiliosync/resilio-sync.repo && rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc
RUN yum update -y && yum install -y wget java-1.8.0-openjdk sudo && yum clean all
RUN rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN yum -y install elasticsearch && yum -y clean all
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers
COPY elastic-entrypoint.sh /
COPY config /usr/share/elasticsearch/config/
COPY config/elasticsearch.in.sh /usr/share/elasticsearch/bin/
RUN chmod 755 elastic-entrypoint.sh
ENTRYPOINT ["/elastic-entrypoint.sh"]

FROM centos:7

ENV USERID=1001
ENV GROUPID=1001
RUN yum update -y && \
yum install -y wget && \
yum install -y java-1.8.0-openjdk && \
yum install -y sudo && \
yum clean all
RUN rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN yum -y install elasticsearch
RUN yum -y clean all
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers  
COPY elastic-entrypoint.sh /
COPY config /usr/share/elasticsearch/config/
RUN chmod 755 elastic-entrypoint.sh
ENTRYPOINT ["/elastic-entrypoint.sh"]

FROM centos:centos7
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
#ENV LANGUAGE en_US.UTF-8 --
ENV LC_ALL en_US.UTF-8
RUN yum update -y && yum install -y sudo rsync lame jdk-12.0.1 ImageMagick libav sudo \
	perl-Compress-Zlib perl-Image-ExifTool ghostscript gimp \
    libreoffice5.0-en-US libreoffice5.0-draw libreoffice5.0-impress libreoffice5.0-calc \
	libreoffice5.0-writer libGL ufraw libwebp-tools resilio-sync \
	ffmpeg wget epel-release logrotate
RUN yum update -y && yum install -y  python-pip && pip install --upgrade pip && pip install awscli --upgrade
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum makecache fast && yum clean all && yum -y install unzip entermediadb_em10
ADD ./scripts /usr/bin
COPY ./conf/ant.sh /etc/profile.d/ant.sh
COPY binaries/ binaries

RUN unzip binaries/apache-ant-1.9.15-bin.zip && rm -f apache-ant-1.9.15-bin.zip && mv apache-ant-1.9.15 /opt/ant && ln -s /opt/ant/bin/ant /usr/bin/ant && chmod +x /etc/profile.d/ant.sh && source /etc/profile.d/ant.sh
RUN /usr/bin/curl -X GET -o /etc/yum.repos.d/entermedia.repo http://packages.entermediadb.org/repo/centos/7/x86_64/entermedia.repo

RUN export JAVA_HOME=/usr/java/latest && export PATH=$PATH:/usr/java/latest/bin && echo "JAVA_HOME=/usr/java/latest" >> /etc/environment && echo "export PATH=$PATH:/usr/java/latest/bin" >> /etc/environment
RUN echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc

COPY ./conf/sysctl.conf /etc/sysctl.conf
COPY ./conf/limits.conf /etc/security/limits.conf
COPY ./insync.tar.gz /usr/bin/
COPY ./gs/gs /usr/bin/

RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && tar -xzvf /binaries/compare.tar.gz --directory /usr/bin
RUN cat /binaries/profile/profile* >/binaries/profile.tar.gz && tar -xvzf /binaries/profile.tar.gz --directory /usr/bin
RUN chmod 755 /usr/bin/entermediadb-deploy.sh
CMD ["/usr/bin/entermediadb-deploy.sh"]

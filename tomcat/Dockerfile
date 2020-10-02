FROM centos:centos7
LABEL maintainer="EnterMedia <help@entermediadb.org>"
ADD ./conf/resilio-sync.repo /etc/yum.repos.d/
ADD ./conf/entermedia.repo /etc/yum.repos.d/
ADD ./conf/resilio-key.asc ./
RUN rpm --import resilio-key.asc && rm -f resilio-key.asc

RUN yum update -y && yum install -y sudo rsync lame jdk-12.0.1 ImageMagick libav \
    perl-Compress-Zlib perl-Image-ExifTool ghostscript gimp \
    libreoffice5.0-en-US libreoffice5.0-draw libreoffice5.0-impress libreoffice5.0-calc \
    libreoffice5.0-writer libGL ufraw libwebp-tools resilio-sync \
    ffmpeg wget epel-release
RUN yum install -y python-pip && pip install --upgrade pip && pip install awscli --upgrade
RUN export JAVA_HOME=/usr/java/latest && export PATH=$PATH:/usr/java/latest/bin && echo "JAVA_HOME=/usr/java/latest" >> /etc/environment && echo "export PATH=$PATH:/usr/java/latest/bin" >> /etc/environment
RUN echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc

ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && yum makecache fast && yum clean all && yum -y install unzip entermediadb_em10dev
ADD ./scripts /usr/bin
RUN ln -s /opt/libreoffice5.0/program/soffice /usr/bin/soffice
COPY ./resources/ant.sh /etc/profile.d/ant.sh
COPY binaries/ binaries
RUN unzip /binaries/apache-ant-1.9.15-bin.zip && rm -f apache-ant-1.9.15-bin.zip && mv apache-ant-1.9.15 /opt/ant && ln -f -s /opt/ant/bin/ant /usr/bin/ant && chmod +x /etc/profile.d/ant.sh && source /etc/profile.d/ant.sh

RUN mkdir -p /usr/share/entermediadb/resources
COPY ./resources/* /usr/share/entermediadb/resources/
COPY ./resources/sysctl.conf /etc/sysctl.conf
COPY ./resources/limits.conf /etc/security/limits.conf
COPY ./resources/nproc.conf /etc/security/limits.d/20-nproc.conf
COPY ./gs/gs /usr/bin/
RUN cat /binaries/compare/compare* >/binaries/compare.tar.gz && tar -xzvf /binaries/compare.tar.gz --directory /usr/bin && cat /binaries/profile/profile* >/binaries/profile.tar.gz && tar -xvzf /binaries/profile.tar.gz --directory /usr/bin
CMD ["/usr/bin/entermediadb-deploy.sh"]

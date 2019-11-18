FROM centos:centos7
RUN /usr/bin/curl -X GET -o /etc/yum.repos.d/entermedia.repo http://packages.entermediadb.org/repo/centos/7/x86_64/entermedia.repo
RUN curl -XGET -o /etc/yum.repos.d/resilio-sync.repo https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/resiliosync/resilio-sync.repo && rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc
RUN yum update -y && yum install -y sudo rsync lame jdk-12.0.1 ImageMagick libav \
	perl-Compress-Zlib perl-Image-ExifTool ghostscript gimp \
    libreoffice5.0-en-US libreoffice5.0-draw libreoffice5.0-impress libreoffice5.0-calc \
	libreoffice5.0-writer libGL ufraw libwebp-tools resilio-sync \
	ffmpeg wget epel-release logrotate
RUN yum update -y && yum install -y  python-pip && pip install --upgrade pip && pip install awscli --upgrade
RUN export JAVA_HOME=/usr/java/latest && export PATH=$PATH:/usr/java/latest/bin && echo "JAVA_HOME=/usr/java/latest" >> /etc/environment && echo "export PATH=$PATH:/usr/java/latest/bin" >> /etc/environment
RUN echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
CMD /bin/bash

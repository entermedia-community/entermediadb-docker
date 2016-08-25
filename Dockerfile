FROM centos:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
ENV CLIENT_NAME=entermedia
ENV INSTANCE_PORT=8080
ENV USERID=9009
ENV GROUPID=9009
COPY resolv.conf /etc/resolv.conf
RUN yum -y install --nogpgcheck wget
RUN /usr/bin/wget -O /etc/yum.repos.d/entermedia.repo http://packages.entermediadb.org/repo/centos/7/x86_64/entermedia.repo
RUN yum -y install entermediadb_em9dev
RUN  /usr/bin/wget -O /etc/ImageMagick-6/delegates.xml https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux/usr/share/entermediadb/conf/im/delegates.xml?reload=true
RUN ln -s /opt/libreoffice5.0/program/soffice /usr/bin/soffice
RUN  /usr/bin/wget -O /usr/bin/entermediadb-deploy https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux/usr/bin/entermediadb-deploy?reload=true
RUN chmod 755 /usr/bin/entermediadb-deploy
RUN groupadd -g $GROUPID entermedia
RUN useradd -ms /bin/bash entermedia -g entermedia -u $USERID
USER entermedia
RUN mkdir /home/entermedia/.ffmpeg
RUN wget -O /home/entermedia/.ffmpeg/libx264-normal.ffpreset https://raw.githubusercontent.com/entermedia-community/entermediadb-installers/master/linux/usr/share/entermediadb/conf/ffmpeg/libx264-normal.ffpreset?reload=true
CMD ["/usr/bin/entermediadb-deploy"]

FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"


ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update

RUN apt-get install -y sudo rsync wget openjdk-16-jdk \
    ghostscript libwebp-dev imagemagick \
    libimage-exiftool-perl  \
    libreoffice \
    ffmpeg lame

RUN apt-get install git curl && cd /tmp && git clone https://github.com/SoftCreatR/imei && \
cd imei && \
chmod +x imei.sh && \
./imei.sh

#Need this?
#epel-release
#gimp

##NOT FOUND
#resilio-sync
#ufraw
#perl-Compress-Zlib  Found: zlib, same?
#libav
#libGL

#imagemagick is 6.9.10


#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh

CMD ["/usr/bin/entermediadb-deploy.sh"]

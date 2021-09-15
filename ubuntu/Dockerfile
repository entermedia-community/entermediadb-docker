FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

RUN apt-get update -y && apt-get install -y sudo rsync wget openjdk-16-jdk \
    ghostscript libwebp-dev imagemagick \
    libimage-exiftool-perl  \
    libreoffice \
    ffmpeg lame

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

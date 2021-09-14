FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

#RUN apt-get update -y && apt-get install -y sudo rsync lame jdk-12.0.1 imagemagick libav \
#    perl-Compress-Zlib perl-Image-ExifTool ghostscript gimp \
#    libreoffice5.0-en-US libreoffice5.0-draw libreoffice5.0-impress libreoffice5.0-calc \
#    libreoffice5.0-writer libGL ufraw libwebp-tools resilio-sync \
#    ffmpeg wget epel-release


#RUN mkdir -p /usr/share/entermediadb/resources
COPY entermediadb-deploy.sh /usr/bin/
RUN chmod 755 /usr/bin/entermediadb-deploy.sh

CMD ["/usr/bin/entermediadb-deploy.sh"]

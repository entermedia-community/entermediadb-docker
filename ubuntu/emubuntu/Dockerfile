# ubuntu base dependencies in emubuntu and have it build whatever it needs then clean up after itself
# Then just put only entermedia stuff in the main Dockerfile

FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN add-apt-repository multiverse
RUN add-apt-repository main
RUN add-apt-repository restricted

# general 
RUN apt-get install -y sudo rsync wget openjdk-16-jdk \
    ghostscript libwebp-dev imagemagick \
    libimage-exiftool-perl  \
    libreoffice \
    ffmpeg lame
RUN apt-get install -y git curl
# gimp
RUN add-apt-repository ppa:ubuntuhandbook1/gimp
RUN apt install -y gimp gimp-gmic

# ufraw
RUN apt-get install -y libgtk2.0-dev liblcms-dev libgimp2.0-dev libtiff-dev libpng-dev libexiv2-dev zlib1g-dev libbz2-dev libjpeg-turbo8-dev
RUN cd /tmp && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw-batch_0.22-3.1~build0.18.04.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/e/exiv2/libexiv2-14_0.25-3.1ubuntu0.18.04.11_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkimageview/libgtkimageview0_1.6.4+dfsg-2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw_0.22-3.1~build0.18.04.1_amd64.deb
RUN cd /tmp && apt-get install -y ./*.deb

# zlib
RUN apt install -y libcompress-zlib-perl zlib1g
RUN apt install -y zip unzip
#libGL
RUN apt install -y libgl-dev

# ImageMagick
RUN cd /tmp && git clone https://github.com/SoftCreatR/imei && \
    cd imei && \
    chmod +x imei.sh && \
    ./imei.sh
RUN rm -rf /tmp/imei

#resilio-sync
RUN cd /tmp && \
    wget https://download-cdn.resilio.com/2.7.2.1375/Debian/resilio-sync_2.7.2.1375-1_amd64.deb && \
    apt-get install -y ./resilio*.deb

#RUN mkdir -p /usr/share/entermediadb/resources
#COPY entermediadb-deploy.sh /usr/bin/
#RUN chmod 755 /usr/bin/entermediadb-deploy.sh
#CMD ["/usr/bin/entermediadb-deploy.sh"]

# ubuntu base dependencies in emubuntu and have it build whatever it needs then clean up after itself
# Then just put only entermedia stuff in the main Dockerfile

FROM ubuntu:20.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"


ENV DEBIAN_FRONTEND=noninteractive

RUN add-apt-repository universe && \
    add-apt-repository multiverse && \
    add-apt-repository main && \
    add-apt-repository restricted && \
    add-apt-repository ppa:ubuntuhandbook1/gimp

# general    --no-install-recommends
RUN apt-get update && apt upgrade -y
RUN apt-get install -y software-properties-common \
    sudo rsync wget openjdk-16-jdk \
    ghostscript libwebp-dev imagemagick \
    libimage-exiftool-perl  \
    libreoffice \
    ffmpeg libaom-dev lame \
    git curl ant python3-pip \
    gimp gimp-gmic libgimp2.0-dev libtiff-dev libpng-dev libexiv2-dev \
    locales \
    libcompress-zlib-perl zlib1g zlib1g-dev zip unzip libgl-dev libbz2-dev libjpeg-turbo8-dev \
    libgtk2.0-dev liblcms-dev 

#set Locale
RUN locale-gen en_US en_US.UTF-8

# python
RUN pip3 install awscli --upgrade

# ufraw
RUN cd /tmp && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw-batch_0.22-3.1~build0.18.04.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/e/exiv2/libexiv2-14_0.25-3.1ubuntu0.18.04.11_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkimageview/libgtkimageview0_1.6.4+dfsg-2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw_0.22-3.1~build0.18.04.1_amd64.deb
RUN cd /tmp && apt-get install -y ./*.deb

# ImageMagick
RUN cd /tmp && git clone https://github.com/SoftCreatR/imei && \
    cd imei && \
    chmod +x imei.sh && \
    ./imei.sh
RUN rm -rf /tmp/imei

#resilio-sync
# RUN cd /tmp && \
#     wget https://download-cdn.resilio.com/2.7.2.1375/Debian/resilio-sync_2.7.2.1375-1_amd64.deb && \
#     apt-get install -y ./resilio*.deb


# Apache-ant bin
RUN groupdel dialout
RUN mkdir -p /tmp/embinaries
COPY binaries/* /tmp/embinaries
RUN mkdir -p /etc/profile.d
COPY ./resources/ant.sh /etc/profile.d/ant.sh
RUN cd /tmp/embinaries && unzip /tmp/embinaries/apache-ant-1.9.15-bin.zip && \
    mv /tmp/embinaries/apache-ant-1.9.15 /opt/ant 
RUN ln -f -s /opt/ant/bin/ant /usr/bin/ant 
RUN chmod +x /etc/profile.d/ant.sh && \
    bash /etc/profile.d/ant.sh

RUN rm -rf /tmp/*
RUN rm -rf /var/lib/apt/lists/*


FROM ubuntu:22.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe && \
    add-apt-repository multiverse && \
    add-apt-repository main && \
    add-apt-repository restricted 
RUN add-apt-repository ppa:ubuntuhandbook1/gimp

# general    --no-install-recommends
RUN apt-get update 
RUN apt-get install -y sudo vim rsync wget \
    ghostscript libwebp-dev \
    libimage-exiftool-perl  \
    ffmpeg libaom-dev lame \
    git curl python3-pip \
    libtiff-dev libpng-dev libexiv2-dev \
    locales \
    libcompress-zlib-perl zlib1g zlib1g-dev zip unzip libgl-dev libbz2-dev libjpeg-turbo8-dev \
    libgtk2.0-dev liblcms-dev 

# ImageMagick
RUN cd /tmp && git clone https://github.com/SoftCreatR/imei && \
    cd imei && \
    chmod +x imei.sh && \
    ./imei.sh
RUN rm -rf /tmp/imei

RUN apt-get install -y openjdk-18-jdk \
    libreoffice \
    ant \
    ldap-utils 

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

RUN apt-get install -y ufraw-batch



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


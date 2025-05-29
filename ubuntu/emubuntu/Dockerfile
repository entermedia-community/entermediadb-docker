FROM ubuntu:22.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Add APT repositories
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe && \
    add-apt-repository multiverse && \
    add-apt-repository restricted && \
    apt-get update

# Set locale
RUN locale-gen en_US.UTF-8

# Install runtime packages (will reinstall after cleanup to keep)
RUN apt-get install -y --no-install-recommends \
    python3-pip ghostscript ffmpeg \
    sudo vim rsync curl zip unzip \
    locales openjdk-18-jdk libreoffice ldap-utils
    git wget build-essential \
    libwebp-dev libaom-dev \
    libtiff-dev libpng-dev libexiv2-dev \
    libgl-dev libbz2-dev libjpeg-turbo8-dev libgtk2.0-dev \
    liblcms-dev libimage-exiftool-perl \
    zlib1g-dev libcompress-zlib-perl

# --- Manual install ufraw and deps ---
RUN cd /tmp && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw-batch_0.22-3.1~build0.18.04.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/e/exiv2/libexiv2-14_0.25-3.1ubuntu0.18.04.11_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkimageview/libgtkimageview0_1.6.4+dfsg-2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw_0.22-3.1~build0.18.04.1_amd64.deb && \
    apt-get install -y ./libexiv2-14_*.deb ./libgtkimageview0_*.deb ./ufraw_*.deb ./ufraw-batch_*.deb && \
    rm -rf /tmp/*

# --- Build and install ImageMagick via external script ---
RUN cd /tmp && \
    git clone https://github.com/SoftCreatR/imei && \
    cd imei && chmod +x imei.sh && ./imei.sh && \
    rm -rf /tmp/*

# --- Remove build dependencies ---
RUN apt-get remove -y --purge \
    build-essential git \
    libwebp-dev libaom-dev \
    libtiff-dev libpng-dev libexiv2-dev \
    libgl-dev libbz2-dev libjpeg-turbo8-dev libgtk2.0-dev \
    liblcms-dev zlib1g-dev libcompress-zlib-perl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/* \
    /usr/share/man/* \
    /usr/share/groff/* \
    /usr/share/info/* \
    /usr/share/lintian/* \
    /usr/share/linda/* \
    /var/cache/man/* 
    ## remove locales not needed
    ##&& \
    ##find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' -exec rm -rf {} +

# Upgrade pip and install runtime Python packages
RUN pip3 install --no-cache-dir --upgrade pip awscli

#CMD ["/bin/bash"]

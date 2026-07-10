FROM ubuntu:26.04
LABEL maintainer="EnterMedia <help@entermediadb.org>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV LD_LIBRARY_PATH=/usr/local/lib

# Add APT repositories
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    add-apt-repository -y restricted 
    

# Install runtime packages (will reinstall after cleanup to keep)
RUN apt-get install -y --no-install-recommends \
    python3-pip ghostscript ffmpeg \
    sudo vim rsync curl zip unzip \
    locales default-jdk libreoffice ldap-utils  \
    wget 

# Set locale & setp libraries path & install pip3
RUN locale-gen en_US.UTF-8 && \
    ldconfig /usr/lib64 

# --- Build and install ImageMagick via external script && Remove build dependencies ---
RUN apt-get install -y build-essential \
    git libwebp-dev libaom-dev \
    libtiff-dev libpng-dev libexiv2-dev \
    libgl-dev libbz2-dev libjpeg-turbo8-dev libgtk2.0-dev \
    liblcms-dev libimage-exiftool-perl \
    zlib1g-dev libcompress-zlib-perl && \
    mkdir -p /tmp && cd /tmp && \
    git clone https://github.com/SoftCreatR/imei && \
    cd imei && chmod +x imei.sh && ./imei.sh && \
    rm -rf /tmp/* && \
    apt-get remove -y --purge \
    build-essential \
    libaom-dev libtiff-dev libwebp-dev libpng-dev libexiv2-dev \
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

#CMD ["/bin/bash"]

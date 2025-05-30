# -------- Stage 1: Build ufraw + ImageMagick --------
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install base tools & build deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget git build-essential software-properties-common \
    libwebp-dev libaom-dev \
    libtiff-dev libpng-dev libexiv2-dev \
    libgl-dev libbz2-dev libjpeg-turbo8-dev libgtk2.0-dev \
    liblcms-dev libimage-exiftool-perl \
    zlib1g-dev libcompress-zlib-perl \
    ffmpeg ghostscript

# Install ufraw manually
RUN cd /tmp && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw-batch_0.22-3.1~build0.18.04.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/e/exiv2/libexiv2-14_0.25-3.1ubuntu0.18.04.11_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkimageview/libgtkimageview0_1.6.4+dfsg-2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/u/ufraw/ufraw_0.22-3.1~build0.18.04.1_amd64.deb && \
    apt-get install -y ./*.deb

# Install ImageMagick using imei script
RUN cd /tmp && git clone https://github.com/SoftCreatR/imei && \
    cd imei && chmod +x imei.sh && ./imei.sh && rm -rf /tmp/*

# Collect runtime binaries and shared libs
RUN mkdir -p /stage/usr/local/bin /stage/usr/bin /stage/usr/lib /stage/lib

# Copy selected binaries
RUN cp /usr/local/bin/convert /stage/usr/local/bin/ && \
    cp /usr/local/bin/identify /stage/usr/local/bin/ && \
    cp /usr/bin/ufraw /stage/usr/bin/ && \
    cp -rp /usr/local/lib /stage/usr/local/ && \
    cp -rp /usr/lib/x86_64-linux-gnu /stage/usr/lib/ 

# Use ldd to gather only required shared libs
RUN for bin in /stage/usr/local/bin/*; do \
      ldd $bin | awk '{print $3}' | grep -E '^/' | xargs -I '{}' cp -v --parents '{}' /stage ; \
    done

# Copy any runtime data files ImageMagick needs
RUN mkdir -p /stage/usr/local/etc && \
    cp -r /usr/local/etc/ImageMagick* /stage/usr/local/etc/

# -------- Stage 2: Final Slim Runtime --------
FROM ubuntu:22.04 AS final

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV LD_LIBRARY_PATH=/usr/local/lib

# Minimal system packages only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip ffmpeg ghostscript \
    sudo vim rsync curl zip unzip \
    openjdk-18-jdk libreoffice ldap-utils locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8

# Copy only required binaries + libs
COPY --from=builder /stage/usr /usr

# Clean junk: docs, man, extra locales
RUN rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* \
    /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* 
    ##&& \
    ##find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' -exec rm -rf {} +

# Python tools
RUN pip3 install --no-cache-dir --upgrade pip awscli


CMD ["/bin/bash"]

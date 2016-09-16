FROM centos:latest
RUN yum install -y sudo rsync
RUN /usr/bin/curl -X GET -o /etc/yum.repos.d/entermedia.repo http://packages.entermediadb.org/repo/centos/7/x86_64/entermedia.repo
RUN yum install -y lame java-1.8.0-openjdk ImageMagick libav \
	perl-Image-ExifTool ghostscript gimp libreoffice5.0-en-US \
	libreoffice5.0-draw libreoffice5.0-impress libreoffice5.0-calc \
	libreoffice5.0-writer libGL ufraw libwebp-tools
CMD /bin/bash

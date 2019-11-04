FROM jenkins/jenkins:lts

USER root
COPY ./scripts/init-jenkins.sh /media/service/init-jenkins.sh
RUN sudo apt update -y && sudo apt install -y apt-file sudo vim ffmpeg exiftool zip openjdk-8-jdk
RUN adduser jenkins sudo && rm /docker-java-home && ln -s /usr/lib/jvm/java-8-openjdk-amd64  /usr/lib/jvm/java-1.8.0-openjdk &&ln -s /usr/lib/jvm/java-1.8.0-openjdk /docker-java-home && chown jenkins. /media/service/init-jenkins.sh

FROM entermediadb/entermediadb9:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
RUN yum install -y unzip
RUN wget http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war > /dev/null
RUN rm -rf /usr/share/entermediadb/webapp/WEB-INF/base
RUN rm -rf /usr/share/entermediadb/webapp/WEB-INF/lib
RUN unzip ROOT.war 'WEB-INF/base/*' -d /usr/share/entermediadb/webapp/ > /dev/null
RUN unzip ROOT.war 'WEB-INF/lib/*' -d /usr/share/entermediadb/webapp/ > /dev/null
RUN rm ROOT.war
CMD ["/usr/bin/entermediadb-deploy.sh"]

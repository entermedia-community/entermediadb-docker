FROM entermediadb/entermediadb9:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
RUN yum install -y unzip
RUN wget http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war
RUN rm -rf /opt/entermediadb/webapp/WEB-INF/base
RUN rm -rf /opt/entermediadb/webapp/WEB-INF/lib
RUN unzip ROOT.war 'WEB-INF/base/' -d /usr/share/entermediadb/webapp/
RUN unzip ROOT.war 'WEB-INF/lib/' -d /usr/share/entermediadb/webapp/
RUN rm ROOT.war
CMD ["/usr/bin/entermediadb-deploy.sh"]

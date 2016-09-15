FROM em9:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
RUN yum install -y unzip
RUN wget http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war
RUN rm -rf /opt/entermediadb/webapp/WEB-INF/base
RUN rm -rf /opt/entermediadb/webapp/WEB-INF/lib
RUN unzip ROOT.war 'WEB-INF/base' -d /opt/entermediadb/webapp/WEB-INF/
RUN unzip ROOT.war 'WEB-INF/lib' -d /opt/entermediadb/webapp/WEB-INF/
RUN chown -R entermedia. /opt/entermediadb/webapp/WEB-INF/base
RUN chown -R entermedia. /opt/entermediadb/webapp/WEB-INF/lib
CMD ["/usr/bin/entermediadb-deploy.sh"]

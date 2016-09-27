FROM entermediadb/entermediadb9:latest
MAINTAINER "EnterMedia" <help@entermediadb.org>
RUN rm -f /usr/bin/entermediadb-update.sh
ADD ./entermediadb-update.sh /usr/bin/entermediadb-update.sh
RUN chmod 755 /usr/bin/entermediadb-update.sh
RUN yum install -y unzip
RUN curl -X GET -o /tmp/ROOT.war http://dev.entermediasoftware.com/jenkins/view/EM9DEV/job/em9dev_demoall/lastSuccessfulBuild/artifact/deploy/ROOT.war > /dev/null
RUN rm -rf /usr/share/entermediadb/webapp/WEB-INF/base
RUN rm -rf /usr/share/entermediadb/webapp/WEB-INF/lib
RUN unzip /tmp/ROOT.war 'WEB-INF/base/*' -d /usr/share/entermediadb/webapp/ > /dev/null
RUN unzip /tmp/ROOT.war 'WEB-INF/lib/*' -d /usr/share/entermediadb/webapp/ > /dev/null
RUN rm /tmp/ROOT.war
CMD ["/usr/bin/entermediadb-deploy.sh"]

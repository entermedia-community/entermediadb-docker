FROM juanluisbaptiste/postfix
RUN sed -i '/smtp      inet  n       -       n       -       -       smtpd/a 2520      inet  n     	-     	n     	-     	-     	smtpd' /etc/postfix/master.cf
RUN sed -i '/#submission inet n       -       n       -       -       smtpd/a submission inet n       -       n       -       -       smtpd' /etc/postfix/master.cf
RUN sed -i '/relayhost=[smtp.entermediadb.org]:2520/a relayhost=' /etc/postfix/main.cf
RUN sed -i '/mydestination=$myhostname/a mydestination=' /etc/postfix/main.cf
ADD ./scripts/maillogs.sh /usr/bin/maillogs.sh
ADD ./scripts/reload-postfix.sh /usr/bin/reload-postfix.sh
ADD ./scripts/processmailqueue.sh /usr/bin/processmailqueue.sh
RUN ls -la /usr/bin/
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

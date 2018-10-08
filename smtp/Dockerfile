FROM juanluisbaptiste/postfix
RUN sed '/smtp      inet  n       -       n       -       -       smtpd/a 2520      inet  n     	-     	n     	-     	-     	smtpd' /etc/postfix/master.cf
RUN sed -i '/#submission inet n       -       n       -       -       smtpd/a submission inet n       -       n       -       -       smtpd' /etc/postfix/master.cf
RUN sed -i '/relayhost=[smtp.entermediadb.org]:2520/a relayhost=' /etc/postfix/main.cf
RUN sed -i '/mydestination=$myhostname/a mydestination=' /etc/postfix/main.cf
RUN postfix reload
ADD ./scripts/maillogs.sh /usr/bin/maillogs.sh
ADD ./scripts/processmailqueue.sh /usr/bin/processmailqueue.sh
RUN chmod +x /usr/bin/maillogs.sh /usr/bin/processmailqueue.sh
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
CMD /bin/bash

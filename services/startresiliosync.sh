#!/bin/bash
chmod +x /opt/entermediadb/webapp/WEB-INF/bin/linux/*.sh
su - entermedia -c "/opt/entermediadb/webapp/WEB-INF/bin/linux/setupresiliodrive.sh restart /opt/entermediadb/webapp/WEB-INF/data"

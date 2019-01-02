#!/bin/sh

set -e
EM_REPO='[entermediadb]\nname=EnterMedia CentOS Dependencies\n#CentOS 7\nbaseurl=http://packages.entermediadb.org/repo/centos/7/x86_64/rpms\n# or CentOS 6\n#baseurl=http://packages.entermediadb.org/repo/centos/6/x86_64/rpms\npriority=1\nenabled=1\ngpgcheck=0'

curl -s https://get.docker.com/ | sudo bash -s
sudo yum remove -y docker docker-common docker-selinux docker-engine-selinux docker-engine docker-ce
sudo yum-config-manager --disable docker-ce-edge
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install -y docker-ce
sudo systemctl enable docker
sudo service docker start
sudo yum install -y wget
sudo wget -O /root/firewall.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/scripts/firewall.sh && chmod +x /root/firewall.sh && sudo /root/firewall.sh

# NGINX
echo -e $EM_REPO > /etc/yum.repos.d/entermedia.repo
sudo yum clean all
sudo yum -y remove nginx
sudo yum -y install nginx-1.10.0-1.el7.centos.ngx
sudo systemctl enable nginx
sudo setsebool -P httpd_can_network_connect 1
sudo service nginx start

# EM DAM installer
curl -o /home/entermedia/entermedia-docker.sh -jL docker.entermediadb.org

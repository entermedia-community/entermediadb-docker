# might have to update bind_address= or host= in build/my.cnf ?


CLIENT=$1
if [[ ! $CLIENT ]]; then
	echo "You must specify a client to use this script!";
	exit 1
fi
DIR_ROOT=/media/clients/$CLIENT

sudo groupadd -g 105 mysql
sudo useradd -ms /bin/bash mysql -g mysql -u 103

sudo mkdir -p $DIR_ROOT/mysql
sudo chown -R mysql. $DIR_ROOT/mysql

sudo docker stop entermedia_mysql
sudo docker rm entermedia_mysql

if [[ ! $(sudo docker network ls | grep embridge) ]]; then
	sudo docker network create --subnet=172.18.0.0/16 embridge
fi

sudo docker run -d -t \
	--net embridge \
	--ip 172.18.0.2 \
	--name entermedia_mysql \
	-v $DIR_ROOT/mysql:/var/lib/mysql -p 127.0.0.1:3306:3306 -d emmysql  /sbin/my_init
echo sudo docker exec -it -u 0 entermedia_mysql /bin/bash
echo mysql -u root -p
echo password: root
echo "CREATE USER 'drupal';"

echo "GRANT ALL PRIVILEGES ON *.* TO 'drupal'@'%' WITH GRANT OPTION;"
# Should we be granting privileges for 'drupal'@'%' or 172.18.0.1 or something?

echo "SET PASSWORD FOR 'drupal' = PASSWORD('mypass');"

echo sudo docker exec -it entermedia_mysql /bin/bash
echo mysql -p -u drupal -h 172.18.0.2 -P 3306
echo mysql -p -u root -h localhost -P 3306


#!/bin/bash
if [ ! -f /var/www/moodle/config.php ]; then
  MOODLE_DB=$MYSQL_DB
  MYSQL_PASSWORD=$MYSQL_PASSWORD
  MOODLE_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo moodle password: $MOODLE_PASSWORD
 
  sed -e "s/pgsql/mysqli/
  s/username/moodle/
  s/password/$MOODLE_PASSWORD/
  s/localhost/$MYSQL_HOST/
  s/example.com/$VIRTUAL_HOST/
  s/\/home\/example\/moodledata/\/var\/moodledata/" /var/www/html/moodle/config-dist.php > /var/www/html/moodle/config.php

  sed -i 's/PermitRootLogin without-password/PermitRootLogin Yes/' /etc/ssh/sshd_config

  chown www-data:www-data /var/www/html/moodle/config.php

  mysqladmin -u root password $MYSQL_PASSWORD
  mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE moodle; GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost' IDENTIFIED BY '$MOODLE_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld
fi
# start all the services
/usr/local/bin/supervisord -n

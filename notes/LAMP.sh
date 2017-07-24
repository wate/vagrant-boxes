#!/bin/bash

# @sacloud-once
#
# @sacloud-desc Apache, PHP, MariaDBをインストールします。
# @sacloud-require-archive distro-centos distro-ver-7.*
# @sacloud-radios-begin required default=remi-php70 php_version "利用するPHPのバージョン"
#  remi-php54   "5.4"
#  remi-php55   "5.5"
#  remi-php56   "5.6"
#  remi-php70   "7.0"
# @sacloud-radios-end
# @sacloud-password minlen=8 mariadb_root_password "MariaDBのrootパスワード" ex="省略された場合は自動生成されます"

REMI_PHP_REPO_ID=@@@php_version@@@
MARIADB_ROOT_PASSWIRD=@@@mariadb_root_password@@@

if [ "$REMI_PHP_REPO_ID" = "@@@php_version@@@" ]; then
  REMI_PHP_REPO_ID="remi-php70"
fi
if [ "$MARIADB_ROOT_PASSWIRD" = "@@@mariadb_root_password@@@" ]; then
  yum install -y expect || exit 1
  MARIADB_ROOT_PASSWIRD=$(mkpasswd -l 32 -d 9 -c 9 -C 9 -s 0 -2)
fi
yum update -y

yum install -y firewalld || exit 1
systemctl start firewalld.service || exit 1
systemctl enable firewalld.service || exit 1

yum install -y httpd mod_ssl || exit 1

systemctl start httpd.service || exit 1
systemctl enable httpd.service || exit 1
firewall-cmd --add-service=http --zone=public --permanent || exit 1
firewall-cmd --add-service=https --zone=public --permanent || exit 1
firewall-cmd --reload || exit 1

yum install -y --enablerepo=epel,remi,${REMI_PHP_REPO_ID} php php-devel php-pear php-gd php-pdo php-intl php-mcrypt php-mbstring php-mysqlnd php-xml || exit 1

yum install -y mariadb-server || exit 1
systemctl start mariadb.service || exit 1
systemctl enable mariadb.service || exit 1

# Remove anonymous users
/usr/bin/mysql -u root -D mysql -e "DELETE FROM user WHERE User='';"
# Disallow root login remotely
/usr/bin/mysql -u root -D mysql -e "DELETE FROM user WHERE User='root' AND Host NOT IN ('localhost',  '127.0.0.1',  '::1');"
# Remove test database
/usr/bin/mysql -u root -e "DROP DATABASE test;"
# Change MariaDB root password
/usr/bin/mysqladmin -u root password "$MARIADB_ROOT_PASSWIRD" || exit 1

cat <<EOT > /root/.my.cnf
[client]
host     = localhost
user     = root
password = $MARIADB_ROOT_PASSWIRD
socket   = /var/lib/mysql/mysql.sock
EOT
chmod 600 /root/.my.cnf

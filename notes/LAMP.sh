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
MARIADB_ROOT_PASSWORD=@@@mariadb_root_password@@@

if [ "$REMI_PHP_REPO_ID" = "@@@php_version@@@" ]; then
  REMI_PHP_REPO_ID="remi-php70"
fi
if [ "$MARIADB_ROOT_PASSWORD" = "@@@mariadb_root_password@@@" ]; then
  yum install -y expect || exit 1
  MARIADB_ROOT_PASSWORD=$(mkpasswd -l 32 -d 9 -c 9 -C 9 -s 0 -2)
fi

yum update -y

yum install -y firewalld || exit 1
systemctl start firewalld.service || exit 1
systemctl enable firewalld.service || exit 1

if [ ! -e /etc/yum.repos.d/epel.repo ]; then
  yum -y install epel-release || exit 1
fi

yum install -y --enablerepo=epel etckeeper tig bash-completion || exit 1

if [ ! -e /etc/.etckeeper ]; then
  etckeeper init || exit 1
  etckeeper commit "initial commit" || exit 1
fi

yum install -y httpd mod_ssl || exit 1

systemctl start httpd.service || exit 1
systemctl enable httpd.service || exit 1
firewall-cmd --add-service=http --zone=public --permanent || exit 1
firewall-cmd --add-service=https --zone=public --permanent || exit 1
firewall-cmd --reload || exit 1

if [ ! -e /etc/yum.repos.d/remi.repo ]; then
  rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi || exit 1
  yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm || exit 1
fi
yum install -y --enablerepo=epel,remi,${REMI_PHP_REPO_ID} php php-devel php-pear php-gd php-pdo php-intl php-mcrypt php-mbstring php-mysqlnd php-xml || exit 1

if [ ! -e /usr/local/bin/composer ]; then
  if [ -z "${HOME}" ]; then
    export COMPOSER_HOME=/root
  fi
  EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" || exit 1
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
      >&2 echo 'ERROR: Invalid installer signature'
      rm composer-setup.php || exit 1
  fi
  php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer || exit 1
  rm composer-setup.php || exit 1
fi

if [ ! -e /usr/local/bin/wp ]; then
  curl -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp || exit 1
  chmod +x /usr/local/bin/wp || exit 1
  if [ -e /etc/bash_completion.d -a ! -e /etc/bash_completion.d/wp-completion.bash ]; then
    curl -s https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash -o /etc/bash_completion.d/wp-completion.bash || exit 1
  fi
fi

yum install -y mariadb-server || exit 1
systemctl start mariadb.service || exit 1
systemctl enable mariadb.service || exit 1

if [ ! -e /root/.my.cnf ]; then
  # Remove anonymous users
  /usr/bin/mysql -u root -D mysql -e "DELETE FROM user WHERE User='';"
  # Disallow root login remotely
  /usr/bin/mysql -u root -D mysql -e "DELETE FROM user WHERE User='root' AND Host NOT IN ('localhost',  '127.0.0.1',  '::1');"
  # Remove test database
  /usr/bin/mysql -u root -e "DROP DATABASE test;"
  # Change MariaDB root password
  /usr/bin/mysqladmin -u root password "$MARIADB_ROOT_PASSWORD" || exit 1
fi

cat <<EOT > /root/.my.cnf
[client]
host     = localhost
user     = root
password = $MARIADB_ROOT_PASSWORD
socket   = /var/lib/mysql/mysql.sock
EOT
chmod 600 /root/.my.cnf

#!/bin/sh

# Update everything
yum update -y

yum install -y epel-release
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# MySQL setup (5.7)
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm

# Disable MySQL 8.0 and enable MySQL 5.7
sed -i -e ':a;N;$!ba;s/enabled=1/enabled=0/1'  /etc/yum.repos.d/mysql-community.repo
sed -i -e ':a;N;$!ba;s/enabled=0/enabled=1/3'  /etc/yum.repos.d/mysql-community.repo

yum install -y mysql-community-devel mysql-community-common mysql-community-server mysql-community-client

echo "
log_bin_trust_function_creators=1
sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,PIPES_AS_CONCAT'
" >> /etc/my.cnf

systemctl enable mysqld && systemctl start mysqld

# Change the temporary MySQL password
mysql_password=$(cat /var/log/mysqld.log | grep password | awk '{print $NF}')
new_password=tdPT3u.{:9#QmQ5
mysql -u root -p$mysql_password --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'tdPT3u.{:9#QmQ5';"
mysql -u root -p$new_password -e "UNINSTALL PLUGIN validate_password;"
mysql -u root -p$new_password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';"

echo "[client]
user=root
password=password
" > /root/.my.cnf

cp -p /root/.my.cnf /home/vagrant

mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'password';"
mysql -e "UPDATE mysql.user SET Password = PASSWORD('password') WHERE User = 'root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1', '%');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "CREATE DATABASE development;"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Install some generally required packages
curl --location https://rpm.nodesource.com/setup_8.x | bash -
yum -y  -q install yum-plugin-replace vim gcc libstdc++-devel gcc-c++ curl-devel nano git subversion unzip libxml2-devel pygpgme re2c ntp wget

# NTP setup
systemctl enable ntpd
systemctl start ntpd
ntpdate 0.uk.pool.ntp.org 1.uk.pool.ntp.org 2.uk.pool.ntp.org 3.uk.pool.ntp.org
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

# Install main project packages
yum -y install httpd openssl-devel redis
yum -y install php71w php71w-common php71w-bcmath php71w-cli php71w-devel php71w-gd php71w-gmp php71w-imap php71w-intl php71w-json php71w-mbstring php71w-mcrypt php71w-mysqlnd php71w-opcache php71w-process php71w-pdo php71w-xml php71w-pecl-xdebug php71w-pear php71w-pecl-igbinary

# Install required PECL packages
pecl channel-update pecl.php.net
yes | pecl install mailparse ds

# Composer (PHP Package Manager)
[ -f /usr/local/bin/php ] && ln -s /usr/local/bin/php /usr/bin/php
[ -f /usr/bin/php ] && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && ln -s /usr/local/bin/composer.phar /usr/local/composer

# Tweak PHP config
sed -i -e 's/^memory_limit\ =\ .*/memory_limit = 512M/' /etc/php.ini # any larger is impractical for dev
sed -i -e 's/^;date.timezone\ =\ .*/date.timezone = Europe\/London/' /etc/php.ini
sed -i -e 's/^upload_max_filesize\ =\ .*/upload_max_filesize = 32M/' /etc/php.ini
sed -i -e 's/^post_max_size\ =\ .*/post_max_size = 64M/' /etc/php.ini
sed -i -e 's/^;error_log\ =\ .*/error_log = \/opt\/logs\/console_errors/' /etc/php.ini
echo 'extension=mailparse.so' > /etc/php.d/zz-mailparse.ini
echo 'extension=ds.so' > /etc/php.d/zz-ds.ini

#Xdebug config to allow remote xdebug connections
echo "
[xdebug]
xdebug.remote_enable = 1
xdebug.remote_port = 9000
xdebug.remote_host = localhost
xdebug.remote_connect_back = 1
xdebug.idekey = PHPSTORM
xdebug.profiler_enable = 0
xdebug.profiler_enable_trigger = 1
xdebug.profiler_enable_trigger_value = VV_XDEBUG_TRIGGER
xdebug.var_display_max_depth = -1
xdebug.var_display_max_children = -1
xdebug.var_display_max_data = -1
" >> /etc/php.ini

# Set the Apache conf
ln -sfn /opt/config/apache/vagrant.conf /etc/httpd/conf.d/default.conf

# Edit the hosts file
echo "127.0.0.1 local.vvdev" | cat >> /etc/hosts

# Start apache service
systemctl enable httpd

# Switch on Redis
systemctl enable redis
systemctl start redis

# Tells Linux to allocate memory in a more optimistic fashion when Redis spawns child processes
[ -f /proc/sys/vm/overcommit_memory ] && echo 1 > /proc/sys/vm/overcommit_memory

# Just so it's easier to call PHPUnit I'll create an alias.
echo "
alias phpunit='/opt/vendor/bin/phpunit'
cd /opt
" >> /home/vagrant/.bash_profile

# Make the terminal display the branch name
echo "
git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1=\"[\u@\h \W]\[\033[01;32m\]\$(git_branch)\[\033[00m\]\$ \"
source ~/.bashrc
" >> /home/vagrant/.bashrc

# Good practice to remove all the vendor dir and force a fresh composer install
[ -d /opt/vendor ] && rm -rf /opt/vendor

# Fix annoying permission issue :)
setenforce 0

echo "Sudoers list permissions need resetting"
chown -R root:root /usr && chmod -R 755 /usr && chmod 4755 /usr/bin/sudo

# Start Apache
systemctl start httpd

echo "Finished - Connect by typing vagrant ssh"
#!/bin/bash
cd /tmp
mkdir install
cd install

#安装mysql
echo 'installMysql'
curl -O http://install.cornerstone365.cn/github/install/mysql-5.7.26-1.el7.x86_64.rpm-bundle.tar
curl -O http://install.cornerstone365.cn/github/install/my.cnf
curl -O http://install.cornerstone365.cn/github/db/db_cornerstone.sql
rpm -e mariadb-libs-* --nodeps
rpm -e maria*
rpm -e mysql*
yum -y install numactl
tar -xvf mysql-5.7.26-1.el7.x86_64.rpm-bundle.tar
rpm -ivh mysql-community-common-5.7.26-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.26-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.26-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.26-1.el7.x86_64.rpm
systemctl restart mysqld.service
sleep 5
defaultmysqlpwd=`grep 'A temporary password' /var/log/mysqld.log | awk -F"root@localhost: " '{ print $2}' `
echo $defaultmysqlpwd
/usr/bin/mysql -uroot -p"${defaultmysqlpwd}" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ITitiCS11112!@';
create database db_cornerstone;
use db_cornerstone;
source /tmp/install/db_cornerstone.sql;
EOF
sleep 2
#
cp -fv my.cnf /etc/my.cnf
systemctl enable mysqld
systemctl daemon-reload
systemctl restart mysqld
echo 'installMysql finished'
#
echo 'installcshome'
curl -O http://install.cornerstone365.cn/github/install/cshome.tar.gz
tar -xzvf cshome.tar.gz
rm -rf /cshome
mv cshome /
echo 'installcshome finished'
#
echo 'installCornerstoneSystem'
curl -O http://install.cornerstone365.cn/github/package/CornerstoneBizSystem.jaz
curl -O http://install.cornerstone365.cn/github/package/CornerstoneWebSystem.war
mv CornerstoneBizSystem.jaz /cshome/jazmin_server_jdk10/instance/CornerstoneBizSystem
mv CornerstoneWebSystem.war /cshome/jazmin_server_jdk10/instance/CornerstoneWebSystem
cd /cshome/jazmin_server_jdk10
./restartall.sh
echo 'CORNERSTONE INSTALL SUCCESS'
#restart jazmin after restart os
cp -f restartall.sh /etc/rc.d/init.d/restartcs.sh
cd /etc/rc.d/init.d
chmod +x  /etc/rc.d/init.d/restartcs.sh
chkconfig --add restartcs.sh
chkconfig restartcs.sh on
chmod +x /etc/rc.d/rc.local

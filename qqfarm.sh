#!/bin/bash
#
#autor:zeng
#date:
#usage:

#安装必要软件
id mysql &>/dev/null
if [ $? -ne 0 ];then
     if [ -f mysql-community.repo ];then
     cp mysql-community.repo /etc/yum.repos.d/mysql-community.repo
     yum -y install mysql-community-server php-mysql httpd php
     systemctl restart mysqld && systemctl enable mysqld
     else
     echo "该目录下没有 mysql-community.repo 文件！！" 
     exit
     fi
else
echo "mysql已安装！"
fi

#修改配置文件

mv /etc/httpd/conf/{httpd.conf,httpd.conf.bak}
mv /etc/{php.ini,php.ini.bak}
if [ -f httpd.conf ];then
cp httpd.conf /etc/httpd/conf/httpd.conf
cp php.ini /etc/php.ini
systemctl restart httpd
else
echo "该目录下没有 httpd.conf "
exit
fi

#项目包解压

rpm -qa | grep unzip
if [ $? -ne  0 ];then
yum -y install unzip
fi    
    if [ -f farm-ucenter1.5.zip ];then
    unzip farm-ucenter1.5.zip -d /var/www/html/
    else
    echo "缺少 farm-ucenter1.5.zip 已经退出！"
    exit
    fi
mv /var/www/html/upload/* /var/www/html/

#导入数据库

passwd=$(grep password /var/log/mysqld.log | awk -F" " 'NR==1{print $11}')

mysql -uroot -p"$passwd" --connect-expired-password  -e  "alter user root@localhost identified by '(Zeng..0421)';"  &>/dev/null

systemctl restart mysqld

mysql -uroot -p"(Zeng..0421)" -e " create database farm;grant all privileges  on farm.* to farm@localhost identified by '(Zeng..0421)';flush privileges;"  &>/dev/null

mysql -u"farm"  -p"(Zeng..0421)" -h"localhost" -D farm</var/www/html/qqfarm.sql &>/dev/null

#修改权限 

chmod -R 777 /var/www/html/{home,ucenter,bbs}

systemctl restart httpd

#打印数据库信息
echo "
数据库服务器：localhost
数据库：farm
用户名：farm
密码：  (Zeng..0421)
"














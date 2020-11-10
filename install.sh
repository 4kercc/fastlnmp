#!/bin/bash
#rm -rf $0
#by cvc in 2018
install_lnmp(){
echo -n "本LNMP脚本仅用于centos7 64位版 环境为nginx1.9开发版 mariaDB php7.1";echo;
echo -n "如果提示输入Y和N，请输入小写 y ";echo;
echo -n "请输入mysql的root密码:";echo;
read mysqlpasswd
echo "mysql密码设置为：$mysqlpasswd 确定请回车，否则请按ctrl+c退出。"
read check
clear
echo "请稍等，正在自动处理....."
sleep 1
yum install -y epel-release epel-release.noarch yum-utils wget 
rpm -Uvh https://github.com/4kercc/fastlnmp/raw/main/remi-release-7.rpm 
rpm -ivh http://nginx.org/packages/mainline/centos/7/x86_64/RPMS/nginx-1.19.0-1.el7.ngx.x86_64.rpm
wget -O /etc/yum.repos.d/MariaDB.repo https://github.com/4kercc/fastlnmp/raw/main/MariaDB.repo 
sed '0,/enabled/{ s/enabled=0/enabled=1/; }' /etc/yum.repos.d/remi-php70.repo > 1.log ;cat 1.log > /etc/yum.repos.d/remi-php70.repo ;rm 1.log -f 
yum update -y 
mkdir -p /var/www/html
#remi-release-7默认安装php7.0,下面这行设置安装php7.1
yum-config-manager --enable remi-php71 
yum install -y net-tools nginx  php-cli   php-common   php-devel  php-fpm  php-gd   php-imap  php-ldap   php-mbstring  php-mcrypt     php-mssql    php-mysqlnd  php-odbc  php-pdo    php-pear   php-pecl-jsonc    php-pecl-jsonc-devel   php-pecl-zip     php-process      php-snmp  php-soap   php-tidy     php-xml   php-xmlrpc  php-opcache  openssl openssl-devel MariaDB-server MariaDB-client
wget -O /etc/nginx/nginx.conf https://github.com/4kercc/fastlnmp/raw/main/nginx.conf
wget -O /etc/nginx/conf.d/default.conf https://github.com/4kercc/fastlnmp/raw/main/default.conf
wget -O /var/www/html/tz.php https://github.com/4kercc/fastlnmp/raw/main/tz.php
wget -O /var/www/html/adminer.php https://github.com/4kercc/fastlnmp/raw/main/adminer.php
wget -O /var/www/html/index.php https://github.com/4kercc/fastlnmp/raw/main/index.php
chown nginx:apache  /var/www/html
firewall-cmd  --permanent --add-service=http
firewall-cmd  --permanent --add-service=https
firewall-cmd  --reload
systemctl enable mariadb.service
systemctl restart mariadb.service
systemctl enable nginx.service
systemctl restart nginx.service
systemctl enable php-fpm.service
systemctl restart php-fpm.service
/usr/bin/mysqladmin -u root password $mysqlpasswd
echo -n "安装完成，请打开IP查看网站";echo;
echo -n "ip/tz.php为探针 ip/adminer.php为数据库管理工具";echo;
echo -n "安装结束~";echo;
exit 0;
}
uninstall_lnmp(){
    printf "Are you sure uninstall lnmp? (y/n)"
    printf "\n"
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"
    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
yum remove -y php-cli   php-common   php-devel  php-fpm  php-gd   php-imap  php-ldap   php-mbstring  php-mcrypt     php-mssql    php-mysqlnd  php-odbc  php-pdo    php-pear   php-pecl-jsonc    php-pecl-jsonc-devel php-pecl-zip  php-process php-snmp  php-soap   php-tidy  php-xml   php-xmlrpc  php-opcache MariaDB-server MariaDB-client
rpm -e nginx
rm -rf /var/www/html/
rm -rf /etc/nginx/
        echo "lnmp uninstall success!"
    else
        echo
        echo "uninstall cancelled, nothing to do..."
        echo
    fi
}

action=$1
if [ -z "$1" ]
then
install_lnmp
fi
case "$action" in
    install|uninstall)
        ${action}_lnmp
        ;;
    *)
        echo "Usage: `basename $0` [install|uninstall]"
        ;;
esac


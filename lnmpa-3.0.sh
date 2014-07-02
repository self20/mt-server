#! /bin/bash
# Build 20140607
# < LNMPA [Apache/Nginx|MYSQL/MariaDB|PHP] Installer >
#
# Copyright (C) <2014>  <MTimer> (http://www.mtimer.cn)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author：MTimer - Inspired by NewEraCracker Server For Windows
#
# Support CentOS/RHEL 32bit/64bit
# BY default, Nginx + MYSQL 5.6 + PHP 5.3 will be installed.
#
#┌────────────────────────────────────────────────
#┐	Structure
#│	/mtimer/		—— 		All important service location
#│		log/		—— 		Logs location
#│		git/		—— 		Optional
#│		server/		—— 		All service
#│		www/		—— 		Websites directory
#│	Need help? Email: mtimercms@hotmail.com  attach lnmpa_install.log
#│	Website: http://www.mtimer.cn
#│
#│	Github: https://github.com/MTimer/mt-server/tree/english
#└────────────────────────────────────────────────
#┘

MCONF="conf"
MCRON="cron"
MEXTRA="extra"
MINIT="init"
MINSTALL="install"

M_APACHE_2_2="2.2.27"
M_APACHE_2_4="2.4.9"
M_PHP_5_3="5.3.28"
M_PHP_5_4="5.4.29"
M_PHP_5_5="5.5.13"
M_MARIADB_5_3="5.3.12"
M_MARIADB_5_5="5.5.37"
M_MARIADB_10_0="10.0.11"
M_MYSQL_5_1="5.1.73"
M_MYSQL_5_5="5.5.38"
M_MYSQL_5_6="5.6.19"
M_NGINX="1.6.0"

# Only root
if [ $(id -u) != "0" ]; then
    clear && echo "Error: You must be root to run this script!"
    exit 1
fi

# Check Linux release
DISTRIBUTION=$(awk 'NR==1{print $1}' /etc/issue)
if echo $DISTRIBUTION | grep -Eqi '(Red Hat|CentOS|Fedora|Amazon)';then
    PACKAGE="rpm"
elif echo $DISTRIBUTION | grep -Eqi '(Debian|Ubuntu)';then
    PACKAGE="deb"
else
    if cat /proc/version | grep -Eqi '(redhat|centos|Red\ Hat)';then
        PACKAGE="rpm"
    elif cat /proc/version | grep -Eqi '(debian|ubuntu)';then
        PACKAGE="deb"
    fi
fi

if [ "$PACKAGE" != "rpm" ];then
    echo -e "\nNot supported linux distribution!"
	echo "Please contact me! MTimer <MTimerCMS@hotmail.com>"
	exit 1
fi

# If you are a developer, more packages will be installed
echo "Are u developer and need help ? "
echo -n "If [y]es, ROR/Git/Nodejs Dev env will be installed!!  [y/n] ?  "

read CUSTOMER
if [ "$CUSTOMER" = "y" ] || [ "$CUSTOMER" = "Y" ]; then
	CUSTOMER=yes
else
	CUSTOMER=no
fi

# Server location
echo -n "[C]hina or [W]orld wide ? "
read WHERE
if [ "$WHERE" = "c" ] || [ "$WHERE" = "C" ]; then
	WHERE=china
else
	WHERE=world
fi

# Apache or Nginx
echo -n "[A]pache or [N]ginx ? "
read WEBTYPE
if [ "$WEBTYPE" = "a" ] || [ "$WEBTYPE" = "A" ]; then
	WEBTYPE=httpd
	echo -n "Apache 2.[4] or 2.[2] ? "
	read APACHETODO
	if [ "$APACHETODO" = "4" ]; then
		apache_version=${M_APACHE_2_4}
	else
		APACHETODO=2
		apache_version=${M_APACHE_2_2}
	fi
else
	WEBTYPE=nginx
	nginx_version=${M_NGINX}
fi

# Choose PHP version
echo -n "PHP 5.[3], PHP 5.[4] or PHP 5.[5] ? "
read PHPTODO
if [ "$PHPTODO" = "5" ]; then
	php5_version=${M_PHP_5_5}
else
	if [ "$PHPTODO" = "4" ]; then
		php5_version=${M_PHP_5_4}
	else
		PHPTODO=3
		php5_version=${M_PHP_5_3}
	fi
fi

# MySQL or MariaDB
echo -n "[1]MySQL or [2]MariaDB ? "
read SQLTYPE
if [ "$SQLTYPE" = "2" ]; then
	SQLTYPE=mariadb
	echo -n "[1]MariaDB 5.3, [2]MariaDB 5.5 or [3]MariaDB 10.0 ? "
	read SQLTODO
	if [ "$SQLTODO" = "1" ]; then
		mariadb_version=${M_MARIADB_5_3}
	else
		if [ "$SQLTODO" = "2" ]; then
			mariadb_version=${M_MARIADB_5_5}
		else
			SQLTODO=3
			mariadb_version=${M_MARIADB_10_0}
		fi
	fi
else
	SQLTYPE=mysql
	echo -n "MySQL 5.[1], MySQL 5.[5] or MySQL 5.[6] ? "
	read SQLTODO
	if [ "$SQLTODO" = "1" ]; then
		mysql_version=${M_MYSQL_5_1}
	else
		if [ "$SQLTODO" = "5" ]; then
			mysql_version=${M_MYSQL_5_5}
		else
			SQLTODO=6
			mysql_version=${M_MYSQL_5_6}
		fi
	fi
fi

# Adminer phpMyAdmin
echo -n "[1]Adminer or [2]phpMyAdmin ? "
read MSQLTYPE
if [ "$MSQLTYPE" = "2" ]; then
	MSQLTYPE=phpmyadmin
else
	MSQLTYPE=adminer
fi

# Auto fdisk
echo -n "Auto fdisk [y/n] ? "
read AUTOFDISK
if [ "$AUTOFDISK" = "y" ] || [ "$AUTOFDISK" = "Y" ]; then
	AUTOFDISK=1
	fdisk -l|grep "Disk"|grep "/dev"|awk '{print $2}'|awk -F: '{print $1}'
	echo -n "Enter your disk name eg. sd [if sda,sdb...] , xv [if xva,xvb] : "
	read FDISKNAME
else
	AUTOFDISK=2
fi

# 32bit/64bit
if [ $(uname -m | grep -c 64) -gt 0 ]; then
	machine=x86_64
else
	machine=i386
fi

OS_VER=$(cat /etc/redhat-release | cut -d\  -f5)
if [ "$OS_VER" = "release" ]; then
	OS_VER=$(cat /etc/redhat-release | cut -d\  -f6)
elif [ "$OS_VER" = "ES" ]; then
	OS_VER=$(cat /etc/redhat-release | cut -d\  -f7)
elif [ "$OS_VER" = "WS" ]; then
	OS_VER=$(cat /etc/redhat-release | cut -d\  -f7)
elif [ "$OS_VER" = "AS" ]; then
	OS_VER=$(cat /etc/redhat-release | cut -d\  -f7)
elif [ "$OS_VER" = "Server" ]; then
	OS_VER=$(cat /etc/redhat-release | cut -d\  -f7)
elif [ "$(cat /etc/redhat-release 2>/dev/null| cut -d\  -f1)" = "CentOS" ]; then
	OS_VER=$(cat /etc/redhat-release |cut -d\  -f3);
	if [ "$OS_VER" = "release" ]; then
		OS_VER=$(cat /etc/redhat-release | cut -d\  -f4)
	fi
elif [ "$(cat /etc/redhat-release 2>/dev/null| cut -d\  -f3)" = "Enterprise" ]; then
	OS_VER=$(cat /etc/redhat-release 2>/dev/null| cut -d\  -f7)
elif [ "$(cat /etc/redhat-release 2>/dev/null| cut -d\  -f1)" = "CloudLinux" ]; then
	OS_VER=$(cat /etc/redhat-release 2>/dev/null| cut -d\  -f4)
fi
OS_VER=$(echo $OS_VER | awk '{print substr($1,1,1)}')

yum clean all

if [ "$OS_VER" = "6" ] && [ "WHERE" = "china" ]; then
	wget -c --tries=3 http://mirrors.ustc.edu.cn/epel/6/${machine}/epel-release-6-8.noarch.rpm
	wget -c --tries=3 http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	rpm -ivh epel-release-6-8.noarch.rpm
	rpm -ivh remi-release-6.rpm
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
	mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/centos?codeblock=2
elif [ "$OS_VER" = "5" ] && [ "WHERE" = "china" ]; then
	wget -c --tries=3 http://mirrors.ustc.edu.cn/epel/5/${machine}/epel-release-5-4.noarch.rpm
	wget -c --tries=3 http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
	rpm -ivh epel-release-5-4.noarch.rpm
	rpm -ivh remi-release-5.rpm
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
	mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/centos?codeblock=1
fi

# rpmforge
#if [ "$machine" = "i386" ]; then
#	machine=i686
#fi
#rpm -Uvh http://mirror.bjtu.edu.cn/repoforge/redhat/el6/en/${machine}/rpmforge/RPMS/rpmforge-release-0.5.2-2.el6.rf.${machine}.rpm
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
yum clean metadata
yum makecache

# Main packages
export CUSTOMER
export WHERE
export FDISKNAME
export WEBTYPE # Apache or Nginx
export APACHETODO # 2.2.X or 2.4.X
export PHPTODO # 3,4,5
export SQLTYPE # MySQL or MariaDB
export SQLTODO # 1 or 2/3/5/6
export MSQLTYPE # PhpMyAdmin or Adminer
export php5_version
export mysql_version
export mariadb_version
export apache_version
export nginx_version
export mtimer_version=2.0
export lnmpa_version=3.0


apache_dir=httpd-${apache_version}
nginx_dir=nginx-${nginx_version}
if [ "$WEBTYPE" = "nginx" ]; then
	webserver_dir=$nginx_dir
else
	webserver_dir=$apache_dir
fi
if [ "$SQLTYPE" = "mysql" ]; then
	sql_dir=mysql-${mysql_version}
else
	sql_dir=mariadb-${mariadb_version}
fi
php_dir=php-${php5_version}
mtimer_dir=mtimercms-${mtimer_version}
lnmpa_dir=lnmpa-${lnmpa_version}-en


export apache_dir
export nginx_dir
export sql_dir
export php_dir
export mtimer_dir
export lnmpa_dir
export machine


# Other packages
export autoconf_version=2.13
export libiconv_version=1.14
export libmcrypt_version=2.5.8
export mhash_version=0.9.9.9
export mcrypt_version=2.6.8
export zlibs_version=1.2.8
export openssl_version=1.0.1h
export freetype_version=2.5.3
export libpng_version=1.6.10
export libgd_version=2.1.0
export ImageMagick_version=6.8.9-2
export libevent_version=2.0.21-stable
export memcached_version=1.4.19
export pcre_version=8.35
export jpeg_version=9a
export curl_version=7.36.0
export Python_version=2.7.7
export asciidoc_version=8.6.9
export git_version=2.0.0
export node_version=v0.10.28
export redis_version=2.6.13
export cmake_version=2.8.12.2
export bison_version=2.6.4
export apr_version=1.5.1
export apr_util_version=1.5.3
export apr_iconv_version=1.2.1
export re2c_version=0.13.6
export libmemcached_version=1.0.18
export phpmemcache_version=3.0.8
export phpmemcached_version=2.2.0
export imagick_version=3.1.2
export scws_version=1.2.2
export adminer_version=4.1.0
export phpmyadmin_version=4.2.0

autoconf_dir=autoconf-${autoconf_version}
libiconv_dir=libiconv-${libiconv_version}
libmcrypt_dir=libmcrypt-${libmcrypt_version}
mhash_dir=mhash-${mhash_version}
mcrypt_dir=mcrypt-${mcrypt_version}
zlibs_dir=zlib-${zlibs_version}
openssl_dir=openssl-${openssl_version}
freetype_dir=freetype-${freetype_version}
libpng_dir=libpng-${libpng_version}
libgd_dir=libgd-${libgd_version}
ImageMagick_dir=ImageMagick-${ImageMagick_version}
libevent_dir=libevent-${libevent_version}
memcached_dir=memcached-${memcached_version}
pcre_dir=pcre-${pcre_version}
jpegsrc_dir=jpegsrc.v${jpeg_version}
curl_dir=curl-${curl_version}
asciidoc_dir=asciidoc-${asciidoc_version}
git_dir=git-${git_version}
Python_dir=Python-${Python_version}
node_dir=node-${node_version}
redis_dir=redis-${redis_version}
cmake_dir=cmake-${cmake_version}
bison_dir=bison-${bison_version}
apr_dir=apr-${apr_version}
apr_util_dir=apr-util-${apr_util_version}
apr_iconv_dir=apr-iconv-${apr_iconv_version}
re2c_dir=re2c-${re2c_version}
libmemcached_dir=libmemcached-${libmemcached_version}
phpmemcache_dir=memcache-${phpmemcache_version}
phpmemcached_dir=memcached-${phpmemcached_version}
imagick_dir=imagick-${imagick_version}
scws_dir=scws-${scws_version}
adminer_dir=adminer-${adminer_version}
phpmyadmin_dir=phpMyAdmin-${adminer_version}-all-languages

export autoconf_dir
export libiconv_dir
export libmcrypt_dir
export mhash_dir
export mcrypt_dir
export zlibs_dir
export openssl_dir
export freetype_dir
export libpng_dir
export libgd_dir
export ImageMagick_dir
export libevent_dir
export memcached_dir
export pcre_dir
export jpegsrc_dir
export curl_dir
export asciidoc_dir
export git_dir
export Python_dir
export node_dir
export redis_dir
export cmake_dir
export bison_dir
export apr_dir
export apr_util_dir
export apr_iconv_dir
export re2c_dir
export libmemcached_dir
export phpmemcache_dir
export phpmemcached_dir
export imagick_dir
export scws_dir
export adminer_dir
export phpmyadmin_dir


# Here we go
cat <<EOF
+-------------------------------------------------+
|     Following packages will be installed        
|       1) $webserver_dir                         
|       2) $sql_dir                               
|       3) $php_dir                               
|       4) $MSQLTYPE                              
|                                                 
|     Line: $WHERE      Developer: $CUSTOMER       
|                                                 
|     Notcie:                                 
|       1) This is how php works                  
|          php 5.3                                
|               mod_php(DSO) - with apache        
|               php-fpm      - with nginx         
|          php 5.4 - php-fpm                      
|          php 5.5 - php-fpm                      
|                                                 
|       2) Don't worry                            
|       You can change php version after install  
+-------------------------------------------------+

EOF
echo "Press Ctrl-C within the next 20 seconds to cancel the install";
sleep 20;
unalias cp

# For faster IO. **DO NOT** put important stuff under /tmp
a=$(date +%s)
mv /tmp /tmp-${a}
ln -s /dev/shm /tmp

# timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

yum install -y ntp
ntpdate -u pool.ntp.org
date
echo 'disable monitor' >> /etc/ntp.conf
service ntpd restart


# Check if MTimer CMS is installed
if [ -e /mtimer/www/${mtimer_dir} ]; then
	echo "";
	echo "";
	echo "*** ${mtimer_dir} exists on this system ***";
	echo "    Press Ctrl-C within the next 10 seconds to cancel the install";
	echo "    Else, wait, and the install will continue overtop (as best it can)";
	echo "";
	echo "";
	sleep 10;
fi



	# Preparation
	if [ -s /etc/selinux/config ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi
	setenforce 0
	cp /etc/yum.conf /etc/yum.conf.old
	sed -i 's/^exclude/#exclude/' /etc/yum.conf
	for packages in wget patch make gcc gcc-c++ flex bison file libtool libtool-libs autoconf kernel-devel patch unzip automake gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel libevent libevent-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libpng libpng-devel libjpeg libjpeg-devel openssl openssl-devel curl curl-devel e2fsprogs e2fsprogs-devel libidn libidn-devel vim-minimal nano gettext gettext-devel gmp-devel libcap perl perl-devel cpio expat-devel perl-ExtUtils-MakeMaker perl-CPAN tk bzip2-devel sqlite-devel xmlto;
	do yum -y install $packages; done
	mv -f /etc/yum.conf.old /etc/yum.conf


	#iflinode=$(cat /proc/version | grep -i debian) ########FOR LINODE########
	# Linode VPS fix
	#if [ "$iflinode" != "" ];then
	#./install_fix_linode_vps_iptables.sh
	#fi



	# Shutdown iptables
	#/etc/init.d/iptables stop
	#/etc/init.d/ip6tables stop
	#chkconfig iptables off
	#chkconfig ip6tables off


	if ! wget -c --tries=3 http://mtimercms.oss.aliyuncs.com/LNMPA-shell/${lnmpa_dir}.tar.gz ; then
		echo "[Error] Download Failed : ${lnmpa_dir}.tar.gz ,Please try again later."
		exit 1
	else
		mkdir $lnmpa_dir
		tar xvf ${lnmpa_dir}.tar.gz -C ./$lnmpa_dir ; cd $lnmpa_dir
	fi

	mkdir packages
	mkdir packages/unpacked
	export LNMPA_PATH=$(pwd)
	export MCONF_PATH="$LNMPA_PATH/$MCONF"
	export MCRON_PATH="$LNMPA_PATH/$MCRON"
	export MEXTRA_PATH="$LNMPA_PATH/$MEXTRA"
	export MINIT_PATH="$LNMPA_PATH/$MINIT"
	export MINSTALL_PATH="$LNMPA_PATH/$MINSTALL"
	export MPACKAGES_PATH="$LNMPA_PATH/packages"
	export MUNPACKED_PATH="$MPACKAGES_PATH/unpacked"

	cd ${MINSTALL_PATH}
	chmod +x ./install_*.sh

	# Go GO
	./install_set_sysctl.sh
	./install_set_ulimit.sh
	if [ "$AUTOFDISK" = "1" ] && [ "$FDISKNAME" != "" ]; then
		# Mount free disk
		./install_disk.sh
	fi
	# Install dir
	./install_dir.sh
	# Install necessary packages
	./install_env.sh
	# Install MYSQL/MariaDB
	./install_mysql.sh
	# Install Apache or Nginx
	./install_${WEBTYPE}.sh
	# Install PHP
	./install_php.sh
	# Install PHP extensions
	./install_php_extension.sh
	# Install VSFTPD
	./install_vsftpd.sh
	# Install MTM
	./install_soft.sh



	if [ "$machine" = "x86_64" ];then
		sed -i 's/^#exclude/exclude/' /etc/yum.conf
	fi

	sed -i "s#account.log#${MEXTRA_PATH}/account.log#g" ${MEXTRA_PATH}/init_mysql.php
	/mtimer/server/php/bin/php -f ${MEXTRA_PATH}/init_mysql.php

	# for faster ssh
	sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
	service sshd restart

	# Disable ipv6
	cat >>/etc/modprobe.d/ipv6.conf<<-EOF
	alias net-pf-10 off
	options ipv6 disable=1
	EOF

	echo "NETWORKING_IPV6=off" >> /etc/sysconfig/network

	modprobe ip_tables
	modprobe iptable_filter
	
	mkdir /mtimer/server/${WEBTYPE}/crons
	cp ${MCRON_PATH}/split_${WEBTYPE}_log.sh /mtimer/server/${WEBTYPE}/crons/split_${WEBTYPE}_log.sh
	# Cron jobs
	# crontab -e
	# If Apache
	# Add 00 00 * * * /bin/bash /mtimer/server/httpd/crons/split_httpd_log.sh
	# If Nginx
	# Add 00 00 * * * /bin/bash /mtimer/server/nginx/crons/split_nginx_log.sh

	echo '';
	echo '+-------------------- SSH Management --------------------------+';
	if [ "$WEBTYPE" = "httpd" ];then
		echo '  Apache: service httpd (start | stop | reload | restart)';
	else
		echo '  Nginx: service nginx (start | stop | reload | restart)';
	fi
	echo '  MYSQL: service mysql (start | stop | reload | restart)';
	if [ "$PHPTODO" = "3" ] && [ "$WEBTYPE" = "httpd" ];then
		echo '  PHP: service httpd (start | stop | reload | restart)';
	else
		echo '  PHP: service php-fpm (start | stop | reload | restart)';
	fi
	if [ "$CUSTOMER" = "yes" ];then
		echo '  Redis: service redis (start | stop | reload | restart)';
	fi
	echo '  Memcached: service memcached (start | stop | reload | restart)';
	echo '';
	echo '+--------------- Websites -------------+';
	echo '  WebSite root: /mtimer/www/example.com/';
	if [ "$CUSTOMER" = "yes" ];then
		echo "  MTime CMS: /mtimer/www/${mtimer_dir}/";
	fi
	if [ "$WEBTYPE" = "nginx" ];then
		echo '  Fancyindex: /mtimer/www/soft.example.com/';
	else
		echo '  Another website: /mtimer/www/soft.example.com/';
	fi
	if [ "$MSQLTYPE" = "phpmyadmin" ];then
		echo '  Phpmyadmin: /mtimer/www/phpmyadmin/';
	else
		echo '  Adminer: /mtimer/www/adminer/';
	fi
	echo '';
	echo '+---------- Installed servers  -----------+';
	if [ "$WEBTYPE" = "httpd" ];then
		echo '  Apache: /mtimer/server/httpd/';
	else
		echo '  Nginx: /mtimer/server/nginx/';
	fi
	echo '  Php: /mtimer/server/php/';
	if [ "$SQLTYPE" = "mysql" ];then
		echo '  Mysql: /mtimer/server/mysql/';
	else
		echo '  MariaDB: /mtimer/server/mysql/';
	fi
	if [ "$CUSTOMER" = "yes" ];then
		echo '  Node: /mtimer/server/node/';
	fi
	echo '';

	# It shows MYSQL,VSFTP accounts, or cat account.log
	echo "";
	cat <<-EOF
	+-------------------------------------------------+
	|          LNMPA installed successfully           |
	|          View account in account.log !          |
	+-------------------------------------------------+
	EOF

	# Print mysql,vsftp accounts
	cat ${MEXTRA_PATH}/account.log | while read line
	do
	echo "$line"
	done

	cp -f ${MEXTRA_PATH}/account.log ${LNMPA_PATH}/../account.log

	#cp /etc/profile /etc/profilebak
	#echo 'export PATH=$PATH:/mtimer/server/mysql/bin:/mtimer/server/nginx/sbin:/mtimer/server/php/sbin:/mtimer/server/php/bin' >> /etc/profile
	#source /etc/profile
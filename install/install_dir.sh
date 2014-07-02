#! /bin/bash
# Load functions
. ${LNMPA_PATH}/functions

mkdir /mtimer
mkdir /mtimer/server
mkdir /mtimer/www
if [ "$CUSTOMER" = "yes" ];then
	mkdir /mtimer/www/${mtimer_dir}
	cat >>/mtimer/www/${mtimer_dir}/phpinfo.php<<-EOF
	<?php
	phpinfo();
	?>
	EOF
fi

mkdir /mtimer/www/example.com
mkdir /mtimer/www/soft.example.com
cp -Rf ${LNMPA_PATH}/docs/* /mtimer/www/example.com

cat >>/mtimer/www/example.com/phpinfo.php<<EOF
<?php
phpinfo();
?>
EOF

# Add users www,mysql
groupadd www
useradd -s /sbin/nologin -M -g www -d /mtimer/www  www
groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql


#Downloadfile PHP-TZ/tz.zip
#cp tz.php /mtimer/www/${mtimer_dir}/

if [ "$MSQLTYPE" = "phpmyadmin" ]; then
	iptables -I INPUT -p tcp --dport 7772 -j ACCEPT
	Downloadfile phpMyAdmin/${phpmyadmin_dir}.zip
	mkdir /mtimer/www/phpmyadmin
	cp -Rf ${MUNPACKED_PATH}/${phpmyadmin_dir}/* /mtimer/www/phpmyadmin/
	sed -i "2 s/^/exit;/" /mtimer/www/phpmyadmin/version_check.php
	chown www:www -R /mtimer/www/phpmyadmin/
else
	iptables -I INPUT -p tcp --dport 7771 -j ACCEPT
	Downloadfile adminer/${adminer_dir}.zip
	mkdir /mtimer/www/adminer
	cp -f ${MUNPACKED_PATH}/${adminer_dir}/${adminer_dir}.php /mtimer/www/adminer/index.php
	chown www:www -R /mtimer/www/
fi
/etc/init.d/iptables save

chmod -R 775 /mtimer/www
chown -R www:www /mtimer/www
mkdir /mtimer/log
mkdir /mtimer/log/php
mkdir /mtimer/log/${SQLTYPE}
touch /mtimer/log/${SQLTYPE}/${SQLTYPE}_slow.log
chown mysql:mysql /mtimer/log/${SQLTYPE}/${SQLTYPE}_slow.log
mkdir /mtimer/log/${WEBTYPE}
chown -R www:www /mtimer/log

mkdir /mtimer/server/${sql_dir}
ln -vs /mtimer/server/${sql_dir} /mtimer/server/${SQLTYPE}

mkdir /mtimer/server/${php_dir}
ln -vs /mtimer/server/${php_dir} /mtimer/server/php


if [ "$WEBTYPE" = "httpd" ]; then
	mkdir /mtimer/server/${apache_dir}
	ln -vs /mtimer/server/${apache_dir} /mtimer/server/httpd
else
	mkdir /mtimer/server/${nginx_dir}
	ln -vs /mtimer/server/${nginx_dir} /mtimer/server/nginx
fi

cd ${MINSTALL_PATH}
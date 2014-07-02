#! /bin/sh
# Load functions
. ${LNMPA_PATH}/functions

# php ext memcache
Downloadfile php-extension/memcache/${phpmemcache_dir}.tgz
phpize
./configure --enable-memcache --with-php-config=/mtimer/server/php/bin/php-config
make
make install
if [ "$CUSTOMER" = "yes" ] ; then
	cp memcache.php /mtimer/www/${mtimer_dir}/
fi

gccv1=$(gcc -dumpversion | cut -f1 -d'.')
gccv2=$(gcc -dumpversion | cut -f2 -d'.')
if [ "$gccv1" = "4" ] && [ $gccv2 -gt 1 ]; then
	# php ext memcached
	Downloadfile php-extension/memcached/${phpmemcached_dir}.tgz
	phpize
	./configure --enable-memcached --with-php-config=/mtimer/server/php/bin/php-config --disable-memcached-sasl
	make
	make install
	cat >>/mtimer/server/php/etc/php.ini<<-EOF

	extension = "memcached.so" 
	EOF
fi


# PHP imagick http://pecl.php.net/package/imagick
Downloadfile php-extension/imagick/${imagick_dir}.tgz
ln -vs /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
phpize
./configure --with-imagick=/usr/local --with-php-config=/mtimer/server/php/bin/php-config
make
make install


# SCWS for MTimer CMS
Downloadfile php-extension/scws/${scws_dir}.tar.bz2
./configure --prefix=/usr/local/scws
make
make install
wget -c --tries=3 php-extension/scws/scws-dict-chs-utf8.tar.bz2
tar xvjf scws-dict-chs-utf8.tar.bz2
mv dict.utf8.xdb /usr/local/scws/etc/
chmod 777 /usr/local/scws/etc/dict.utf8.xdb
cd ${MUNPACKED_PATH}/${scws_dir}/phpext
phpize
./configure --with-php-config=/mtimer/server/php/bin/php-config --with-scws=/usr/local/scws
make
make install


case "$PHPTODO" in
	3)
		day=20090626
		;;
	4)
		day=20100525
		;;
	5)
		day=20121212
		;;
esac


#ZendGuardLoader
if [ "$PHPTODO" = "3" ] || [ "$PHPTODO" = "4" ]; then
Downloadfile php-extension/zend/ZendGuardLoader-php-5.${PHPTODO}-linux-glibc23-${machine}.tar.gz

mkdir -p /mtimer/server/php/lib/php/extensions/no-debug-non-zts-$day/Zend
cp ./php-5.${PHPTODO}.x/ZendGuardLoader.so /mtimer/server/php/lib/php/extensions/no-debug-non-zts-$day/Zend/

cat >>/mtimer/server/php/etc/php.ini<<EOF
zend_extension="/mtimer/server/php/lib/php/extensions/no-debug-non-zts-$day/Zend/ZendGuardLoader.so" 
EOF
fi


# php extensions
cp /mtimer/server/php/etc/php.ini /mtimer/server/php/etc/php.ini.old

sed -i "s#; extension_dir = \"./\"#extension_dir = \"/mtimer/server/php/lib/php/extensions/no-debug-non-zts-$day/\"\nextension = \"memcache.so\"\nextension = \"scws.so\"\nextension = \"imagick.so\"\nscws.default.charset = utf8\nscws.default.fpath = /usr/local/scws/etc\n#" /mtimer/server/php/etc/php.ini
sed -i 's/output_buffering = 4096/output_buffering = Off/g' /mtimer/server/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/g' /mtimer/server/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /mtimer/server/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /mtimer/server/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /mtimer/server/php/etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /mtimer/server/php/etc/php.ini
#sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /mtimer/server/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /mtimer/server/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /mtimer/server/php/etc/php.ini


if [ "$CUSTOMER" = "yes" ] ; then
	# phpredis Do not edit--
	Downloadfile php-extension/phpredis/phpredis-master.zip
	phpize
	./configure --with-php-config=/mtimer/server/php/bin/php-config
	make
	make install

	# phpRedisAdmin
	Downloadfile php-extension/phpRedisAdmin/phpRedisAdmin-master.zip
	git clone https://github.com/nrk/predis.git vendor
	cd ${MUNPACKED_PATH}
	mv phpRedisAdmin /mtimer/www/${mtimer_dir}/

	cat >> /mtimer/server/php/etc/php.ini <<-EOF

	extension = "redis.so"
	EOF
fi


service php-fpm restart
service ${WEBTYPE} start

cd ${MINSTALL_PATH}
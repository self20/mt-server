#! /bin/sh
# Load functions
. ${LNMPA_PATH}/functions
export PHP_AUTOCONF=/usr/local/${autoconf_dir}/bin/autoconf
export PHP_AUTOHEADER=/usr/local/${autoconf_dir}/bin/autoheader
Downloadfile php/${php_dir}.tar.gz
#svn co http://svn.php.net/repository/php/php-src/trunk/sapi/fpm sapi/fpm

ISMODPHP=0
case "$PHPTODO" in
	3) # 5.3.X
		if [ "$WEBTYPE" = "httpd" ]; then # mod_php(DSO)[Apache]
			./configure \
				--prefix=/mtimer/server/php \
				--with-config-file-path=/mtimer/server/php/etc \
				--with-config-file-scan-dir=/mtimer/server/php/etc/conf.d \
				--with-apxs2=/mtimer/server/httpd/bin/apxs \
				--with-freetype-dir=/usr/local/${freetype_dir} \
				--with-jpeg-dir=/usr/local/jpeg.6 \
				--with-pcre-regex=/usr/local \
				--with-pcre-dir=/usr/local \
				--with-libxml-dir=/usr \
				--with-png-dir \
				--with-mysql=mysqlnd \
				--with-mysqli=mysqlnd \
				--with-pdo-mysql=mysqlnd \
				--with-mysql-sock=/tmp/mysql.sock \
				--with-iconv=/usr/local/lib \
				--with-openssl=/usr/local/ssl \
				--with-zlib \
				--with-gd \
				--with-bz2 \
				--with-xmlrpc \
				--with-curl=/usr/local/curl \
				--with-mhash \
				--with-mcrypt \
				--with-gettext \
				--enable-xml \
				--enable-zend-multibyte \
				--enable-sockets \
				--enable-wddx \
				--enable-zip \
				--enable-calendar \
				--enable-bcmath \
				--enable-soap \
				--enable-mbstring \
				--enable-gd-native-ttf \
				--enable-pcntl \
				--enable-ftp \
				--enable-inline-optimization \
				--enable-sqlite-utf8 \
				--disable-ipv6 \
				--disable-debug \
				--disable-fileinfo
			ISMODPHP=1
		else # FastCGI[Nginx]
			#./buildconf --force
			./configure \
				--prefix=/mtimer/server/php \
				--with-config-file-path=/mtimer/server/php/etc \
				--with-config-file-scan-dir=/mtimer/server/php/etc/conf.d \
				--with-freetype-dir=/usr/local/${freetype_dir} \
				--with-jpeg-dir=/usr/local/jpeg.6 \
				--with-pcre-regex=/usr/local \
				--with-pcre-dir=/usr/local \
				--with-libxml-dir=/usr \
				--with-png-dir \
				--with-mysql=mysqlnd \
				--with-mysqli=mysqlnd \
				--with-pdo-mysql=mysqlnd \
				--with-mysql-sock=/tmp/mysql.sock \
				--with-iconv=/usr/local/lib \
				--with-openssl=/usr/local/ssl \
				--with-zlib \
				--with-gd \
				--with-bz2 \
				--with-xmlrpc \
				--with-curl=/usr/local/curl \
				--with-mhash \
				--with-mcrypt \
				--with-gettext \
				--enable-fpm \
				--enable-xml \
				--enable-zend-multibyte \
				--enable-sockets \
				--enable-wddx \
				--enable-zip \
				--enable-calendar \
				--enable-bcmath \
				--enable-soap \
				--enable-mbstring \
				--enable-gd-native-ttf \
				--enable-pcntl \
				--enable-ftp \
				--enable-inline-optimization \
				--enable-sqlite-utf8 \
				--disable-ipv6 \
				--disable-debug \
				--disable-fileinfo
		fi
		;;
	4|5) # 5.4.X, 5.5.X FastCGI
		./configure \
			--prefix=/mtimer/server/php \
			--with-config-file-path=/mtimer/server/php/etc \
			--with-config-file-scan-dir=/mtimer/server/php/etc/conf.d \
			--with-freetype-dir=/usr/local/${freetype_dir} \
			--with-jpeg-dir=/usr/local/jpeg.6 \
			--with-pcre-regex=/usr/local \
			--with-pcre-dir=/usr/local \
			--with-libxml-dir=/usr \
			--with-png-dir \
			--with-mysql=mysqlnd \
			--with-mysqli=mysqlnd \
			--with-pdo-mysql=mysqlnd \
			--with-mysql-sock=/tmp/mysql.sock \
			--with-iconv=/usr/local/lib \
			--with-openssl=/usr/local/ssl \
			--with-zlib \
			--with-gd \
			--with-bz2 \
			--with-xmlrpc \
			--with-curl=/usr/local/curl \
			--with-mhash \
			--with-mcrypt \
			--with-gettext \
			--enable-fpm \
			--enable-xml \
			--enable-sockets \
			--enable-wddx \
			--enable-zip \
			--enable-calendar \
			--enable-bcmath \
			--enable-soap \
			--enable-mbstring \
			--enable-gd-native-ttf \
			--enable-pcntl \
			--enable-ftp \
			--enable-inline-optimization \
			--disable-ipv6 \
			--disable-debug \
			--disable-fileinfo
		;;
esac

make #ZEND_EXTRA_LIBS='-liconv'
make install

cp -f php.ini-production /mtimer/server/php/etc/php.ini

ln -s /mtimer/server/php/bin/php /usr/bin/php
ln -s /mtimer/server/php/bin/phpize /usr/bin/phpize

if [ "$ISMODPHP" = "0" ]; then
	ln -s /mtimer/server/php/sbin/php-fpm /usr/bin/php-fpm
	cp -f /mtimer/server/php/etc/php-fpm.conf.default /mtimer/server/php/etc/php-fpm.conf

	sed -i "s@^;pid.*@pid = /tmp/php-fpm.pid@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^;error_log.*@error_log = /mtimer/log/php/php-fpm_error.log@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^;log_level.*@log_level = notice@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^user =.*@user = www@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^group =.*@group = www@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^;rlimit_files.*@rlimit_files = 51200@" /mtimer/server/php/etc/php-fpm.conf

	Mem=$(free -m | awk '/Mem:/{print $2}')
	sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/2/20))@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/2/30))@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/2/40))@" /mtimer/server/php/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/2/20))@" /mtimer/server/php/etc/php-fpm.conf

	cp -f ${MINIT_PATH}/php-fpm /etc/init.d/php-fpm
	chmod +x /etc/init.d/php-fpm
	chkconfig --level 2345 php-fpm on
	chmod 755 /mtimer/server/php/sbin/php-fpm
	service php-fpm start
fi
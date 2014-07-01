#! /bin/sh
#加载必需函数
. ${LNMPA_PATH}/functions
Downloadfile apache/${apache_dir}.tar.gz

case "$APACHETODO" in
	2)
	./configure \
		--prefix=/mtimer/server/httpd \
		--enable-mods-shared=most \
		--enable-ssl=shared \
		--enable-cache=shared \
		--enable-proxy=shared \
		--enable-proxy-connect=shared \
		--enable-proxy-ftp=shared \
		--enable-proxy-http=shared \
		--enable-proxy-scgi=shared \
		--enable-proxy-ajp=shared \
		--disable-ipv6 \
		--with-mpm=prefork \
		--with-pcre=/usr/local/bin/pcre-config
	;;
	4)
	./configure \
		--prefix=/mtimer/server/httpd \
		--with-apr=/usr/local/apr \
		--with-apr-util=/usr/local/apr-util \
		--enable-mods-shared=most \
		--enable-mpm-shared=all \
		--enable-ssl=shared \
		--disable-ipv6 \
		--with-mpm=event \
		--with-pcre=/usr/local/bin/pcre-config
	;;
esac

make
make install
#check=`grep -in "www\|httpd\|apache" /etc/passwd /etc/group`

cd ${LNMPA_PATH}
cp -R /mtimer/server/httpd/htdocs /mtimer/www/
chown -R www:www /mtimer/www
sed -i "s#server/httpd/htdocs#www/htdocs#" /mtimer/server/httpd/conf/httpd.conf
#if [ "$MSQLTYPE" = "phpmyadmin" ]; then
#	sed -i "s#Listen 80#Listen 80\nListen 7772#" /mtimer/server/httpd/conf/httpd.conf
#else
#	sed -i "s#Listen 80#Listen 80\nListen 7771#" /mtimer/server/httpd/conf/httpd.conf
#fi
sed -i 's/User daemon/User www/g' /mtimer/server/httpd/conf/httpd.conf
sed -i 's/Group daemon/Group www/g' /mtimer/server/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.htm index.php/g' /mtimer/server/httpd/conf/httpd.conf

cat >> /mtimer/server/httpd/conf/httpd.conf <<EOF

# Added BY MTimer
PidFile "/tmp/httpd.pid"

Include conf/vhosts/*.conf
EOF
mkdir /mtimer/server/httpd/conf/vhosts

if [ "$PHPTODO" != "3" ]; then
	PHPVARY="-php5.3"
else
	PHPVARY=""
fi
cp -f ${MCONF_PATH}/apache/vhosts-2.${APACHETODO}${PHPVARY}/example.com.conf /mtimer/server/httpd/conf/vhosts/
cp -f ${MCONF_PATH}/apache/vhosts-2.${APACHETODO}${PHPVARY}/soft.example.com.conf /mtimer/server/httpd/conf/vhosts/
cp -f ${MCONF_PATH}/apache/vhosts-2.${APACHETODO}${PHPVARY}/${MSQLTYPE}.conf /mtimer/server/httpd/conf/vhosts/

mkdir /mtimer/server/httpd/conf.d
rm -Rf /mtimer/log/httpd
ln -vs /mtimer/server/httpd/logs /mtimer/log/httpd
ln -vs /mtimer/server/httpd/include /usr/include/httpd


#cp -fR config-apache/* /mtimer/server/httpd/conf/
chkconfig --del httpd
rm -f /etc/init.d/httpd
cp ${MINIT_PATH}/httpd2.${APACHETODO} /etc/init.d/httpd
chmod +x /etc/init.d/httpd
chkconfig --level 2345 httpd on


# mod_fastcgi for Apache 2.2.X, 2.4.X 已经不需要了,但是装下也无妨
Downloadfile lib-web/fastcgi/mod_fastcgi-2.4.6.tar.gz
cp Makefile.AP2 Makefile
sed -i "s@^top_dir.*@top_dir      = /mtimer/server/httpd@" ./Makefile
sed -i "s@^APXS.*@APXS      = /mtimer/server/httpd/bin/apxs@" ./Makefile
sed -i "s@^APACHECTL.*@APACHECTL = /mtimer/server/httpd/bin/apachectl@" ./Makefile
if [ "$APACHETODO" = "4" ]; then
	patch -p1 < ${MEXTRA_PATH}/byte-compile-against-apache24.diff

	if [ "$PHPTODO" != "3" ]; then
		sed -i "s@^#LoadModule proxy_module.*@LoadModule proxy_module modules/mod_proxy.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule proxy_fcgi_module.*@LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule proxy_http_module.*@LoadModule proxy_http_module modules/mod_proxy_http.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule proxy_connect_module.*@LoadModule proxy_connect_module modules/mod_proxy_connect.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule proxy_balancer_module.*@LoadModule proxy_balancer_module modules/mod_proxy_balancer.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule proxy_ftp_module.*@LoadModule proxy_ftp_module modules/mod_proxy_ftp.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule cache_module.*@LoadModule cache_module modules/mod_cache.so@" /mtimer/server/httpd/conf/httpd.conf
		sed -i "s@^#LoadModule ssl_module.*@LoadModule ssl_module modules//mod_ssl.so@" /mtimer/server/httpd/conf/httpd.conf
	fi
	sed -i "s@^#LoadModule rewrite_module.*@LoadModule rewrite_module modules/mod_rewrite.so@" /mtimer/server/httpd/conf/httpd.conf
else 
	if [ "$PHPTODO" = "3" ]; then
		sed -i 's#<Directory "/mtimer/www/htdocs">#<Directory "/mtimer/www/htdocs">\n    AddType application/x-httpd-php .php\n    AddType application/x-httpd-php .php5\n    AddType application/x-httpd-php-source .phps\n    AddType application/x-httpd-php-source .php5s\n#' /mtimer/server/httpd/conf/httpd.conf
	fi
	sed -i "s@^#ServerName .*@ServerName 127.0.0.1:80@" /mtimer/server/httpd/conf/httpd.conf
fi
make
make install

# 当然你也可以用 mod_fcgid, PHPER 不用纠结，因为你使用的是 FPM
#rm -f /mtimer/server/httpd/conf.d/mod_fastcgi.conf
#Downloadfile lib-web/fcgid/mod_fcgid-2.3.9.tar.gz
#APXS=/mtimer/server/httpd/bin/apxs ./configure.apxs
#make
#make install


cd ${MINSTALL_PATH}

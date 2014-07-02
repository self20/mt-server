#! /bin/sh
# Load functions
. ${LNMPA_PATH}/functions

unzip ${MEXTRA_PATH}/ngx-fancyindex-0.2.5-fixed.zip -d ${MUNPACKED_PATH}

Downloadfile nginx/${nginx_dir}.tar.gz

./configure --user=www --group=www --prefix=/mtimer/server/nginx --error-log-path=/mtimer/log/nginx/error.log --pid-path=/tmp/nginx.pid --http-log-path=/mtimer/log/nginx/access.log --lock-path=/tmp/nginx.lock --with-http_stub_status_module --without-http-cache --with-http_ssl_module --with-http_addition_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_flv_module --http-client-body-temp-path=/tmp/nginx/client --http-proxy-temp-path=/tmp/nginx/proxy --http-fastcgi-temp-path=/tmp/nginx/fcgi --http-uwsgi-temp-path=/tmp/nginx/uwsgi --http-scgi-temp-path=/tmp/nginx/scgi --add-module=${MUNPACKED_PATH}/ngx-fancyindex-0.2.5-fixed
make
make install


cp -fR ${MCONF_PATH}/nginx/rewrite /mtimer/server/nginx/conf/
cp -f ${MCONF_PATH}/nginx/nginx.conf /mtimer/server/nginx/conf/
mkdir /mtimer/server/nginx/conf/vhosts
cp -f ${MCONF_PATH}/nginx/vhosts/example.com.conf /mtimer/server/nginx/conf/vhosts/
cp -f ${MCONF_PATH}/nginx/vhosts/soft.example.com.conf /mtimer/server/nginx/conf/vhosts/
cp -f ${MCONF_PATH}/nginx/vhosts/${MSQLTYPE}.conf /mtimer/server/nginx/conf/vhosts/
#if [ "$CUSTOMER" = "yes" ]; then
	#cp -f ${MCONF_PATH}/nginx/vhosts/mtimercms.conf /mtimer/server/nginx/conf/vhosts/
	#sed -i "s#www/mtimercms#www/${mtimer_dir}#g" /mtimer/server/nginx/conf/vhosts/mtimercms.conf
#fi


cp ${MEXTRA_PATH}/footer.html /mtimer/www/soft.example.com/

chmod 755 /mtimer/server/nginx/sbin/nginx
cp ${MINIT_PATH}/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx


mkdir -p /tmp/nginx/client
chkconfig --level 345 nginx on
service nginx start

cd ${MINSTALL_PATH}
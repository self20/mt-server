#! /bin/bash
#加载必需函数
. ${LNMPA_PATH}/functions

# 安装时光人系统
# Downloadfile program/${mtimer_dir}.zip
#if [ -e ${mtimer_dir}.zip ] && [ "$CUSTOMER" = "yes" ]; then
#	unzip ${mtimer_dir}.zip
#	mv -Rf ${mtimer_dir}/* /mtimer/www/${mtimer_dir}/
#	chown -R www:www /mtimer/www/${mtimer_dir}/

#	cd /mtimer/www/${mtimer_dir}/
#	chmod 777 backup/ xxx
#	chmod 755 xxx
#	chmod 666 xxx
#	chmod 444 xxx

#	cd -

	#这一部分是开机启动Nodechat聊天模块，一般用户不需要
#	if [ -d /mtimer/wwww/${mtimer_dir}/nodechat ]; then
#		cp nodechat /etc/init.d/
#		sed -i "s#www/mtimercms#www/${mtimer_dir}#g" /etc/init.d/nodechat
#		chmod +x /etc/init.d/nodechat
#		chkconfig nodechat on
#		service nodechat start
#	fi
#fi


# 启动 Memcached server
cp ${MINIT_PATH}/memcached /etc/init.d/
chmod +x /etc/init.d/memcached
mkdir -p /etc/memcached/pidfiles
chown nobody:nobody /etc/memcached/pidfiles
cp -f ${MCONF_PATH}/memcached/* /etc/memcached/
chkconfig memcached on
service memcached start
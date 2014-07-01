#! /bin/sh

# 有些VPS初始路径有误
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:~/bin
# 加载必需函数
. ${LNMPA_PATH}/functions

if [ ! $(grep -l '/lib'    '/etc/ld.so.conf') ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! $(grep -l '/usr/lib'    '/etc/ld.so.conf') ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ ! $(grep -l '/usr/local/lib'    '/etc/ld.so.conf') ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

rm -f /etc/ld.so.conf.d/mysql*.conf

ldconfig


# 开始安装一些包，不求最新，只求稳定
Downloadfile lib-web/autoconf/${autoconf_dir}.tar.gz
./configure --prefix=/usr/local/${autoconf_dir}
make
make install


Downloadfile lib-web/libiconv/${libiconv_dir}.tar.gz
./configure
make
make install


Downloadfile lib-web/libmcrypt/${libmcrypt_dir}.tar.gz
./configure --disable-posix-threads
make
make install
ldconfig
cd libltdl/
./configure --enable-ltdl-install
make
make install


Downloadfile lib-web/mhash/${mhash_dir}.tar.gz
./configure
make
make install


ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

ldconfig


Downloadfile lib-web/mcrypt/${mcrypt_dir}.tar.gz
./configure
make
make install


Downloadfile lib-web/zlib/${zlibs_dir}.tar.gz
./configure
make CFLAGS=-fpic
make install


Downloadfile lib-web/pcre/${pcre_dir}.tar.gz
./configure --enable-utf8 --enable-unicode-properties #--disable-shared
make
make install


# 因为之前yum安装了 zlib 等，所以这里费劲了
if [ "$machine" = "x86_64" ] ; then
	rm -f /lib64/libpcre.so*
	rm -f /lib64/libz.so*
	rm -f /usr/lib64/libz.so*
	ln -sf /usr/local/lib/libpcre.so.1.2.3 /lib64/libpcre.so.0
	ln -sf /usr/local/lib/libpcre.so.1.2.3 /lib64/libpcre.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib64/libz.so
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib64/libz.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /usr/lib64/libz.so
	ln -sf /usr/local/lib/libz.so.1.2.8 /usr/lib64/libz.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib64/libz.so.1
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
else
	rm -f /lib/libpcre.so*
	rm -f /lib/libz.so*
	rm -f /usr/lib64/libz.so*
	ln -sf /usr/local/lib/libpcre.so.1.2.3 /lib/libpcre.so.0
	ln -sf /usr/local/lib/libpcre.so.1.2.3 /lib/libpcre.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib/libz.so
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib/libz.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /usr/lib/libz.so
	ln -sf /usr/local/lib/libz.so.1.2.8 /usr/lib/libz.so.1
	ln -sf /usr/local/lib/libz.so.1.2.8 /lib/libz.so.1
fi
ldconfig


Downloadfile lib-web/openssl/${openssl_dir}.tar.gz
./config shared zlib
make
make install
mv /usr/bin/openssl /usr/bin/openssl.old
mv /usr/include/openssl /usr/include/openssl.old
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl.conf


# 因为估计你yum安装了 wget 等，所以这里费劲了
if [ "$machine" = "x86_64" ] ; then
	rm -f /usr/lib64/libssl.so*
	rm -f /usr/lib64/libcrypto.so*
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib64/libssl.so
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib64/libssl.so.10
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib64/libssl.so.1.0.0
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so.10
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so.1.0.0
else
	rm -f /usr/lib/libssl.so*
	rm -f /usr/lib/libcrypto.so*
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib/libssl.so
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib/libssl.so.10
	ln -sf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/lib/libssl.so.1.0.0
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10
	ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.1.0.0
fi
ldconfig


# http://libmng.com/pub/png/libpng.html
Downloadfile lib-web/libpng/${libpng_dir}.tar.gz
rm -f /usr/lib/libz.so
rm -f /usr/lib64/libz.so
rm -f /usr/local/lib/libz.so
rm -f /usr/local/lib64/libz.so
./configure
make CFLAGS=-fpic
make install


# http://download.savannah.gnu.org/releases/freetype/
Downloadfile lib-web/freetype/${freetype_dir}.tar.gz
./configure --prefix=/usr/local/${freetype_dir}
make
make install


Downloadfile lib-web/libevent/${libevent_dir}.tar.gz
./configure
make
make install


Downloadfile lib-web/memcached/${memcached_dir}.tar.gz
./configure
make
make install


# http://www.ijg.org/
Downloadfile lib-web/jpegsrc/${jpegsrc_dir}.tar.gz jpeg-${jpeg_version}
./configure --enable-static --enable-shared --prefix=/usr/local/jpeg-${jpeg_version}
make
make install


# http://libgd.bitbucket.org/
Downloadfile lib-web/libgd/${libgd_dir}.tar.gz
./configure --with-jpeg=/usr/local/jpeg-${jpeg_version}/ --with-png=/usr/local/ --with-zlib --with-freetype=/usr/local/${freetype_dir}/
make
make install


# http://www.imagemagick.org/download/
Downloadfile lib-web/ImageMagick/${ImageMagick_dir}.tar.gz
cp /usr/local/${freetype_dir}/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig
./configure CPPFLAGS="-I/usr/local/jpeg-${jpeg_version}/include -I/usr/local/${freetype_dir}/include -I/usr/local/${freetype_dir}/include/freetype2" LDFLAGS="-L/usr/local/${freetype_dir}/lib -L/usr/local/jpeg-${jpeg_version}/lib"
make
make install
ldconfig
#export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
ln -vs /usr/local/include/ImageMagick-6/wand /usr/local/include/wand
ln -vs /usr/local/include/ImageMagick-6/magick /usr/local/include/magick


Downloadfile lib-web/curl/${curl_dir}.tar.gz
./configure --prefix=/usr/local/curl --with-ssl=/usr/local/ssl --disable-ipv6
make
make install
cp -f /usr/local/curl/bin/* /usr/bin/


Downloadfile lib-web/python/${Python_dir}.tgz
./configure
make
make install


if [ "$CUSTOMER" = "yes" ] ; then

	#Downloadfile lib-web/asciidoc/${asciidoc_dir}.zip
	#./configure
	#make install

	# 下面是Git之类的，一般用户并不需要，当然使用Nodechat模块的用户必须安装
	Downloadfile lib-web/git/${git_dir}.tar.gz
	make configure
	./configure --prefix=/mtimer/git
	make all #doc
	make install


	Downloadfile lib-web/node/${node_dir}.tar.gz
	sed -i '1s/python/python2.7/1' ./configure  ##########CentOS 5#########
	./configure --prefix=/mtimer/server/node
	make
	make install


	# 开始安装Nodechat需要的
	echo 'export PATH=$PATH:/mtimer/git/bin' >> /etc/profile
	echo 'export PATH=$PATH:/mtimer/server/node/bin' >> /etc/profile
	source /etc/profile

	# 时光人系统 Nodechat聊天模块需要，一般用户不需要
	#npm install express -gd
	#npm install forever -gd
	#npm install forever-webui -g
	#npm install node-gyp -g
	#npm install socket.io -g
	#npm install hiredis redis -g
	#npm install mysql@2.0.0-alpha8 -g



	#Downloadfile lib-web/redis/${redis_dir}.tar.gz
	#make
	#make install
	#cd ${LNMPA_PATH}
	#cp -f redis.conf  /etc/
	#cp redis /etc/init.d/
	#chmod +x /etc/init.d/redis
	#chkconfig --add redis
	#chkconfig redis on
	#service redis start
fi



# 安装 MYSQL 或 MariaDB 高版本才需要
if [ "$SQLTODO" -gt "1" ]; then
	Downloadfile lib-web/cmake/${cmake_dir}.tar.gz
	./bootstrap
	make
	make install


	Downloadfile lib-web/bison/${bison_dir}.tar.gz
	./configure
	make
	make install
fi



# 安装 Apache 2.4.X 时需要
if [ "$APACHETODO" == "4" ]; then
	Downloadfile lib-web/apr/${apr_dir}.tar.gz
	sed -i 's/$RM "$cfgfile"/#$RM "$cfgfile"/g' ./configure
	./configure
	make
	make install

	Downloadfile lib-web/apr/${apr_util_dir}.tar.gz
	./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
	make
	make install

	Downloadfile lib-web/apr/${apr_iconv_dir}.tar.gz
	./configure --prefix=/mtimer/server/httpd --with-apr=/usr/local/apr
	make
	make install
fi


Downloadfile lib-web/re2c/${re2c_dir}.tar.gz
./configure
make
make install


# 如果 gcc 版本低于 4.2,则无法安装 libmemcached 以及后面的 php memcached 扩展
# 你可以按下面步骤自行安装 gcc >= 4.2 后补上, 但是很费时间，这里就免了
#Downloadfile lib-web/gcc/gcc-4.9.0.tar.bz2
#./contrib/download_prerequisites
#cd ..
#mkdir gcc-build-4.9.0
#cd  gcc-build-4.9.0
#../gcc-4.9.0/configure --prefix=/usr/local/gcc-4.9.0 --enable-checking=release --enable-languages=c,c++ --disable-multilib
#make -j4
#make install
#cat >> ~/.bashrc <<EOF
#GCCHOME=/usr/local/gcc-4.9.0
#PATH=$GCCHOME/bin:$PATH
#LD_LIBRARY_PATH=$GCCHOME/lib
#export GCCHOME PATH LD_LIBRARY_PATH
#EOF


gccv1=$(gcc -dumpversion | cut -f1 -d'.')
gccv2=$(gcc -dumpversion | cut -f2 -d'.')
if [ "$gccv1" = "4" ] && [ $gccv2 -gt 1 ]; then
	Downloadfile lib-web/libmemcached/${libmemcached_dir}.tar.gz
	./configure
	make
	make install
fi


# sqlit fix
cd ${MEXTRA_PATH}
gcc -o lemon lemon.c
mv lemon /usr/local/bin/

cd ${MINSTALL_PATH}
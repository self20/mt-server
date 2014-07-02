#! /bin/bash
yum -y install vsftpd
cp -f ${MCONF_PATH}/ftp/chroot_list /etc/vsftpd/
cp -f ${MCONF_PATH}/ftp/ftpusers /etc/vsftpd/
cp -f ${MCONF_PATH}/ftp/user_list /etc/vsftpd/


cp -f ${MCONF_PATH}/ftp/vsftpd-${machine}.conf /etc/vsftpd/vsftpd.conf

sed -i 's/# chkconfig: - 60 50/# chkconfig: 345 60 50/g' /etc/init.d/vsftpd
chkconfig vsftpd on
service vsftpd start
chown -R www:www /mtimer/www

MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
LENGTH="9"
while [ "${n:=1}" -le "$LENGTH" ]
do
	PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
	let n+=1
done
echo $PASS | passwd --stdin www
sed -i s/'ftp_password'/${PASS}/g ${MEXTRA_PATH}/account.log

cd ${MINSTALL_PATH}
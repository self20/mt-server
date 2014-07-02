#!/bin/bash
# Mtimer CMS Cut logs [Nginx]
# Author: http://www.mtimer.cn

# It should be yesterday, eg. 20120903
todaydate=`date --date='yesterday' "+%Y%m%d"`
# Log path
log_files_path="/mtimer/log/nginx/"
# Saved logs path，eg. /2013/12/
log_files_dir=${log_files_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
# Specify logs need to be cut, all logs by default.
log_files_name=()
# eg. log_files_name=(mtimercms soft)  separate by white space


# Save Days
save_days=7

############################################
# Edit below to suit your needs #
############################################
mkdir -p $log_files_dir

log_files_num=${#log_files_name[@]}

# Only when specify logs names
for((i=0;i<$log_files_num;i++));do
	mv ${log_files_path}${log_files_name[i]}.log ${log_files_dir}/${log_files_name[i]}_$todaydate.log
done


# Cut all logs
if [ $log_files_num = 0 ]; then
	for logs in `ls -l $log_files_path | grep -v "^d" | awk 'NF>2 {print $NF}'`;do
		mv ${log_files_path}$logs ${log_files_dir}/${logs%.*}_$todaydate.log
	done
fi

# Restart Nginx,PHP everyday。
if [ -s /tmp/nginx.pid ]; then
	service nginx restart
# Already in init scripts
# sleep 5
# phpfpm_pid=`cat /tmp/php-fpm.pid`
# echo -17 > /proc/$phpfpm_pid/oom_adj
fi

if [ ! -s /tmp/php-fpm.pid ]; then
	add_pid=$(ps aux | grep php-fpm | grep master | awk '{print $2}')

	if [ "$add_pid" != "" ];then
		echo "$add_pid" > /tmp/php-fpm.pid
	fi
fi
service php-fpm restart
# 因为启动脚本里已经有下面的功能了
# sleep 5
# phpfpm_pid=`cat /tmp/php-fpm.pid`
# echo -17 > /proc/$phpfpm_pid/oom_adj


# Delete logs XXX days before
find $log_files_path -mtime +$save_days -exec rm -rf {} \;

# Find Nginx pid，make it generate new logs
kill -USR1 `ps aux | grep nginx | grep master | awk '{print $2}'`

# Cron jobs
# cp split_nginx_log.sh /mtimer/server/nginx/crons/split_nginx_log.sh
# crontab -e
# Add 00 00 * * * /bin/bash /mtimer/server/nginx/crons/split_nginx_log.sh


# For WHMCS
# php -q /mtimer/www/whmcs/admin/cron.php
#!/bin/bash
# Mtimer CMS 时光人系统 日志切割脚本[Nginx]
# 作者: http://www.mtimer.cn

# 先把日期赋值到变量，因为是在第二天0点后执行，所以日期应该获取前一天的，如20120903
todaydate=`date --date='yesterday' "+%Y%m%d"`
# 设置日志路径，Nodechat聊天记录也保存于此{保存dump.rdb，因为/tmp目录下文件在服务器重启后消失},你无需修改
log_files_path="/mtimer/log/nginx/"
# 将日志存放于日期目录内，如/2013/12/
log_files_dir=${log_files_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
# 手动指定需要切割的日志名称，默认是日志路径下所有日志。如果需要手动指定，请在括号内填写日志名
log_files_name=()
# 比如log_files_name=(mtimercms soft)  用空格分隔


# 日志保留天数
save_days=7

############################################
# 你可以适当修改下面的脚本 #
############################################
mkdir -p $log_files_dir

log_files_num=${#log_files_name[@]}

# 切割日志脚本,在指定日志的情况下才执行
for((i=0;i<$log_files_num;i++));do
	mv ${log_files_path}${log_files_name[i]}.log ${log_files_dir}/${log_files_name[i]}_$todaydate.log
done


# 默认切割日志路径下所有日志，在指定日志的情况下不执行
if [ $log_files_num = 0 ]; then
	for logs in `ls -l $log_files_path | grep -v "^d" | awk 'NF>2 {print $NF}'`;do
		mv ${log_files_path}$logs ${log_files_dir}/${logs%.*}_$todaydate.log
	done
fi

# 重启Nginx,PHP,天天重启更健康,并禁止壮士断腕。
if [ -s /tmp/nginx.pid ]; then
	service nginx restart
# 因为启动脚本里已经有下面的功能了
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


# 删除XXX天前的日志和nodechat聊天记录
find $log_files_path -mtime +$save_days -exec rm -rf {} \;

# 找到nginx的master进程，向它发USR1指令，让它生成新的日志
kill -USR1 `ps aux | grep nginx | grep master | awk '{print $2}'`

# 如何将此脚本加入定时任务？执行以下命令
# cp split_nginx_log.sh /mtimer/server/nginx/crons/split_nginx_log.sh
# crontab -e
# 添加00 00 * * * /bin/bash /mtimer/server/nginx/crons/split_nginx_log.sh


# 安装有whmcs需要的，没有whmcs的忽略
# php -q /mtimer/www/whmcs/admin/cron.php
使用 MT Server 管理服务器 ![MT Server](http://mtimercms.u.qiniudn.com/rest/mt-server.jpg)
====================================================

### LNMPA 一键安装脚本

演示：[PHPINFO](http://42.159.195.136/phpinfo.php)

`Windows 下强烈建议使用便携的`[NewEraCracker For Windows](http://www.mtimer.cn/open/server-config/104-neweracracker-best-wamnp-nts-fix.html)！


----


## 导航

* **[多版本服务管理](#1-多版本服务管理)**
  * [默认](#2-默认)
  * [安装 MT Server](#3-安装-mt-server)
  * [选择安装](#4-选择安装)
  * [管理 MT Server](#5-管理-mt-server)
  * [安装目录](#6-安装目录)
* **[常见问题](#7-常见问题)**
* **[下一版本](#8-下一版本-mtenv)**
  * [更新历史](#9-更新历史)
  * [版权](#10-版权)


----


### 1. 多版本服务管理

> Apache 2.2, 2.4

> MySQL 5.1, 5.5, 5.6  / MariaDB 5.3, 5.5, 10.0

> PHP 5.3, 5.4, 5.5


### 2. 默认

- 几乎全编译，安装时间相当长。因为只有这样可以指定安装目录。也是为了下一版本 MTEnv 做准备。

- 安装时一路回车，将安装 Nginx + MYSQL 5.6 + PHP 5.3。

- PHP 5.3 + Apache 情形下，PHP 才以 mod_php 模式运行，其余情形均以 PHP-FPM 运行。

- pid, sock 均在 /tmp/下。

- /tmp/目录已经软连接/dev/shm/，所以重要的文件请勿存放在/tmp/下，因为文件会不定时消失。


### 3. 安装 MT Server

通过 `curl`
> curl -L -SsO git.io/tYfR5g | sh 2>&1|tee lnmpa_install.log

通过 `wget`
> wget --no-check-certificate git.io/tYfR5g | sh 2>&1|tee lnmpa_install.log

需以 root 身份执行上述命令


### 4. 选择安装

```
Are u developer and need help ? [1]Yes or [2]No
  你是开发者吗？ 如选是 将会按照 ROR/Git/Nodejs 环境，安装时间将会更长。默认 否

[1]China or [2]World wide ? 
  默认 国内线路

[1]Apache or [2]Nginx ? 
  默认 Nginx

  如果选择 Apache:
    Apache 2.[4] or 2.[2] ? 
    默认 Apache 2.2

PHP 5.[3], PHP 5.[4] or PHP 5.[5] ? 
  默认 PHP 5.3

  [1]MySQL or [2]MariaDB ? 
  默认 MySQL

  如果选择 MySQL:
    MySQL 5.[1], MySQL 5.[5] or MySQL 5.[6] ? 
    默认 MySQL 5.6

  如果选择 MariaDB:
    [1]MariaDB 5.3, [2]MariaDB 5.5 or [3]MariaDB 10.0 ? 
    默认 MariaDB 10.0

[1]Adminer or [2]Phpmyadmin ? 
  默认 Adminer

Auto fdisk [1]Yes or [2]No ? 
  需要自动挂载空白磁盘吗？  默认 否

  如果选择是： - 则将所有空白磁盘挂载到 /mtimer1 /mtimer2 以此类推
  Enter your disk name eg. sd [if sda,sdb...] , xv [if xva,xvb] : 
  输入空白磁盘名称，比如 sda,sdb 之类的输入 sd     xva,xvb 之类的输入 xv
```


### 5. 管理 MT Server

```
service httpd (start | stop | reload | restart)
service nginx (start | stop | reload | restart)
service mysql (start | stop | reload | restart)
service php-fpm (start | stop | reload | restart)
service memcached (start | stop | reload | restart) 
  	//或者指定 memcache 服务器 service memcached (start | stop | reload | restart) memcached_11211
memcached 的 pidfile 在 /etc/memcached/pidfiles/
```


### 6. 安装目录

```
/mtimer/                --    重要服务存放位置
    log/                --    存放各种日志  
      nginx/
      httpd/
      php/
      mysql/
      mariadb/
    git/                --    可选
    server/             --    各种服务程序
      nginx/
        conf/
          nginx.conf    --    nginx 主配置文件
          rewrite/      --    URL 重写规则文件目录
          vhosts/       --    子网站配置文件目录
        crons/          --    定时任务脚本目录
      httpd/
        conf/
          httpd.conf    --    apache 主配置文件
          vhosts/       --    子网站配置文件目录
        conf.d/         --    其他配置文件
        crons/          --    定时任务脚本目录
      php/
        etc/
          php-fpm.conf  --    PHP-FPM 配置文件
          php.ini       --    PHP 配置文件
      mysql/            ─┐
                          =>  配置文件在 /etc/my.cnf
      mariadb/          ─┘
    www/                --    网站目录，子网站存放在每个子目录
      example.com/      --    默认网站目录
      soft.example.com/ --    子网站目录
      phpmyadmin/       --    phpMyAdmin 目录，http://你的IP:7772/访问
      adminer/          --    Adminer 目录， http://你的IP:7771/访问
```


### 7. 常见问题

- 如何添加定时任务?


```
$ crontab -e
$ i

Apache 的：
  00 00 * * * /bin/bash /mtimer/server/httpd/crons/split_httpd_log.sh
Nginx 的:
  00 00 * * * /bin/bash /mtimer/server/nginx/crons/split_nginx_log.sh

$ :wq
```

- Apache + php 5.3 怎么重启PHP?

```
此种情形 PHP 以 mode_php 运行。
要重启 PHP 也就是重启 Apache。
命令：Service httpd restart
```

- FTP 连不上?

```
有时候你需要重启下服务器才能正常使用 FTP
```

- FTP 和 数据库初始密码？

```
在 account.log
```



----



### 8. 下一版本 MTEnv

> 类似 Python 管理工具 PYEnv, Ruby 管理工具 RBEnv。

> 不仅管理 LNMPA 版本，任意切换LNMPA版本以及某个版本的某个软件，而且自动配置 vim, pyenv, rbenv 等开发环境。

> 简化安装过程。更加自动化。

> 有好的建议请 Email。



### 9. 更新历史

```
--2014.05.10 更新脚本至 3.0，
  --LNMP 升级为 LNMPA, 命名为 MTimer Server
  --加入 MariaDB
  --完全重新组织结构
  --添加文档，大量重写

--2013.07.17 更新脚本至2.0，
  --很久了，无所谓了

  作者:MTimer
  邮箱:MTimercms@hotmail.com
```


### 10. 版权

```
Copyright (C) <2014>  <MTimer> (http://www.mtimer.cn)

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
```
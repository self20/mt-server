Simple Server Management ![MT Server](http://mtimercms.u.qiniudn.com/rest/mt-server.jpg)
====================================================

### MT Server - LNMPA

Demo: [PHPINFO](http://42.159.195.136/phpinfo.php)

`For windows try`[NewEraCracker For Windows](http://adminspot.net/topic/5258-neweracracker-server-for-windows/)！


----


## Table of Contents

* **[Installation](#1-installation)**
  * [Default](#2-default)
  * [Install MT Server](#3-install-mt-server)
  * [Choice](#4-choice)
  * [Manage MT Server](#5-manage-mt-server)
  * [Structure](#6-structure)
* **[FAQ](#7-faq)**
* **[Next release](#8-next-release-mtenv)**
  * [Version History](#9-version-history)
  * [License](#10-license)


----


### 1. Installation

> Apache 2.2, 2.4

> MySQL 5.1, 5.5, 5.6  / MariaDB 5.3, 5.5, 10.0

> PHP 5.3, 5.4, 5.5


### 2. Default

- It almost compiles everything which takes a while.

- It installs Nginx + MYSQL 5.6 + PHP 5.3 if you press `Enter` all the way down.

- Under PHP 5.3 + Apache circumstance, PHP run as mod_php. In other cases, PHP-FPM instead.

- pid, sock locate under /tmp/ .

- /tmp/ is linked to /dev/shm/, so *do not* put important stuff to /tmp/ .


### 3. Install MT Server

Via `curl`
> bash <(curl -sSL git.io/PxaSTw) 2>&1|tee lnmpa_install.log

Via `wget`
> bash <(wget --no-check-certificate git.io/PxaSTw) 2>&1|tee lnmpa_install.log


### 4. Choice

```
Are u developer and need help ? [1]Yes or [2]No
  Default no.

[1]China or [2]World wide ? 
  Default World wide.

[1]Apache or [2]Nginx ? 
  Default Nginx

  If choose Apache:
    Apache 2.[4] or 2.[2] ? 
    Default Apache 2.2

PHP 5.[3], PHP 5.[4] or PHP 5.[5] ? 
  Default PHP 5.3

  [1]MySQL or [2]MariaDB ? 
  Default MySQL

  If choose MySQL:
    MySQL 5.[1], MySQL 5.[5] or MySQL 5.[6] ? 
    Default MySQL 5.6

  If choose MariaDB:
    [1]MariaDB 5.3, [2]MariaDB 5.5 or [3]MariaDB 10.0 ? 
    Default MariaDB 10.0

[1]Adminer or [2]Phpmyadmin ? 
  Default Adminer

Auto fdisk [1]Yes or [2]No ? 
  Default no

  If choose Yes: - it will mount free disk to /mtimer1 /mtimer2 etc..
  Enter your disk name eg. sd [if sda,sdb...] , xv [if xva,xvb] : 
  If sda,sdb input sd     xva,xvb input xv
```


### 5. Manage MT Server

```
service httpd (start | stop | reload | restart)
service nginx (start | stop | reload | restart)
service mysql (start | stop | reload | restart)
service php-fpm (start | stop | reload | restart)
service memcached (start | stop | reload | restart) 
    //Or specify memcache server: service memcached (start | stop | reload | restart) memcached_11211
memcached's pidfiles location: /etc/memcached/pidfiles/
```


### 6. Structure

```
/mtimer/                --    All important service location
    log/                --    Logs location  
      nginx/
      httpd/
      php/
      mysql/
      mariadb/
    git/                --    Optional
    server/             --    All service
      nginx/
        conf/
          nginx.conf    --    nginx main configuration file
          rewrite/      --    URL rewrite rule files location
          vhosts/       --    virtual hosts configuration files location
        crons/          --    cron jobs shell location
      httpd/
        conf/
          httpd.conf    --    apache main configuration file
          vhosts/       --    virtual hosts configuration files location
        conf.d/         --    other configuration files location
        crons/          --    cron jobs shell location
      php/
        etc/
          php-fpm.conf  --    PHP-FPM configuration file
          php.ini       --    PHP configuration file
      mysql/            ─┐
                          =>  /etc/my.cnf
      mariadb/          ─┘
    www/                --    Websites directory
      example.com/      --    Default website directory
      soft.example.com/ --    Sample vhosts website
      phpmyadmin/       --    phpMyAdmin, http://Your IP:7772/
      adminer/          --    Adminer, http://Your IP:7771/
```


### 7. FAQ

- Cron jobs?


```
$ crontab -e
$ i

Apache:
  00 00 * * * /bin/bash /mtimer/server/httpd/crons/split_httpd_log.sh
Nginx:
  00 00 * * * /bin/bash /mtimer/server/nginx/crons/split_nginx_log.sh

$ :wq
```

- Apache + php 5.3 : restart PHP?

```
In this circumstance, PHP run as mode_php.
To restart PHP just restart Apache.
Run: Service httpd restart
```

- FTP no connection?

```
Sometimes you need to restart your server to use FTP
```

- FTP and MySQL passwords?

```
Check account.log
```



----



### 8. Next Release MTEnv

> Similar to Python management PYEnv, Ruby management RBEnv.

> Not only manage LNMPA versions, it can choose between LNMPA versions, soft versions, it also help you deploy vim, pyenv, rbenv.

> Simplify installation. Much easier.

> Suggestions goes to Email.



### 9. Version History

```
--2014.05.10 Update to 3.0,
  --LNMP upgrade to LNMPA, name as MT Server
  --Inculde MariaDB
  --Complete rewrite
  --Add docs

--2013.07.17 Update to 2.0,
  --none

  Author:MTimer
  Email:MTimercms@hotmail.com
```


### 10. License

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
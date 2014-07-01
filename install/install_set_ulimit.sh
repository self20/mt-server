#!/bin/sh
cp /etc/security/limits.conf /etc/security/limits.conf.old
cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF

#! /bin/bash
cp /etc/init.d/iptables /etc/init.d/iptables.backup
patch -p1 < ${MEXTRA_PATH}/14857.txt \/etc/init.d/iptables

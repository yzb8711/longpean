#!/bin/bash
yum  -y  install  gcc   pcre-devel  autoconf

                                              #下载端口监控脚本
mv discover_port  /tmp/          #移动脚本
                                               #下载zabbix源码包
tar  -xf  zabbix-3.4.4.tar.gz       #解压zabbix源码包
cd  zabbix-3.4.4/	               #进入编译目录
./configure  --enable-agent     #配置zabbix
make  install		#安装zabbix
#------修改agent配置文件------
sed -i '93c Server=127.0.0.1,172.31.48.131' /usr/local/etc/zabbix_agentd.conf
sed -i '134c ServerActive=172.31.48.131:10051' /usr/local/etc/zabbix_agentd.conf
sed -i '280c UnsafeUserParameters=1' /usr/local/etc/zabbix_agentd.conf
sed -i '245c AllowRoot=1' /usr/local/etc/zabbix_agentd.conf
#--------进入自定义key目录，并创建监控key文件
cd  /usr/local/etc/zabbix_agentd.conf.d/
echo UserParameter=tcpportlisten,/bin/bash /tmp/discover_port.sh "$1" > tcp_port.key
#---------添加zabbix用户并启动---------
useradd zabbix
zabbix_agentd
#----------设置zabbix服务开机自启-----
echo zabbix_agentd  >> /etc/rc.local
chmod +x  /etc/rc.local

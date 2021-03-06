#!/bin/bash
yum  -y  install  gcc   pcre-devel  autoconf

                                              #下载端口监控脚本
mv discover_port.sh  /tmp/          #移动脚本
                                               #下载zabbix源码包
tar  -xf  zabbix-3.4.4.tar.gz       #解压zabbix源码包
cd  zabbix-3.4.4/	               #进入编译目录
./configure  --enable-agent     #配置zabbix
make  install		#安装zabbix
#------修改agent配置文件------
sed -i '93c Server=127.0.0.1,ec2-44-242-54-71.us-west-2.compute.amazonaws.com ' /usr/local/etc/zabbix_agentd.conf
sed -i '134c ServerActive=ec2-44-242-54-71.us-west-2.compute.amazonaws.com:10051' /usr/local/etc/zabbix_agentd.conf
sed -i '280c UnsafeUserParameters=1' /usr/local/etc/zabbix_agentd.conf
sed -i '245c AllowRoot=1' /usr/local/etc/zabbix_agentd.conf
sed -i '264s/#//' /usr/local/etc/zabbix_agentd.conf
#--------进入自定义key目录，并创建监控key文件
cd  /usr/local/etc/zabbix_agentd.conf.d/
echo UserParameter=tcpportlisten,/bin/bash /tmp/discover_port.sh "$1" > tcp_port.key
#---------添加zabbix用户并启动---------
useradd zabbix
zabbix_agentd
#----------设置zabbix服务开机自启-----
echo zabbix_agentd  >> /etc/rc.local
chmod +x  /etc/rc.local
iptables -A OUTPUT -p tcp --sport 10050 -j ACCEPT
iptables -A INPUT -p tcp --dport 10051 -j ACCEPT
iptables-save > /etc/sysconfig/iptables
iptables -n -L --line-numbers
ss -ntulp | grep :10050 
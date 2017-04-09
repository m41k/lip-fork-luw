#!/bin/bash

#--------------------------------------------------------------------------------#
#		                 FORK LUW				 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#


mkdir /var/www/html/vps
cd /var/www/html/vps/
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/var/www/html/vps/index.html
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/var/www/html/vps/linux.png

cd /usr/lib/cgi-bin/
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/usr/lib/cgi-bin/vps-ini.sh
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/usr/lib/cgi-bin/vps-tuser.sh
chmod +x vps*

mkdir /opt/vps
cd /opt/vps
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/opt/vps/vps.sh

mkdir /opt/vps/tools
cd /opt/vps/tools
wget https://raw.githubusercontent.com/m41k/vps-fork-luw/master/opt/vps/tools/vps-iptables.sh
chmod +x vps-iptables.sh

mkdir /opt/vps/homesh
mkdir /opt/vps/log
touch /opt/vps/log/acesso
chmod 646 /opt/vps/log/acesso

echo www-data ALL=NOPASSWD:/usr/lib/cgi-bin/vps-tuser.sh >> /etc/sudoers
echo ALL     ALL=NOPASSWD:/opt/vps/tools/vps-iptables.sh >> /etc/sudoers

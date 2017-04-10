#!/bin/bash

#--------------------------------------------------------------------------------#
#		               LIP FORK LUW			              	 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#


mkdir /var/www/html/lip
cd /var/www/html/lip/
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/var/www/html/lip/index.html
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/var/www/html/lip/linux.png

cd /usr/lib/cgi-bin/
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/usr/lib/cgi-bin/lip-ini.sh
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/usr/lib/cgi-bin/lip-tuser.sh
chmod +x lip*

mkdir /opt/lip
cd /opt/lip
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/opt/lip/lip.sh

mkdir /opt/lip/tools
cd /opt/lip/tools
wget https://raw.githubusercontent.com/m41k/lip-fork-luw/master/opt/lip/tools/lip-iptables.sh
chmod +x lip-iptables.sh

mkdir /opt/lip/homesh
mkdir /opt/lip/log
touch /opt/lip/log/acesso
chmod 646 /opt/lip/log/acesso

echo www-data ALL=NOPASSWD:/usr/lib/cgi-bin/lip-tuser.sh >> /etc/sudoers
echo ALL ALL=NOPASSWD:/opt/lip/tools/lip-iptables.sh >> /etc/sudoers

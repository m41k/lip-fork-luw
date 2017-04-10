#!/bin/bash
#echo -e "Content-type: text/html\n\n"
#--------------------------------------------------------------------------------#
#   LUW-TUSER - Create and configure unprivileged temp user to LXC/LUW 		 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------#
#    			Criando usuario local 					 #
#--------------------------------------------------------------------------------#
server=$1
nuser=u$RANDOM
tpass=P45s$RANDOM
#echo "<h2>User: "$nuser" Pass: "$tpass"</h2>"
echo "<h2>You have an hour.</h2>"
useradd -m $nuser -p `openssl passwd -1 $tpass`
#--------------------------------------------------------------------------------#
#      			Log - add usuario criado 					 #
#--------------------------------------------------------------------------------#
logacesso=/opt/lip/log/acesso
echo $nuser >> $logacesso
#--------------------------------------------------------------------------------#
#		      Configurando usuario para utilizar o LXC	                 #
#--------------------------------------------------------------------------------#

mkdir -p /home/$nuser/.config/lxc
chown $nuser:$nuser /home/$nuser/.config/lxc
ini=`grep $nuser /etc/subuid | cut -d : -f2`
fim=`grep $nuser /etc/subuid | cut -d : -f3`
echo lxc.include = /etc/lxc/default.conf > /home/$nuser/.config/lxc/default.conf
echo lxc.id_map = u 0 $ini $fim >> /home/$nuser/.config/lxc/default.conf
echo lxc.id_map = g 0 $ini $fim >> /home/$nuser/.config/lxc/default.conf
chown $nuser:$nuser /home/$nuser/.config/lxc/default.conf


echo $nuser veth lxcbr0 10 >> /etc/lxc/lxc-usernet

#passwd $nuser

#--------------------------------------------------------------------------------#
#       		Configurando ambiente LUW para usuario	                 #
#--------------------------------------------------------------------------------#

mkdir /home/$nuser/public_html
chown $nuser:$nuser /home/$nuser/public_html
mkdir /home/$nuser/public_html/cgi-bin
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin
mkdir /home/$nuser/public_html/cgi-bin/luw-box
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin/luw-box
cp /opt/lip/lip.sh /home/$nuser/public_html/cgi-bin/
chmod +x /home/$nuser/public_html/cgi-bin/lip.sh
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin/lpi.sh

#--------------------------------------------------------------------------------#
#                       Configurando Secutiry Shell 		                 #
#--------------------------------------------------------------------------------#
su $nuser -c "ssh-keygen -t rsa -f /home/$nuser/.ssh/id_rsa -N '' > /dev/null; cat /home/$nuser/.ssh/id_rsa.pub >> /home/$nuser/.ssh/authorized_keys"


#--------------------------------------------------------------------------------#
#            Criando script para deletar usuario e agendando tarefa 	 		                 #
#--------------------------------------------------------------------------------#
#sed -e "/$nuser veth lxcbr0 10/d" /etc/lxc/lxc-usernet > /etc/lxc/lxc-usernet

homesh=/opt/lip/homesh/$nuser.sh

echo '#!/bin/bash' > $homesh
echo 'nid=`id -u '$nuser'`' >> $homesh
echo 'procs=`ps -u $nid | cut -c 1-6 | paste -s | tr -d "PID" | expand -i | tr -s " "`' >> $homesh
echo 'userdel -rf  '$nuser' 2> /dev/null' >> $homesh
echo 'kill -9 $procs 2> /dev/null' >> $homesh
#echo 'sed -e "/'$nuser 'veth lxcbr0 10/d" /etc/lxc/lxc-usernet > /etc/lxc/lxc-usernet' >> $homesh
echo 'rm -rf /opt/lip/homesh/'$nuser.sh >> $homesh
chmod +x $homesh
at -f $homesh now +25 minutes

#rodared='<meta http-equiv="refresh" content="0;url=http://'$nuser':'$tpass'@luw.servehttp.com/~'$nuser'/cgi-bin/lip.sh">'
#rodared='<meta http-equiv="refresh" content="0;url=http://'$nuser':'$tpass'@8.43.87.71/~'$nuser'/cgi-bin/lip.sh">'
rodared='<meta http-equiv="refresh" content="0;url=http://'$nuser':'$tpass'@'$server'/~'$nuser'/cgi-bin/lip.sh">'
echo $rodared

#echo <meta http-equiv="refresh" content="0;url=http://$nuser:$tpass@'$SERVER_NAME'/~$nuser/">

echo "<br>"
#echo "<h1>Enter</h1>"
echo "<h1>Behave yourself</h1>"

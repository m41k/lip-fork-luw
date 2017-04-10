#!/bin/zsh
#--------------------------------------------------------------------------------#
#		            LIP FOR LUW						 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#

eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html\n\n"


#--------------------------------------------------------------------------------#
#			     VARIAVEIS INICIAIS					 #
#--------------------------------------------------------------------------------#
#-->Hostname
#hostname=`hostname`
hostname="localhost"
#-->Secutiry Shell comand
ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $REMOTE_USER@$hostname"
#-->Corte para pegar nome do arquivo
luw=`echo $0 | rev | cut -d / -f1 | rev`

#--------------------------------------------------------------------------------#
#			     FORMULARIO INICIAL					 #
#--------------------------------------------------------------------------------#
#------->Baixa pagina de imagens LXC e cria lista das Distros usada no FORM 
	ipage=~/.imgpage.html
	ilist=~/.imglist.lxc
	wget -q http://images.linuxcontainers.org/ -O $ipage
	lynx -dump -width 120 $ipage > $ilist
#	cini=`cat -n $ilist | grep "Distribution Release Architecture" | awk {'print $1'}`
#	cfin=`cat -n $ilist | grep "_________________________________" | awk {'print $1'}`
#	de=`expr $cfin - $cini - 1`
#	ate=`expr $cfin - 1`
#	distro=( `tac $ilist | head -n $ate | tail -n $de | awk {'print $1"_"$2"_"$3'} | grep 'ubuntu\|debian\|centos' | grep 'i386\|amd64'` )
	distro=( `tac $ilist | grep 'centos\|debian\|ubuntu' | grep 'i386\|amd64' | awk {'print $1"_"$2"_"$3'}` )
	rm -rf $ipage
	rm -rf $ilist
#------->Form para criacao de container
	echo "<form method='post' action='$luw'>"
	echo "<h2>First Server</h2>"
	echo "Hostname:"
	echo " <input type='text' name='ncont' maxlength='50' size='30'>"

	echo "Memory:"
        echo "<select name='mem'>"
	echo "<option value='256M'>256 MB</option>"
	echo "<option value='512M'>512 MB</option>"
	echo "<option value='1G'>1 GB</option>"
        echo  "</select>"

	echo "Distro:"
	echo "<select name='dcont'>"
	 for (( d=1; d<=${#distro[@]}; d++ ))
          do
           echo "<option value=$distro[$d]>$distro[$d]"
         done
	echo  "</select>"

	echo  "SSH:<input type='checkbox' name='ssh' value='enable'>"
	echo  "<input type='submit' value='Criar'>"
	echo  "</form>"

#--------------------------------------------------------------------------------#
#			BOTAO CRIAR CONTAINER - EXECUCAO			 #
#--------------------------------------------------------------------------------#
if [ $FORM_ncont != "" ]; then
 if  echo $FORM_ncont | grep '[^[:alnum:]]' > /dev/null; then
  echo "<font color=red size=2><b>Invalid name. Use alphanumeric characters only.</b></font>"
 else
	contname=$FORM_ncont
	distro=`echo $FORM_dcont | awk -F_ {'print $1'}`
	release=`echo $FORM_dcont | awk -F_ {'print $2'}`
	arquit=`echo $FORM_dcont | awk -F_ {'print $3'}`
	echo "<pre>"
	eval $ssh lxc-create -t download -n $contname -- -d $distro -r $release -a $arquit &> /dev/null
	echo "</pre>"

#------->Configurando memoria do container
	echo 'lxc.cgroup.memory.limit_in_bytes = '$FORM_mem >> ~/.local/share/lxc/$FORM_ncont/config

#------>CheckBox SSH Habilitado
  if [ $FORM_ssh = "enable" ]; then

#------>Start container
	eval $ssh lxc-start -n $FORM_ncont
	#sleep 5

#------>Loop check RUNNING container
	for i in $(seq 1 100)
   	 do
     	  state=`lxc-info -s -n $FORM_ncont | tr -d " " | cut -d ":" -f2`
     	   if [ $state = RUNNING ]; then
            break
     	   fi
     	  sleep 3
	 done

#------>Criar usuarios
	user=lip
	pass=lip
        eval $ssh lxc-attach -n $FORM_ncont -- useradd -m $user -s /bin/bash
        eval $ssh lxc-attach -n $FORM_ncont -- usermod -p $(openssl passwd $pass) $user
        #sleep 3

#------>Install SSH Server Debian/Ubuntu
#        eval $ssh lxc-start -n $FORM_ncont
#        sleep 5
#        eval $ssh lxc-attach -n $FORM_ncont -- apt-get install -y openssh-server &> /dev/null
#------>Gerando porta randomica
        port=$((RANDOM%49152+16383))
        echo "<b>SSH:</b><br>"
        echo $SERVER_NAME':'$port
#       echo "Ativado"
#------>Pegando ip container
	echo "<br>"
#	ipc=`lxc-ls -f | grep $FORM_ncont |tr -d ' ' | cut -d '-' -f2`
#	ipc=`lxc-info -i -n $FORM_ncont |tr -d ' ' | cut -d ':' -f2`
#LOOP IP
        for i in $(seq 1 100)
         do
 	  ipc=`lxc-info -i -n $FORM_ncont |tr -d ' ' | cut -d ':' -f2`
           if [ "$ipc" != "" ]; then
            break
           fi
          sleep 3
         done
	echo $ipc

#------>Abrir porta
open="sudo /opt/lip/tools/lip-iptables.sh $port $ipc 22"
echo "<br>"
echo $open
eval $open

#------>Verifica Debian/Ubuntu ou CentOS

   if echo "$distro" | egrep 'centos' > /dev/null; then
   #------>Install SSH Server CentOS
	 echo "CentOS"
#	 eval $ssh lxc-attach -n $FORM_ncont -- bash -c 'yum install -y openssh-server; /sbin/service sshd start && /sbin/service sshd status'
        eval $ssh lxc-attach -n $FORM_ncont -- yum install openssh-server -y &> /dev/null
        eval $ssh lxc-attach -n $FORM_ncont -- systemctl start sshd.service &> /dev/null
        eval $ssh lxc-attach -n $FORM_ncont -- /sbin/service sshd start &> /dev/null
        eval $ssh lxc-attach -n $FORM_ncont -- /etc/init.d/sshd start &> /dev/null
    else
   #------>Install SSH Server Debian/Ubuntu
        eval $ssh lxc-attach -n $FORM_ncont -- apt-get install -y openssh-server &> /dev/null
        eval $ssh lxc-attach -n $FORM_ncont -- /etc/init.d/ssh restart &> /dev/null
   fi

  fi


#------->Log criacao de container
        logcreate=/opt/luw/log/creation
        echo $REMOTE_USER $contname $distro $release $arquit >> $logcreate
#------->Fim Log
 fi
fi 2> /dev/null

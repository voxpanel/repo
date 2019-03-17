#!/bin/bash -e
clear
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
NC=`tput sgr0`
echo "${GREEN}"
echo "===================================================="
echo "Instalação do ShoutCast"
echo "Poderá demorar vários minutos. Por favor, aguarde!"
echo "===================================================="
echo "${NC}"
echo "${YELLOW}Deseja prosseguir? (y/n)${NC}"
read -e run
if [ "$run" == n ] ; then
   exit
else
#instalando
iptables -I INPUT -p tcp -s 0/0 --dport 20 -j ACCEPT
iptables -I INPUT -p tcp -s 0/0 --dport 21 -j ACCEPT
yum install iptables wget nano vixie-cron mailx sendmail nmap perl rsync rdate gcc nano openssh-server openssh-clients kernel-devel postgresql-libs fuse-curlftpfs unrar gcc glibc.i686 glibc-devel.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686 postgresql-libs openssl-devel glibc-devel unzip -y
ln -s /usr/bin/nano /usr/bin/pico
iptables -F
perl -i -p -e 's/#Port 22/Port 6985/' /etc/ssh/sshd_config
grep 'Port 6' /etc/ssh/sshd_config
service sshd restart
perl -i -p -e 's/en_US.UTF-8/en_US/' /etc/sysconfig/i18n
cat /etc/sysconfig/i18n
iptables -F
service iptables save
chkconfig iptables on
chkconfig crond on
adduser streaming
usermod -u 500 streaming
groupmod -g 500 streaming
cd /home
mkdir streaming
cd ~
chmod 0777 /home/streaming
yum install epel-release -y
yum upgrade ca-certificates --disablerepo=epel -y
yum update -y
yum install glibc.i686 libstdc++.i686 -y
perl -i -p -e 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
echo 0 > /selinux/enforce
echo "modprobe ip_conntrack" >> /etc/sysconfig/modules/iptables.modules
chmod +x /etc/sysconfig/modules/iptables.modules
####################################################################################################
#Conteudo do servidor de streaming(shoutcast, php, configs)
####################################################################################################
cd /home/streaming/
wget http://srvstm.com/_configs-stm_/streaming.tar.gz
tar -zxvf streaming.tar.gz
####################################################################################################
#Ajustes do servidor e configurações
####################################################################################################
yum update -y
unalias cp
unalias mv
cd /home/streaming/
yum install vnstat pure-ftpd httpd php php-xml php-mysql python34 fuse-curlftpfs unrar -y
yum install -y libstdc++ --skip-broken --setopt=protected_multilib=false
yum install -y libstdc++-4.4.6-4.el6.i686 --skip-broken --setopt=protected_multilib=false
yum install -y libgcc_s.so.1 --skip-broken --setopt=protected_multilib=false
yum install -y glibc.i686 --skip-broken --setopt=protected_multilib=false
yum -y install libstdc++.so.6
rm -rfv /etc/pure-ftpd/pure-ftpd.conf; mv -v pure-ftpd.conf /etc/pure-ftpd/pure-ftpd.conf
rm -rfv /etc/pure-ftpd/pureftpd-mysql.conf; mv -v pureftpd-mysql.conf /etc/pure-ftpd/pureftpd-mysql.conf
echo >> /root/.bash_profile
echo 'export LANG=en_US' >> /root/.bash_profile
echo 'cd /home/streaming' >> /root/.bash_profile
rm -rfv /var/spool/cron/root
mv -v cron.streaming.txt /var/spool/cron/root 
echo '* * * * * chmod 0777 /home/streaming/*' >> /var/spool/cron/root
service crond restart
cp -fv httpd.conf /etc/httpd/conf/httpd.conf
cp -fv php.ini /etc/php.ini
rm -rfv httpd.conf php.ini 
chown -Rfv streaming.streaming /home/streaming/
yum install rdate -y
rm -Rf /etc/localtime
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
rdate -s rdate.cpanel.net
vnstat --showconfig > /etc/vnstat.conf
sed -i '/eth0/d' /etc/vnstat.conf
echo  >> /etc/vnstat.conf
echo "Interface \"`ifconfig | awk {'print $1'} | head -1`\"" >> /etc/vnstat.conf
vnstat -u -i `ifconfig | awk {'print $1'} | head -1` --force
perl -i -p -e 's/max_execution_time = 30/max_execution_time = 1800/' php.ini
perl -i -p -e 's/max_input_time = 60/max_execution_time = 1800/' php.ini
cd ~
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
######################################################################
#Modulos para manipulação arquivos MP3
######################################################################
curl -L -O https://ufpr.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --enable-shared --enable-nasm
make
make install
make distclean
echo '/usr/local/lib' >> /etc/ld.so.conf
echo '/usr/lib' >> /etc/ld.so.conf
wget http://www.ffmpeg.org/releases/ffmpeg-4.0.tar.gz
tar -zxvf ffmpeg-4.0.tar.gz
cd ffmpeg-4.0
./configure --disable-yasm --enable-libmp3lame --enable-pic --enable-gpl --enable-shared --enable-decoder=aac --enable-filter=aformat --enable-filter=volume --enable-filter=aresample && make && make install
ldconfig
######################################################################
#Configuração do FTP para conexão com banco de dados do painel
######################################################################
nano /etc/pure-ftpd/pureftpd-mysql.conf
######################################################################
#Finalização
######################################################################
rm -rfv streaming.tar.gz
chkconfig pure-ftpd on
chkconfig httpd on
/etc/init.d/httpd restart
/etc/init.d/pure-ftpd restart
/etc/init.d/rsyslog restart
echo 'streaming:cia@radio#cdr' | chpasswd
sed -i '/MinUID/d' /etc/pure-ftpd/pure-ftpd.conf
sed -i '/MYSQLDefaultUID/d' /etc/pure-ftpd/pureftpd-mysql.conf
sed -i '/MYSQLDefaultGID/d' /etc/pure-ftpd/pureftpd-mysql.conf
user_stm_id=`id -u streaming`
echo "MinUID $user_stm_id" >> /etc/pure-ftpd/pure-ftpd.conf
echo "MYSQLDefaultUID $user_stm_id" >> /etc/pure-ftpd/pureftpd-mysql.conf
echo "MYSQLDefaultGID $user_stm_id" >> /etc/pure-ftpd/pureftpd-mysql.conf
/etc/init.d/pure-ftpd restart
#concluir
clear
echo "${GREEN}"
echo "================================================================="
echo 
echo "Concluído. :)"
echo
echo "A porta SSH foi alterada de 22 para 6985."
echo
echo "Acesse o painel e crie o servidor e configure as demais."
echo
echo "================================================================="
echo "${NC}"
fi

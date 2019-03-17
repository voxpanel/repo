#!/bin/bash -e
clear
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
NC=`tput sgr0`
echo "${GREEN}"
echo "===================================================="
echo "Instalação do Painel"
echo "Poderá demorar vários minutos. Por favor, aguarde!"
echo "===================================================="
echo "${NC}"
echo "${YELLOW}Dominio (sem http/https ou www): ex. meusite.com ou painel.meusite.com ${NC}"
read -e dominio
echo "${YELLOW}Senha MySQL:${NC}"
read -e senhamysql
echo "${YELLOW}Deseja prosseguir? (y/n)${NC}"
read -e run
if [ "$run" == n ] ; then
   exit
else
#instalando
yum install iptables wget nano vixie-cron mailx sendmail nmap perl rsync rdate gcc nano openssh-server openssh-clients fuse-curlftpfs gcc glibc.i686 glibc-devel.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686 postgresql-libs openssl-devel glibc-devel -y
ln -s /usr/bin/nano /usr/bin/pico
replace 'NETWORKING_IPV6=yes' 'NETWORKING_IPV6=no' -- /etc/sysconfig/network
service ip6tables stop
chkconfig ip6tables off
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
yum install epel-release -y
yum upgrade ca-certificates --disablerepo=epel -y
yum install nano iptables vixie-cron nmap perl-libs -y;
perl -i -p -e 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
echo 0 > /selinux/enforce
echo >> /root/.bash_profile
echo 'export LANG=en_US' >> /root/.bash_profile
yum update -y
yum install vnstat pure-ftpd -y
chkconfig pure-ftpd on
yum install rdate -y
rm -Rf /etc/localtime
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
rdate -s rdate.cpanel.net
iptables -I INPUT -p tcp -s 0/0 --dport 20 -j ACCEPT
iptables -I INPUT -p tcp -s 0/0 --dport 21 -j ACCEPT
yum install httpd httpd-devel mysql mysql-server mysql-devel php-common php-mbstring php-php-gettext php-bcmath php-xml php-gd php-tcpdf-dejavu-sans-fonts phpMyAdmin php-devel php-ldap php-cli php-mysql php-process php-mcrypt php-tcpdf php-odbc php-zts php-snmp php-pear php-xmlrpc php-dba php-pdo php php-tidy php-intl php-imap php-embedded php-soap -y
chkconfig httpd on
chkconfig mysqld on
adduser painel
echo 'painel:k4kh34rhk3r34rssf' | chpasswd
mkdir /home/painel/public_html
mkdir /home/player/public_html
chmod 0755 /home/painel
chmod 0755 /home/painel/public_html
chmod 0755 /home/player
chmod 0755 /home/player/public_html
replace '#NameVirtualHost *:80' 'NameVirtualHost *:80' -- /etc/httpd/conf/httpd.conf
replace 'AddDefaultCharset UTF-8' 'AddDefaultCharset ISO-8859-1' -- /etc/httpd/conf/httpd.conf
replace '/var/www/html' '/home/painel/public_html' -- /etc/httpd/conf/httpd.conf
replace 'Options FollowSymLinks' 'Options ExecCGI FollowSymLinks Includes IncludesNOEXEC Indexes -MultiViews SymLinksIfOwnerMatch' -- /etc/httpd/conf/httpd.conf
replace 'AllowOverride None' 'AllowOverride All' -- /etc/httpd/conf/httpd.conf
replace ';default_charset=iso-8859-1' 'default_charset=iso-8859-1l' -- /etc/php.ini
echo '<Directory "/home/player/public_html/">' >> /etc/httpd/conf/httpd.conf
echo ' Options Indexes FollowSymLinks' >> /etc/httpd/conf/httpd.conf
echo ' AllowOverride All' >> /etc/httpd/conf/httpd.conf
echo ' Order allow,deny' >> /etc/httpd/conf/httpd.conf
echo ' Allow from all' >> /etc/httpd/conf/httpd.conf
echo '</Directory>' >> /etc/httpd/conf/httpd.conf
echo '<VirtualHost *:80>' >> /etc/httpd/conf/httpd.conf
echo ' ServerName DOMINIO-VOXRADIO' >> /etc/httpd/conf/httpd.conf
echo ' DocumentRoot /home/painel/public_html/' >> /etc/httpd/conf/httpd.conf
echo ' ServerAlias DOMINIO-VOXRADIO' >> /etc/httpd/conf/httpd.conf
echo ' ErrorLog /home/painel/public_html/error_log' >> /etc/httpd/conf/httpd.conf
echo ' CustomLog /home/painel/public_html/requests_log combined' >> /etc/httpd/conf/httpd.conf
echo '</VirtualHost>' >> /etc/httpd/conf/httpd.conf
echo '<VirtualHost *:80>' >> /etc/httpd/conf/httpd.conf
echo ' ServerName player.DOMINIO-VOXRADIO' >> /etc/httpd/conf/httpd.conf
echo ' DocumentRoot /home/player/public_html/' >> /etc/httpd/conf/httpd.conf
echo ' ServerAlias player.DOMINIO-VOXRADIO' >> /etc/httpd/conf/httpd.conf
echo ' ErrorLog /home/player/public_html/error_log' >> /etc/httpd/conf/httpd.conf
echo ' CustomLog /home/player/public_html/requests_log combined' >> /etc/httpd/conf/httpd.conf
echo '</VirtualHost>' >> /etc/httpd/conf/httpd.conf
replace 'DOMINIO-VOXRADIO' $dominio -- /etc/httpd/conf/httpd.conf
cd /usr/src
wget https://www.libssh2.org/download/libssh2-1.8.0.tar.gz
tar -zxvf libssh2-1.8.0.tar.gz
cd libssh2-1*
./configure && make && make install
pecl install ssh2-0.12
echo 'extension=ssh2.so' >> /etc/php.ini
php -m | grep ssh
yum install geoip geoip-devel -y
pecl install geoip 
echo 'extension=geoip.so' >> /etc/php.ini
unalias cp
wget http://srvstm.com/GeoIP.tar.gz
tar -zxvf GeoIP.tar.gz
cp -Rfv GeoIP/ /usr/local/share/
cp -Rfv GeoIP/ /usr/share/
php -m | grep geoip
######################################################################
###### Instalação JAVA #######
######################################################################
yum install java* -y
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export ANT_HOME=/opt/ant' >> /etc/profile
######################################################################
###### Instalação SDK ANDROID #######
######################################################################
cd /opt/
wget http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
tar -xzf android-sdk_r23.0.2-linux.tgz
echo "export PATH=$PATH:/opt/android-sdk-linux/platforms" >> ~/.profile
echo "export PATH=$PATH:/opt/android-sdk-linux/tools" >> ~/.profile
export PATH=$PATH:/opt/android-sdk-linux/platforms
export PATH=$PATH:/opt/android-sdk-linux/tools
./android-sdk-linux/tools/android update sdk --no-ui 
######################################################################
###### Instalação ANT #######
######################################################################
cd /opt
wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz
tar -zxvf apache-ant-1.9.4-bin.tar.gz
ln -s /opt/apache-ant-1.9.4 /opt/ant
ln -s /opt/ant/bin/ant /usr/bin/ant
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
export PATH=$JAVA_HOME/bin:$PATH
replace 'dirname' '/usr/bin/dirname' -- /opt/ant/bin/ant
######################################################################
###### CRON #######
######################################################################
echo '0 */12 * * * /usr/bin/rdate -s rdate.cpanel.net' >> /var/spool/cron/root
echo '0 5 * * * /bin/rm -rfv /var/log/httpd/*-*' >> /var/spool/cron/root
echo '0 5 * * * /bin/rm -rfv /var/log/*-20*' >> /var/spool/cron/root
echo '0 5 * * * /bin/rm -rfv /var/spool/clientmqueue/*' >> /var/spool/cron/root
echo '0 */1 * * * /bin/echo -n > /var/spool/mail/root' >> /var/spool/cron/root
echo '0 */1 * * * /bin/echo -n > /home/painel/public_html/access_log' >> /var/spool/cron/root
echo '0 */1 * * * /bin/echo -n > /home/player/public_html/access_log' >> /var/spool/cron/root
echo '0 */1 * * * /bin/echo -n > /home/painel/public_html/error_log' >> /var/spool/cron/root
echo '0 */1 * * * /bin/echo -n > /home/player/public_html/error_log' >> /var/spool/cron/root
echo '0 3 * * 0 /usr/bin/yum clean all' >> /var/spool/cron/root
echo '0 2 * * * /usr/bin/php -q /home/painel/public_html/robots/limpar-logs.php' >> /var/spool/cron/root
echo '0 3 * * 0 /usr/bin/php -q /home/painel/public_html/robots/limpar-estatisticas.php' >> /var/spool/cron/root
echo '*/30 * * * * /bin/nice -20 /usr/bin/php /home/painel/public_html/robots/monitor-servidores.php' >> /var/spool/cron/root
echo '*/15 * * * * /bin/nice -20 /usr/bin/php /home/painel/public_html/robots/monitor-capacidade.php' >> /var/spool/cron/root
echo '* * * * * /usr/bin/php /home/painel/public_html/robots/monitor-streamings-relay.php registros=0-20000' >> /var/spool/cron/root
echo '* * * * * /bin/nice -20 /usr/bin/php /home/painel/public_html/robots/gerar-estatisticas-shoutcast.php registros=0-20000' >> /var/spool/cron/root
echo '* * * * * /bin/nice -20 /usr/bin/php /home/painel/public_html/robots/gerar-estatisticas-wowza.php registros=0-20000' >> /var/spool/cron/root
echo '* * * * * /bin/nice -20 /usr/bin/php -q /home/painel/public_html/robots/agendamentos.php registros=0-50000' >> /var/spool/cron/root
echo '* * * * * /bin/nice -20 /usr/bin/php /home/painel/public_html/robots/atualizar-uso-ftp.php registros=0-20000' >> /var/spool/cron/root
service crond restart
#################################################################################
###### DESPOIS QUE MANDAR OS ARQUIVOS DO PAINEL TEM QUE AJUSTAR PERMISSAO #######
#################################################################################
cd /home/painel/public_html
chown painel.painel * -Rfv
cd /home/player/public_html
chown painel.painel * -Rfv
######################################
###### CONFIGURAÇÂO PHPMYADMIN #######
######################################
rm -f /etc/httpd/conf.d/phpMyAdmin.conf
touch /etc/httpd/conf.d/phpMyAdmin.conf
echo 'Alias /srv-bd-admin /usr/share/phpMyAdmin' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '<Directory /usr/share/phpMyAdmin/setup/>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '   <IfModule mod_authz_core.c>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     # Apache 2.4' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     <RequireAny>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '       Require ip 127.0.0.1' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '       Require ip ::1' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     </RequireAny>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '   </IfModule>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '   <IfModule !mod_authz_core.c>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     # Apache 2.2' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     Order Deny,Allow' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     Deny from All' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     Allow from 127.0.0.1' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '     Allow from ::1' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '   </IfModule>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '</Directory>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '<Directory /usr/share/phpMyAdmin/libraries/>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Order Deny,Allow' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Deny from All' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Allow from None' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '</Directory>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '<Directory /usr/share/phpMyAdmin/setup/lib/>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Order Deny,Allow' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Deny from All' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Allow from None' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '</Directory>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '<Directory /usr/share/phpMyAdmin/setup/frames/>' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Order Deny,Allow' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Deny from All' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '    Allow from None' >> /etc/httpd/conf.d/phpMyAdmin.conf
echo '</Directory>' >> /etc/httpd/conf.d/phpMyAdmin.conf
/etc/init.d/mysqld restart
mysql_secure_installation
/etc/init.d/httpd restart
#concluir
clear
echo "${GREEN}"
echo "================================================================="
echo
echo 
echo "Concluído. :)"
echo
echo "A porta SSH foi alterada de 22 para 6985."
echo
echo "Configure o banco de dados e demais dependências manualmente."
echo "phpMyAdmin: http://$dominio/srv-bd-admin"
echo "Usuário MySQL: root"
echo "Senha MySQL: $senhamysql"
echo "O nome de banco de dados deve ser 'audioaju', para evitar bugs."
echo
echo "Edite os arquivos e configure o banco de dados."
echo "/home/painel/admin/inc/conecta.php"
echo "/home/player/inc/conecta-remoto.php"
echo "/home/painel/robots/inc/conecta-remoto.php"
echo
echo "Admin/Revenda: http://$dominio/admin"
echo "Usuário e senha: admin"
echo "Cliente: http://$dominio"
echo
echo "================================================================="
echo "${NC}"
fi

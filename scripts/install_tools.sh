#!/bin/bash

#Muestra todos los comandos que se van ejecutando
set -ex

# Se importan las variables de configuracion
source .env

#Actualizamos repositorios 
apt update

#Actualizamos los paquetes 
#apt upgrade -y

#Configuramos las respuestas
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
#Instalamos phpmyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# Creamos un usuario que tengo acceso a todas las bases de datos 
mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%';"


# Instalamos Adminer 
# Creamos el directorio para adminer 
mkdir -p /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

# Renombramos el nombre del archivo de Adminer 
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# Modificamos el propietario y el grupo del directorio /var/www/html
chown -R www-data:www-data /var/www/html

# Instalamos GoAccess
apt install goaccess -y

# Creamos un directorio para los informes html de GoAccess
mkdir -p /var/www/html/stats 

# Ejecutamos GoAccess en segundo plano 
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

# Paso 5. Configuramos la autenticación básica de un directorio
# Creamos el archivo .htpasswd
htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

# Copiamos ek archivo de configuración dde apache con la configuracion del acceso 
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf

# Reiniciamos el servicio de Apache 
systemctl restart apache2
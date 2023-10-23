# practica-01-IAW
Repositorio para la primera practica en amazon

### Primero instalamos la instancia en amazon web services para ello pulsamos en lanzar instancias
![Captura 1](https://github.com/JoseFco04/practica-01-IAW/assets/145347148/d0429595-4975-4a76-a2bd-9244a6a673cc)

### Ponemos el tipo de instancia en small
![Captura 2](https://github.com/JoseFco04/practica-01-IAW/assets/145347148/f06ac2b4-85fa-4d7c-962c-dce9793916f1)

### Le pulsamos en permitir el trafico http y https para que añada sus grupos de seguridad directamente
![Cap 3](https://github.com/JoseFco04/practica-01-IAW/assets/145347148/1930e39b-2550-4f2f-85e6-027bf242ffdc)

### Asignnamos una ip elástica a la instancia 
![Cap 4](https://github.com/JoseFco04/practica-01-IAW/assets/145347148/1c768fb3-d1e0-4fef-8fa6-b7f650e736b6)

### El script del install lamp es el siguiente, son los siguientes comandos con su comentario de que hacen 
#!/bin/bash

### Muestra todos los comandos que se van ejecutando
set -x

### Actualizamos los repositorios
### apt update

### Actualizamos los paquetes

### apt upgrade -y

### instalamos el servidor web Apache
apt install apache2 -y

### Instalamos e sistema gestor de base de datos de mysql
apt install mysql-server -y

#mysql -u $DB_USER -p $DP_PASSWD < .../sql/database.sql

### Instalamos  PHP
apt install php libapache2-mod-php php-mysql -y

### Copiar el archivo de configuración de Apache 
cp ../conf/000-default.conf /etc/apache2/sites-available
### Reiniciamos el servicio Apache
systemctl restart apache2

### Copiamos el archivo de prueba de php
cp ../php/index.php /var/www/html

### Modificamos el propietario y el grupo del directorio /var/www/html

chown -R www-data:www-data /var/www/html

### El script del install tools paso por paso en el cual instalamos phpmyadmin,Adminer y GoAccess
### Se importan las variables de configuracion
source .env

### Actualizamos repositorios 
apt update

### Actualizamos los paquetes 
#apt upgrade -y

### Configuramos las respuestas
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
#Instalamos phpmyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

### Creamos un usuario que tengo acceso a todas las bases de datos 
mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@''%';"


### Instalamos Adminer 
### Creamos el directorio para adminer 
mkdir -p /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

### Renombramos el nombre del archivo de Adminer 
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

### Modificamos el propietario y el grupo del directorio /var/www/html
chown -R www-data:www-data /var/www/html

### Instalamos GoAccess
apt install goaccess -y

### Creamos un directorio para los informes html de GoAccess
mkdir -p /var/www/html/stats 

### Ejecutamos GoAccess en segundo plano 
goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED --real-time-html --daemonize

## Paso 5. Configuramos la autenticación básica de un directorio
### Creamos el archivo .htpasswd
htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

### Copiamos ek archivo de configuración dde apache con la configuracion del acceso 
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf

### Y el archivo .env donde guardamos las variables de las contraseñas y nombres de usuario
### Configuramos las variables 
### ------------------------------------
PHPMYADMIN_APP_PASSWORD=123456
APP_USER=usuario
APP_PASSWORD=password
STATS_USERNAME=Josefco
STATS_PASSWORD=123456


### Reiniciamos el servicio de Apache 
systemctl restart apache2



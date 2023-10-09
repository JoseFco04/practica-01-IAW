#!/bin/bash

#Muestra todos los comandos que se van ejecutando
set -x

# Configuramos las variables 
#------------------------------------
#PHPMYADMIN_APP_PASSWORD=123456
#------------------------------------
#Actualizamos repositorios 
#apt update

#Actualizamos los paquetes 
#apt upgrade -y

#Configuramos las respuestas
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
#Instalamos phpmyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl 
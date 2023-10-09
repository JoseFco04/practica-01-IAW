#!/bin/bash

#Muestra todos los comandos que se van ejecutando
set -x

#Actualizamos repositorios 
#apt update

#Actualizamos los paquetes 
#apt upgrade -y

#Instalamos phpmyadmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl 
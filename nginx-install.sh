#!/bin/bash
# Script para instalar y configurar Nginx automáticamente
# Autor: Santiago Chivata
# Fecha: $(date)

set -e  # Detener ejecución si ocurre un error

# Función para verificar si el usuario es root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root o con sudo."
    exit 1
  fi
}

# Función para instalar nginx
install_nginx() {
  echo "Actualizando paquetes..."
  apt update -y

  echo "Instalando Nginx..."
  apt install -y nginx

  echo "Habilitando y arrancando el servicio..."
  systemctl enable nginx
  systemctl start nginx

  echo "Nginx instalado y ejecutándose en http://localhost"
}

# Ejecutar funciones
check_root
install_nginx
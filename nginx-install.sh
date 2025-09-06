#!/usr/bin/env bash
# nginx-install.sh
# Instalador idempotente de Nginx (Debian/Ubuntu y CentOS/RHEL)
# Autor: Santiago Chivata
# Fecha: $(date)

set -euo pipefail

LOGFILE="/var/log/nginx-install.log"

# Función de logging
log() {
    local level="$1"; shift
    echo "$(date +'%F %T') [$level] $*" | tee -a "$LOGFILE"
}

# Verificar si es root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script debe ejecutarse como root o con sudo."
        exit 1
    fi
}

# Detectar distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=${ID,,}
    else
        log "ERROR" "No se pudo detectar la distribución"
        exit 1
    fi
}

# Verificar si Nginx ya está instalado
is_installed() {
    case "$DISTRO" in
        ubuntu|debian)
            dpkg -s nginx >/dev/null 2>&1
            ;;
        centos|rhel|rocky|almalinux)
            rpm -q nginx >/dev/null 2>&1
            ;;
        *)
            false
            ;;
    esac
}

# Instalar Nginx según distro
install_nginx() {
    case "$DISTRO" in
        ubuntu|debian)
            log "INFO" "Actualizando repositorios (apt)..."
            apt update -y
            log "INFO" "Instalando Nginx (apt)..."
            apt install -y nginx
            ;;
        centos|rhel|rocky|almalinux)
            log "INFO" "Instalando Nginx (yum)..."
            yum install -y epel-release || true
            yum install -y nginx
            ;;
        *)
            log "ERROR" "Distribución no soportada: $DISTRO"
            exit 1
            ;;
    esac
}

# Habilitar y arrancar servicio
enable_start_service() {
    log "INFO" "Habilitando y arrancando Nginx..."
    systemctl enable --now nginx
}

# Abrir puerto 80 en firewall
configure_firewall() {
    if command -v ufw >/dev/null 2>&1; then
        log "INFO" "Abriendo puerto 80 en ufw..."
        ufw allow 'Nginx HTTP' || ufw allow 80/tcp
    elif command -v firewall-cmd >/dev/null 2>&1; then
        log "INFO" "Abriendo puerto 80 en firewalld..."
        firewall-cmd --permanent --add-service=http || true
        firewall-cmd --reload || true
    else
        log "INFO" "No se detectó firewall gestionado por ufw/firewalld"
    fi
}

# Backup de index.html y crear uno básico
deploy_index() {
    local index_path="/var/www/html/index.html"
    if [ -f "$index_path" ]; then
        log "INFO" "Haciendo backup de $index_path"
        cp -a "$index_path" "${index_path}.backup.$(date +%s)"
    fi
    log "INFO" "Creando index.html básico"
    cat > "$index_path" <<HTML
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Nginx - Instalado</title></head>
<body>
<h1>Nginx instalado correctamente</h1>
<p>Script: nginx-install.sh</p>
<p>Fecha: $(date)</p>
</body>
</html>
HTML
}

# Resumen final
post_checks() {
    log "INFO" "Comprobando estado del servicio..."
    systemctl status nginx --no-pager | tee -a "$LOGFILE"

    log "INFO" "Comprobando HTTP en localhost..."
    curl -I http://localhost || true
}

# === MAIN ===
check_root
touch "$LOGFILE"
chmod 640 "$LOGFILE"
detect_distro

if is_installed; then
    log "INFO" "Nginx ya está instalado. No se reinstalará."
else
    install_nginx
fi

enable_start_service
configure_firewall
deploy_index
post_checks

log "INFO" "Instalación finalizada. Revisa $LOGFILE para más detalles."
echo "✅ Nginx instalado y corriendo en http://localhost"
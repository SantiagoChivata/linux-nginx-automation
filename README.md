# 🚀 Automatización de instalación de Nginx con Bash

Este proyecto contiene un script en **Bash** para instalar y configurar un servidor web **Nginx** automáticamente en Linux.

## 📂 Estructura
linux-nginx-automation/
│── README.md
│── nginx-install.sh
│── screenshots/
└── docs/


## ⚙️ Requisitos
- Linux (Ubuntu/Debian)
- Usuario con permisos `sudo`
- Git instalado

> [!NOTE]
> ## ▶️ Uso
>   * 1. Clona el repositorio: 
    git clone https://github.com/SantiagoChivata/linux-nginx-automation.git
    cd linux-nginx-automation

>   * 2. Dar permisos al script:
```chmod +x nginx-install.sh```

>   * 3. Ejecútalo con sudo:
```sudo ./nginx-install.sh```

>   * 4. Verificar que Nginx está corriendo, Abre en tu navegador:
```http://localhost```
>   O desde terminal:
```curl -I http://localhost```
```curl http://localhost | head -n 20```

> ## Validaciones que realiza el script
>   * Detección de distribución (Debian/Ubuntu o CentOS/RHEL).
>   * Verifica si Nginx ya está instalado (y no lo reinstala).
>   * Habilita y arranca el servicio (systemctl enable --now nginx).
>   * Abre el puerto 80 en ufw o firewalld si están disponibles.
>   * Hace backup del index.html por si ya existía.
>   * Crea /var/log/nginx-install.log con registro de acciones.
>   * Devuelve salida final con resumen y comandos de comprobación (systemctl status nginx, curl).

> [!IMPORTANT]
> 🛠️ Buenas prácticas aplicadas

✅ Idempotencia: si ejecutas el script dos veces, no rompe nada.
✅ Uso de set -e para detenerse en caso de errores.
✅ Funciones claras (check_root, install_nginx).
✅ Documentación en README.md y capturas en screenshots/.

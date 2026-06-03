# Lin-Security-Audit 🛡️

Un script automatizado en Bash diseñado para realizar auditorías rápidas de seguridad y comprobar el estado de *hardening* (endurecimiento) en servidores basados en Linux (Debian/Ubuntu). 

Este script ayuda a los administradores de sistemas a detectar debilidades comunes de configuración en segundos, generando un reporte de auditoría local listo para su revisión.

## 🚀 Funcionalidades
El script automatiza la verificación de cuatro pilares básicos de seguridad del sistema operativo:
1. **Estado del Firewall:** Comprueba si `UFW` está instalado y activo en el sistema.
2. **Auditoría de SSH:** Examina la directiva `PermitRootLogin` en el archivo de configuración del servidor SSH para mitigar ataques de fuerza bruta.
3. **Control de Privilegios:** Analiza `/etc/passwd` en busca de usuarios no autorizados que contengan UID 0 (privilegios de superusuario).
4. **Visibilidad de Red:** Identifica y registra todos los puertos y servicios de red que se encuentran actualmente en estado de escucha (`LISTEN`).

## 🛠️ Requisitos e Instalación
El script utiliza herramientas nativas de administración de sistemas Linux (`ufw`, `ss`, `awk`, `grep`), por lo que no requiere instalar dependencias adicionales.

1. Clona el repositorio en el servidor que quieras auditar:
```bash
git clone [https://github.com/tu-usuario/lin-security-audit.git](https://github.com/tu-usuario/lin-security-audit.git)
```

2. Dale permisos de ejecución al script:
```bash
cd lin-security-audit
chmod +x audit.sh
```

## 💻 Modo de Uso
Debido a que el script accede a archivos críticos de configuración del sistema (como `/etc/ssh/sshd_config` y los sockets de red), **debe ejecutarse con privilegios de root**:

```bash
sudo ./audit.sh
```

## 📊 Salida del Script
El script muestra alertas visuales en colores directamente en la terminal para una rápida identificación de riesgos (`OK` / `WARN` / `PELIGRO`). Además, vuelca de forma automática un informe detallado con el nombre `reporte_seguridad_AAAA-MM-DD.txt` en el mismo directorio.

### Ejemplo del Reporte Generado:
```text
==================================================
  REPORTE DE AUDITORÍA DE SEGURIDAD - Wed Jun  3 12:45:00 CEST 2026
==================================================

[1] Comprobando el estado del Firewall (UFW)...
Resultado: Status: active

[2] Analizando la configuración de SSH (/etc/ssh/sshd_config)...
[PELIGRO] PermitRootLogin está activo. Se recomienda desactivarlo.

[3] Buscando usuarios con UID 0 (Privilegios de Superusuario)...
Usuarios con UID 0 encontrados: 
root

[4] Listando puertos locales en escucha (Sockets abiertos)...
tcp   LISTEN 0      4096         0.0.0.0:22        0.0.0.0:*     users:(("sshd",pid=924,fd=3))
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*     users:(("apache2",pid=1102,fd=6))
```

## 📈 Próximas Mejoras (Roadmap)
* Añadir verificación de políticas de contraseñas complejas en `/etc/login.defs`.
* Comprobación de actualizaciones de seguridad pendientes en el gestor de paquetes (`apt`).

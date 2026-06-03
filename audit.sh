#!/bin/bash

# ==============================================================================
# Título:        lin-security-audit.sh
# Descripción:   Script básico de auditoría de seguridad y hardening para Linux.
# Requisitos:    Ejecutar como root (sudo).
# ==============================================================================

# Colores para la salida en terminal
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
SIN_COLOR='\033[0m'

REPORTE="reporte_seguridad_$(date +%F).txt"

# Asegurar que el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo -e "${ROJO}[!] Error: Este script debe ejecutarse con privilegios de root (sudo).${SIN_COLOR}"
  exit 1
fi

echo "==================================================" > "$REPORTE"
echo "  REPORTE DE AUDITORÍA DE SEGURIDAD - $(date)" >> "$REPORTE"
echo "==================================================" >> "$REPORTE"

echo -e "${VERDE}[*] Iniciando auditoría del sistema...${SIN_COLOR}"

# 1. Comprobación del Firewall (UFW)
echo -e "\n[1] Comprobando el estado del Firewall (UFW)..." | tee -a "$REPORTE"
if command -v ufw >/dev/null 2>&1; then
    ESTADO_UFW=$(ufw status | grep -i "Status")
    echo "Resultado: $ESTADO_UFW" >> "$REPORTE"
    if echo "$ESTADO_UFW" | grep -q "active"; then
        echo -e "${VERDE}[OK] El firewall UFW está activo.${SIN_COLOR}"
    else
        echo -e "${ROJO}[PELIGRO] El firewall UFW está INACTIVO.${SIN_COLOR}" >> "$REPORTE"
        echo -e "${ROJO}[PELIGRO] El firewall UFW está INACTIVO.${SIN_COLOR}"
    fi
else
    echo -e "${AMARILLO}[WARN] UFW no está instalado en este sistema.${SIN_COLOR}" | tee -a "$REPORTE"
fi

# 2. Comprobación de la configuración de SSH
echo -e "\n[2] Analizando la configuración de SSH (/etc/ssh/sshd_config)..." | tee -a "$REPORTE"
SSH_CONFIG="/etc/ssh/sshd_config"

if [ -f "$SSH_CONFIG" ]; then
    # Comprobar si el acceso root directo está permitido
    PERMIT_ROOT=$(grep -E "^PermitRootLogin" "$SSH_CONFIG" || echo "PermitRootLogin yes (por defecto)")
    echo "Configuración encontrada: $PERMIT_ROOT" >> "$REPORTE"
    
    if echo "$PERMIT_ROOT" | grep -q "yes"; then
        echo -e "${ROJO}[PELIGRO] PermitRootLogin está activo. Se recomienda desactivarlo.${SIN_COLOR}" | tee -a "$REPORTE"
    else
        echo -e "${VERDE}[OK] El acceso directo como root por SSH está protegido o deshabilitado.${SIN_COLOR}"
    fi
else
    echo -e "${AMARILLO}[WARN] No se encontró el archivo de configuración de SSH Server.${SIN_COLOR}" | tee -a "$REPORTE"
fi

# 3. Detección de usuarios con UID 0 (Privilegios Root)
echo -e "\n[3] Buscando usuarios con UID 0 (Privilegios de Superusuario)..." | tee -a "$REPORTE"
USUARIOS_ROOT=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
echo "Usuarios con UID 0 encontrados: " >> "$REPORTE"
echo "$USUARIOS_ROOT" >> "$REPORTE"

COUNT_ROOT=$(echo "$USUARIOS_ROOT" | wc -l)
if [ "$COUNT_ROOT" -gt 1 ]; then
    echo -e "${AMARILLO}[WARN] Hay más de un usuario con privilegios root:${SIN_COLOR}"
    echo "$USUARIOS_ROOT"
else
    echo -e "${VERDE}[OK] Solo el usuario 'root' tiene UID 0.${SIN_COLOR}"
fi

# 4. Puertos e interfaces en escucha
echo -e "\n[4] Listando puertos locales en escucha (Sockets abiertos)..." | tee -a "$REPORTE"
if command -v ss >/dev/null 2>&1; then
    ss -tulpn | grep LISTEN >> "$REPORTE"
    echo -e "${VERDE}[OK] Puertos en escucha volcados al reporte.${SIN_COLOR}"
else
    echo "Comando 'ss' no disponible." >> "$REPORTE"
fi

echo -e "\n${VERDE}[*] Auditoría finalizada con éxito.${SIN_COLOR}"
echo -e "${AMARILLO}[i] Los resultados detallados se han guardado en: $REPORTE${SIN_COLOR}"

#!/bin/bash

# --- 1. Paquetes del sistema ---
PACKAGES=("ansible" "python3-pip" "sshpass" "dos2unix")
PACKAGES_TO_INSTALL=()

for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg " ; then
        PACKAGES_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -ne 0 ]; then
    echo "Instalando paquetes faltantes: ${PACKAGES_TO_INSTALL[*]}..."
    sudo apt update && sudo apt install -y "${PACKAGES_TO_INSTALL[@]}"
fi

# --- 2. Librerías Python ---
echo "Instalando librerías Python (proxmoxer, requests)..."
pip3 install proxmoxer requests --user --break-system-packages 2>/dev/null

# --- 3. Instalación de Colecciones ---
BASE_DIR=$(dirname "$(cd "$(dirname "$0")" && pwd)")

echo "Instalando colecciones desde requirements.yml de forma global..."
ansible-galaxy collection install -r "$BASE_DIR/ansible/collections/requirements.yml" --force

# --- 4. Configuración SSH Automática ---
echo "Verificando claves SSH..."
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generando par de claves SSH..."
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa" >/dev/null 2>&1
fi

echo "--------------------------------------------------------"
read -p "¿Quieres autorizar la conexión con Proxmox ahora? (s/n): " CONFIGURE_SSH

if [[ "$CONFIGURE_SSH" =~ ^[Ss]$ ]]; then
    read -p "IP de Proxmox [192.168.1.156]: " PVE_IP
    PVE_IP=${PVE_IP:-192.168.1.156}
    
    read -s -p "Contraseña de root de Proxmox: " PVE_PASS
    echo ""
    
    echo "Enviando clave SSH..."
    sshpass -p "$PVE_PASS" ssh-copy-id -o StrictHostKeyChecking=no root@"$PVE_IP" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Acceso SSH autorizado correctamente."
    else
        echo "Error al copiar la clave. Verifica la contraseña o la IP."
    fi
fi

# --- 5. Limpieza de archivos ---
echo "Limpiando formatos de archivos..."
find "$BASE_DIR/ansible" -type f \( -name "*.yml" -o -name "*.ini" -o -name "*.cfg" \) -exec dos2unix {} + 2>/dev/null

echo "--------------------------------------------------------"
echo "ENTORNO PREPARADO"
echo "Las colecciones se han instalado en tu HOME de Linux."
echo "--------------------------------------------------------"
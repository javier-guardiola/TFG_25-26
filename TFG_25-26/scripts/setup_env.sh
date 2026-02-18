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
python3 -c "import proxmoxer, requests" 2>/dev/null || \
pip3 install proxmoxer requests --user --break-system-packages

# --- 3. Instalación Local de la Colección ---
# La instalamos en ./ansible/collections para que coincida con tu .cfg
BASE_DIR=$(dirname "$(cd "$(dirname "$0")" && pwd)")
echo "Instalando coleccion en ruta local..."
ansible-galaxy collection install community.general -p "$BASE_DIR/ansible/collections"

# --- 4. Limpieza de archivos ---
echo "Limpiando formatos de archivos en carpeta ansible..."
find "$BASE_DIR/ansible" -type f -name "*.yml" -o -name "*.ini" | xargs dos2unix 2>/dev/null

echo "Listo. Ahora puedes lanzar el playbook desde la carpeta 'ansible'."
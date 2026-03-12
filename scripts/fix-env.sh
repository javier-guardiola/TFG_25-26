#!/bin/bash

apt-get update
apt-get remove --purge -y ansible ansible-core
apt-get autoremove -y
apt-get install -y python3-pip python3-venv python3-full sshpass

VENV_DIR="$HOME/tfg-venv"
python3 -m venv $VENV_DIR

source $VENV_DIR/bin/activate

pip install "ansible-core<2.17" "ansible<10.0" proxmoxer requests jmespath
pip install --upgrade pyopenssl cryptography requests-toolbelt urllib3

rm -rf ~/.ansible/collections

if [ -f "../ansible/collections/requirements.yml" ]; then
    ansible-galaxy collection install -r ../ansible/collections/requirements.yml
elif [ -f "ansible/collections/requirements.yml" ]; then
    ansible-galaxy collection install -r ansible/collections/requirements.yml
else
    ansible-galaxy collection install community.proxmox
fi

echo "=================================================================="
echo "ENTORNO REPARADO. EJECUTA ESTE COMANDO ANTES DE LANZAR ANSIBLE:"
echo "source $HOME/tfg-venv/bin/activate"
echo "=================================================================="git 
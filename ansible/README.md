# Automatización de Infraestructura (Ansible)

Este directorio contiene toda la lógica de **Infraestructura como Código (IaC)** utilizada para gestionar el entorno Proxmox VE.

### Contenidos
- **Playbooks:** Scripts YAML que definen el estado deseado de los contenedores LXC y las máquinas virtuales.
- **Inventories:** Listado de hosts, grupos y variables específicas de cada entorno.
- **Roles/Tasks:** Tareas modulares para la instalación de dependencias, configuración de red y securización de servicios.

### Objetivo
Automatizar el ciclo de vida de los servicios (creación, configuración y mantenimiento), eliminando la intervención manual y garantizando la repetibilidad del entorno.
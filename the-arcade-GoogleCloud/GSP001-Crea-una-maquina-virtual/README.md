# 🛡️ Lab Report: Creating a Virtual Machine (GSP001)

**Date:** May 14, 2026  
**Series:** The Arcade Google Cloud 2026 / Base Camp  
**Author:** Yair Rosas  
**Status:** ✅ Completed

## 🎯 Lab Objectives (Objetivos)
* **Provisioning:** Crear instancias de máquinas virtuales (VM) utilizando la consola web y la línea de comandos `gcloud`.
* **Software Deployment:** Instalar y configurar un servidor web NGINX en una instancia de Linux.
* **Network Configuration:** Configurar reglas de firewall para permitir tráfico HTTP entrante.

## 🏗️ Architecture Overview (Resumen de Arquitectura)
* **Compute Resources:** 2 Instancias de VM (`gcelab` y `gcelab2`).
* **Machine Type:** `e2-medium` (2 vCPU, 4 GB RAM).
* **Operating System:** Debian GNU/Linux 12 (bookworm).
* **Network:** Default VPC con una regla de Firewall en el puerto 80.

## 🛠️ Deployment Scripts & Commands
| Command (English Term) | Description (Spanish) |
| :--- | :--- |
| `gcloud compute instances create` | **Resource Provisioning:** Comando principal para desplegar la infraestructura. |
| `sudo apt-get update && install` | **Package Management:** Actualización de repositorios e instalación de software. |
| `ps auwx | grep nginx` | **Process Verification:** Comando de Linux para verificar que el servicio está corriendo. |

> [!TIP]
> Puedes encontrar el script de automatización completo en el archivo `scripts.sh` de este directorio.

## 🌐 Remote Access (SSH Cheat Sheet)
Para gestionar las instancias desde la terminal (Cloud Shell o Kali Linux):

```bash
# Conexión estándar
gcloud compute ssh gcelab --zone=us-central1-a

# Ejecución de comandos remotos (Non-interactive mode)
gcloud compute ssh gcelab --zone=us-central1-a --command="sudo systemctl status nginx"

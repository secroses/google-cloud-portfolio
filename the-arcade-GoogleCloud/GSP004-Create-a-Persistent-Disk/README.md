# Define the markdown content for the professional README
readme_content = """# GSP004: Persistent Disk Provisioning & Attachment

![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Category](https://img.shields.io/badge/Category-Infrastructure-blue?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Introductory-green?style=for-the-badge)

## 🎯 Objetivos del Laboratorio
Este laboratorio técnico se enfoca en la gestión del ciclo de vida del almacenamiento en bloque dentro de un entorno de nube pública.

* **Provisioning:** Configuración de una máquina virtual (VM) en Google Compute Engine.
* **Storage Management:** Despliegue de un *Persistent Disk* estándar independiente del ciclo de vida de la instancia.
* **Block Storage Attachment:** Vinculación lógica y física del disco a la VM.
* **System Persistence:** Configuración del sistema operativo Linux para el formateo, montaje y persistencia automática mediante `/etc/fstab`.

## 🏗️ Descripción de la Arquitectura
La arquitectura implementada consiste en un **Deployment de Nodo Único** operando bajo una distribución basada en Debian. El nodo cuenta con un disco de arranque (Boot Disk) por defecto y un volumen secundario de 200 GB (`mydisk`). 

Para garantizar la viabilidad técnica y baja latencia, ambos recursos residen en la misma **Zona Lógica**, permitiendo que el protocolo de comunicación entre el hypervisor y el almacenamiento sea óptimo.

---

## 💻 Comandos de Despliegue (gcloud CLI)
La infraestructura se orquesta mediante la interfaz de línea de comandos de Google Cloud:

# ☁️ Google Cloud Compute Basics: Challenge Lab

![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Introductory-yellow?style=for-the-badge)

## 🎯 Objectives
El objetivo de este laboratorio es implementar una arquitectura base para una aplicación web mediante el **provisioning** de recursos en Google Cloud, demostrando competencias operativas sin depender de instrucciones paso a paso.

*   Crear un bucket de almacenamiento de objetos (*Cloud Storage*).
*   Desplegar una máquina virtual (*Compute Engine*) con reglas de red específicas.
*   Aprovisionar y adjuntar almacenamiento en bloque adicional (*Persistent Disk*).
*   Configurar un servidor web NGINX mediante acceso remoto.

## 🏗️ Architecture Overview

La infraestructura consta de un servidor web público que actúa como punto de entrada, respaldado por almacenamiento escalable.


1.  **Frontend Node:** Una instancia de Compute Engine (Debian 12) operando como servidor web NGINX, permitiendo tráfico **Ingress** a través del puerto 80.
2.  **Storage Layer:** 
    *   Un disco persistente balanceado (10 GB) para el sistema operativo (*Boot Disk*).
    *   Un disco persistente estándar (200 GB) adjunto para almacenamiento de datos adicionales.
    *   Un bucket multirregional de Cloud Storage para el alojamiento de recursos estáticos o scripts de inicio.

## 🚀 Deployment Commands

Para desplegar la infraestructura base, ejecuta el script de automatización incluido en este repositorio:

```bash
chmod +x scripts.sh
./scripts.sh

# Google Cloud Compute Basics: Challenge Lab (ARC120)

![Status](https://img.shields.io/badge/Status-Completed-success) ![Platform](https://img.shields.io/badge/Platform-Google%20Cloud-blue) ![Focus](https://img.shields.io/badge/Focus-Security-red)

## Objectives
Este laboratorio se enfoca en el despliegue fundacional de infraestructura en la nube, cumpliendo con los requerimientos técnicos para alojar una aplicación web. Los objetivos principales alcanzados fueron:
1.  **Cloud Storage:** Creación de un bucket multirregional para el almacenamiento seguro de *scripts* de inicio y código fuente.
2.  **Compute Engine & Block Storage:** Despliegue de una instancia `e2-medium` y aprovisionamiento de un disco persistente secundario de 200 GB para almacenamiento de datos escalable.
3.  **Web Server Deployment:** Instalación, configuración y habilitación de un servidor web NGINX accesible públicamente.

## Architecture Overview
La topología desplegada representa una arquitectura web *Single-Tier* básica compuesta por:
*   **Compute Layer:** Una máquina virtual (VM) en Google Compute Engine (GCE) que actúa como servidor web público (*Frontend*).
*   **Storage Layer:** 
    *   Disco de arranque balanceado (*Boot Disk*) de 10 GB para el sistema operativo.
    *   Disco persistente (*Persistent Disk*) adicional de 200 GB adjunto a la instancia.
    *   Bucket de Cloud Storage multirregional para respaldo de *assets* estáticos.
*   **Network Layer:** Reglas de *firewall* a nivel de VPC (*Virtual Private Cloud*) que permiten tráfico de red entrante (*Ingress*) exclusivamente en el puerto `tcp:80` a través de *Network Tags*.

## Deployment Commands
Para automatizar el despliegue de esta infraestructura de forma rápida y auditable, ejecuta el *script* proporcionado:

```bash
chmod +x scripts.sh
./scripts.sh
```

## SSH Cheat Sheet
Comandos esenciales para la administración de la instancia y la recolección inicial de evidencia (*Incident Response* / *Log Analysis*):

*   **Secure Remote Access (IAP Tunneling):**
    ```bash
    gcloud compute ssh my-instance --zone=$ZONE --tunnel-through-iap
    ```
*   **Service Health Check:**
    ```bash
    sudo systemctl status nginx
    ```
*   **Access & Threat Hunting Logs:**
    ```bash
    sudo tail -f /var/log/nginx/access.log
    sudo tail -f /var/log/nginx/error.log
    ```
*   **Verify Attached Block Devices:**
    ```bash
    lsblk
    ```

## Cybersecurity Use Cases
Desde la perspectiva de un **SOC Analyst** (*Blue Team*), esta arquitectura permite practicar escenarios defensivos fundamentales:
*   **Web Traffic Analysis:** El servidor NGINX expuesto al exterior sirve como un sensor para capturar tráfico. El análisis de `access.log` permite detectar *crawlers* maliciosos, intentos de *SQL Injection* (SQLi) o *Directory Traversal*.
*   **Storage Security Auditing:** Validar la postura de seguridad del bucket de Cloud Storage para evitar la filtración de datos (*Data Exfiltration*), verificando políticas de *Uniform Bucket-Level Access*.
*   **Lateral Movement Detection:** Monitorear los *logs* de auditoría de Google Cloud (Cloud Audit Logs) para identificar intentos de escalado de privilegios desde la VM comprometida hacia otros recursos del proyecto.


## Security Posture (SOC Mindset)
El diseño original de este laboratorio prioriza la simplicidad funcional, pero introduce riesgos significativos en un entorno de producción. A continuación, se detallan tres vulnerabilidades críticas identificadas en la arquitectura y sus respectivas mitigaciones empresariales:

### 1. Vulnerability: Insecure HTTP Traffic Transmission (Port 80)
*   **Risk:** La aplicación está expuesta a través de HTTP (texto plano), lo que amplía la *Attack Surface* frente a ataques de *Man-in-the-Middle* (MitM). Un atacante podría interceptar o alterar el tráfico entre el usuario y el servidor.
*   **Enterprise Mitigation:** Implementar un **Global HTTP(S) Load Balancer** con un certificado SSL/TLS gestionado por Google para encriptar la comunicación en tránsito. Desplegar **Google Cloud Armor** (WAF) en el balanceador para mitigar ataques DDoS y reglas específicas del Top 10 de OWASP.

### 2. Vulnerability: Over-privileged Default Compute Service Account
*   **Risk:** La instancia de GCE se crea utilizando la cuenta de servicio predeterminada del proyecto, la cual generalmente posee el rol de *Editor* a nivel global. Si un atacante compromete NGINX, podría usar las credenciales de los metadatos de la VM para realizar un *Lateral Movement* y tomar control del proyecto entero.
*   **Enterprise Mitigation:** Aplicar estricto **PoLP** y **IAM Hardening**. Crear una cuenta de servicio personalizada (*Custom Service Account*) sin roles básicos. Asignarle únicamente roles granulares (ej. `roles/storage.objectViewer`) limitados al *bucket* específico y adjuntar esta cuenta durante la creación de la instancia.

### 3. Vulnerability: Publicly Exposed Infrastructure (External IP)
*   **Risk:** La instancia posee una IP pública asignada, lo que la expone directamente a escaneos automatizados de Internet (*botnets*, *port scanners*), aumentando drásticamente la probabilidad de compromiso por vulnerabilidades de día cero (*Zero-day*) en NGINX o en el sistema operativo.
*   **Enterprise Mitigation:** Eliminar la dirección IP pública de la instancia de GCE. Configurar **Cloud NAT** en la VPC para permitir que la VM tenga salida a Internet segura para actualizaciones de paquetes. Forzar la administración remota de los ingenieros exclusivamente a través de **Identity-Aware Proxy (IAP)**.

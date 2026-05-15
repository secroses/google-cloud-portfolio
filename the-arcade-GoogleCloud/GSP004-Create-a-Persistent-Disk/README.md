# GSP004: Persistent Disk Provisioning & Attachment

## Objectives
* Realizar el *Provisioning* de una máquina virtual (VM) en Google Compute Engine.
* Desplegar un disco persistente (Persistent Disk) estándar independiente del ciclo de vida de la VM.
* Ejecutar la vinculación (*Attachment*) del almacenamiento en bloques a la instancia.
* Configurar el sistema operativo a nivel de línea de comandos para formatear, montar y garantizar la persistencia del disco mediante `/etc/fstab`.

## Architecture
La arquitectura de este laboratorio consiste en un *Deployment* de un solo nodo (VM `gcelab`) operando bajo una distribución basada en Linux (Debian). El nodo cuenta con un disco de arranque (Boot Disk) por defecto y un disco persistente secundario de 200 GB (`mydisk`) conectado como dispositivo de almacenamiento en bloques (*Block Storage*). Ambos recursos residen en la misma zona lógica para garantizar baja latencia y viabilidad de conexión.

## Deployment Commands
Los comandos principales de `gcloud` utilizados para la infraestructura son:
* `gcloud compute instances create`: Despliega la VM.
* `gcloud compute disks create`: Crea el disco persistente de forma aislada.
* `gcloud compute instances attach-disk`: Vincula el disco a la VM especificada.
* `gcloud compute ssh`: Genera llaves RSA locales, inyecta la llave pública en los metadatos de la instancia y establece una conexión segura al sistema operativo.

## SSH Cheat Sheet
Una vez dentro del sistema operativo Linux, estos comandos interactúan con el hardware virtualizado. Comprenderlos desde cero es vital para la administración de sistemas:

* `ls -l /dev/disk/by-id/`: Lista los dispositivos físicos conectados. En Linux, todo es un archivo; `/dev` es el directorio de *devices*. Este comando te ayuda a identificar el nombre exacto asignado por Google Cloud al disco (ej. `scsi-0Google_PersistentDisk_...`).
* `sudo mkdir /mnt/mydisk`: Crea un directorio que servirá como "puerta de entrada" (Punto de montaje / *Mount point*) para acceder al nuevo disco.
* `sudo mkfs.ext4 [ruta_del_disco]`: `mkfs` significa *Make File System*. Transforma el disco en bruto en un sistema de archivos `ext4` organizado, permitiendo que el sistema operativo pueda escribir y leer datos estructurados.
* `sudo mount [ruta_del_disco] /mnt/mydisk`: Conecta el sistema de archivos recién formateado al directorio creado. Ahora, todo lo que guardes en `/mnt/mydisk` se escribirá físicamente en el disco persistente de 200 GB.
* `sudo nano /etc/fstab`: Abre el editor de texto `nano` para modificar el *File System Table*. Si no agregas una entrada aquí, al reiniciar la máquina, el disco se desconectará lógicamente. Escribir aquí garantiza la persistencia.

## Cybersecurity Use Cases
El uso de discos persistentes independientes es una práctica recomendada en seguridad por las siguientes razones:
1. **Forensic Analysis & Snapshots:** Si la VM de arranque es comprometida por *malware*, el disco secundario con los datos críticos puede ser desvinculado de inmediato y montado en una VM de análisis aislada en modo de solo lectura (Read-Only) para evitar manipulación de evidencia.
2. **Log Retention (Separation of Duties):** Almacenar los registros de auditoría y *logs* del sistema en un disco persistente separado protege la información en caso de que el sistema operativo principal colapse, se corrompa o se quede sin espacio (evitando ataques de denegación de servicio a nivel de almacenamiento).

## Technical Glossary (English/Spanish)
* **Provisioning:** Aprovisionamiento (Creación y asignación de recursos en la nube).
* **Hardening:** Bastionado (Proceso de asegurar un sistema reduciendo sus vulnerabilidades).
* **Deployment:** Despliegue (Puesta en marcha de la infraestructura).
* **Ingress / Egress:** Tráfico de entrada / Tráfico de salida (Flujo de datos en la red).
* **Persistent Disk (PD):** Disco Persistente (Almacenamiento en red altamente duradero).
* **Block Storage:** Almacenamiento en bloques (Datos guardados en volúmenes de tamaño fijo, ideal para bases de datos o sistemas de archivos).
* **Mount Point:** Punto de montaje (Directorio en Linux donde se hace accesible un sistema de archivos adicional).

## Security Posture (SOC Mindset)
Como analista de un Security Operations Center (SOC), evaluar esta configuración base revela múltiples vectores de riesgo que requerirían *Hardening* inmediato en un entorno de producción:

1. **Riesgo de Ingress (IP Pública por defecto):** El comando de creación de la VM asigna automáticamente una IP externa (`EXTERNAL_IP`). Esto expone la instancia a escaneos pasivos en Internet y posibles ataques de fuerza bruta por SSH. **Mitigación:** Desplegar la VM sin IP pública usando `--no-address` y acceder a través de Identity-Aware Proxy (IAP).
2. **Identidad y Privilegios (Service Account):** La VM se está desplegando con la cuenta de servicio predeterminada de Compute Engine, la cual suele tener el rol de "Editor" a nivel de proyecto (exceso de privilegios). **Mitigación:** Aplicar el principio de mínimo privilegio creando una Service Account dedicada con permisos granulares.
3. **Gestión de Claves Criptográficas:** El disco persistente se creó utilizando las claves de encriptación administradas por Google (Default). Para cumplir con regulaciones estrictas, se recomienda usar Customer-Managed Encryption Keys (CMEK) a través de Cloud KMS.
4. **Falta de Firewall Egress:** No se especifica ninguna restricción de red. La VM tiene acceso total de salida (*Egress*), lo que permitiría a un atacante establecer un canal de comando y control (C2) o exfiltrar los datos del disco persistente de 200 GB. **Mitigación:** Implementar reglas de firewall de *Egress* restrictivas (Default Deny).

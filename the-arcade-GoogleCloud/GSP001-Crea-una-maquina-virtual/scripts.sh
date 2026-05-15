#!/bin/bash

# ==============================================================================
# LAB: GSP001 - Creating a Virtual Machine
# DESCRIPTION: Automating VM provisioning, firewall configuration, and NGINX setup.
# AUTHOR: Edgar Yair Rosas Flores (secroses)
# DATE: 2026-05-14
# ==============================================================================

# 1. SET ENVIRONMENT VARIABLES (Configuración de entorno)
# Establishing regional and zonal variables for Resource Provisioning.
export REGION="us-central1"
export ZONE="us-central1-a"

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo "--- [1/4] Environment variables set: $REGION in $ZONE ---"

# 2. TASK 1: CREATE INSTANCE VIA CONSOLE/GCLOUD
# Provisioning a Linux Debian instance with an HTTP tag for web traffic.
echo "--- [2/4] Provisioning gcelab instance... ---"
gcloud compute instances create gcelab \
    --machine-type e2-medium \
    --zone=$ZONE \
    --tags=http-server \
    --image-family=debian-12 \
    --image-project=debian-cloud

# 3. TASK 2: INSTALL NGINX WEB SERVER
# Using Remote Execution to update and install NGINX without manual login.
# Note: The 'http-server' tag allows traffic on Port 80.
echo "--- [3/4] Installing NGINX Web Server via SSH... ---"
gcloud compute ssh gcelab --zone=$ZONE --quiet --command="sudo apt-get update && sudo apt-get install -y nginx"

# Create firewall rule to allow HTTP ingress traffic (Tráfico entrante)
echo "--- Creating Firewall Rule for Ingress Traffic... ---"
gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# 4. TASK 3: CREATE SECOND INSTANCE VIA GCLOUD
# Deploying a second instance (gcelab2) to demonstrate command-line scalability.
echo "--- [4/4] Provisioning gcelab2 instance... ---"
gcloud compute instances create gcelab2 \
    --machine-type e2-medium \
    --zone=$ZONE

echo "--- LAB DEPLOYMENT COMPLETE ---"
echo "Check external IP of gcelab to verify NGINX default page."

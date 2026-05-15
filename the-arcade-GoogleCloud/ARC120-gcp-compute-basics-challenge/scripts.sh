#!/bin/bash
# ==============================================================================
# Script Name: scripts.sh
# Description: Automated provisioning for ARC120 Challenge Lab.
# Role: Security Analyst 
# ==============================================================================

# Variables (Replace <YOUR_PROJECT_ID> with the actual Qwiklabs Project ID)
PROJECT_ID="<YOUR_PROJECT_ID>"
REGION="us-east1" # Modify if Qwiklabs assigns a different region
ZONE="us-east1-b" # Modify if Qwiklabs assigns a different zone
BUCKET_NAME="$PROJECT_ID-bucket"
INSTANCE_NAME="my-instance"
DISK_NAME="mydisk"

echo "🚀 Starting infrastructure provisioning..."

# 1. Provisioning Cloud Storage Bucket (US Multi-region)
echo "📦 Creating Cloud Storage bucket..."
gcloud storage buckets create gs://$BUCKET_NAME --location=US

# 2. Provisioning Compute Engine VM with attached boot disk and HTTP Ingress allowed
echo "💻 Creating Compute Engine instance ($INSTANCE_NAME)..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server

# Allowing Ingress traffic on Port 80 (HTTP)
gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# 3. Provisioning Additional Persistent Disk
echo "💽 Creating secondary persistent disk ($DISK_NAME)..."
gcloud compute disks create $DISK_NAME \
    --size=200GB \
    --zone=$ZONE \
    --type=pd-standard

# Attaching the disk to the instance
echo "🔗 Attaching $DISK_NAME to $INSTANCE_NAME..."
gcloud compute instances attach-disk $INSTANCE_NAME \
    --disk=$DISK_NAME \
    --zone=$ZONE

echo "✅ Cloud resources provisioning completed successfully!"
echo "⚠️ Next step: SSH into $INSTANCE_NAME to install NGINX."

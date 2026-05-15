#!/bin/bash
# ==============================================================================
# Script Name: deploy_persistent_disk.sh
# Description: Automates the Provisioning of a Compute Engine VM and a Persistent Disk.
#              It also handles the attachment, formatting, and mounting via SSH.
# ==============================================================================

# 1. Define Environment Variables for Deployment
# Ensure you replace these with the specific Zone/Region provided by the lab.
REGION="us-central1"
ZONE="us-central1-a"
VM_NAME="gcelab"
DISK_NAME="mydisk"

echo "Starting Deployment..."

# 2. Configure default Compute Engine settings
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# 3. Provisioning the Virtual Machine
# Deploys an e2-standard-2 instance with default boot disk.
echo "Provisioning VM: $VM_NAME..."
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --machine-type=e2-standard-2

# 4. Provisioning the Persistent Disk (Block Storage)
# Creates a 200GB standard persistent disk in the same zone.
echo "Provisioning Persistent Disk: $DISK_NAME..."
gcloud compute disks create $DISK_NAME \
    --size=200GB \
    --zone=$ZONE

# 5. Attaching the Storage
# Connects the newly created disk to the running VM instance.
echo "Attaching $DISK_NAME to $VM_NAME..."
gcloud compute instances attach-disk $VM_NAME \
    --disk=$DISK_NAME \
    --zone=$ZONE

# 6. Hardening and OS-level Configuration via SSH
# Connects to the VM to create a filesystem, mount the disk, and ensure persistence on reboot.
echo "Executing remote OS configuration..."
gcloud compute ssh $VM_NAME --zone=$ZONE --command="
    # Create the mount point directory
    sudo mkdir -p /mnt/mydisk
    
    # Format the disk with ext4 filesystem
    sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1
    
    # Mount the disk to the directory
    sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk
    
    # Append the mount configuration to /etc/fstab for persistence after reboot
    echo '/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1' | sudo tee -a /etc/fstab
"

echo "Deployment complete."

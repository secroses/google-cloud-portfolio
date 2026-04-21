#!/bin/bash

# ==============================================================================
# PROJECT: Cymbal Retail Incident Response [cite: 68]
# TASK: Infrastructure Remediation and Hardening 
# ==============================================================================

# 1. COMPUTE RECOVERY: Restore system from a clean snapshot
# We use --no-address to ensure the instance has no Public IP (Attack Surface Reduction)
gcloud compute instances create cc-app-02 \
    --zone=us-east1-d \
    --machine-type=e2-medium \
    --source-snapshot=cc-app01-snapshot \
    --tags=cc \
    --no-address

# 2. SHIELDED VM CONFIGURATION: Enable Secure Boot
# This prevents unauthorized code and rootkits from loading during boot-up
gcloud compute instances stop cc-app-02 --zone=us-east1-d

gcloud compute instances update cc-app-02 \
    --zone=us-east1-d \
    --shielded-secure-boot

gcloud compute instances start cc-app-02 --zone=us-east1-d

# 3. NETWORK SECURITY: Implement Least Privilege Firewall Rules
# Create a rule to allow SSH access ONLY via Google Identity-Aware Proxy (IAP)
gcloud compute firewall-rules create limit-ports \
    --network=default \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=35.235.240.0/20 \
    --target-tags=cc \
    --rules=tcp:22

# 4. THREAT ERADICATION: Delete vulnerable default rules
# Removing risky rules for ICMP, RDP, and SSH open to 0.0.0.0/0
gcloud compute firewall-rules delete \
    default-allow-icmp \
    default-allow-rdp \
    default-allow-ssh \
    --quiet

# 5. OBSERVABILITY: Enable Firewall Logging
# Logging is essential to detect and respond to suspicious activity 
gcloud compute firewall-rules update limit-ports --enable-logging
gcloud compute firewall-rules update default-allow-internal --enable-logging

echo "Remediation process completed successfully."
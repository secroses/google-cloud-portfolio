# Lab Write-up: GSP313 - Implement Load Balancing on Compute Engine

**Date:** October 27, 2025
**Platform:** Google Cloud Skills Boost
**Objective:** To deploy a Network Load Balancer (Layer 4) and an HTTP Load Balancer (Layer 7) on Google Cloud.

---

## 1. Challenge Summary

The objective of this challenge lab is to create a resilient web architecture. This includes:
* Creating 3 VM instances (`web1`, `web2`, `web3`) with an Apache server.
* Creating a Network Load Balancer to distribute TCP traffic.
* Creating an HTTP/S Load Balancer to intelligently distribute web traffic.

---

## 2. Methodology and Strategy (The Key to Success)

After several failed attempts, the successful strategy depended not only on the correct commands but on **how and when** they were executed.

### A. The Rule of Patience and Verification
The key was to run the commands **one by one** and wait for the terminal to return control (the prompt).

* **Console Monitoring:** When creating the VMs (`web1`, `web2`, `web3`), it's essential to have the **"Compute Engine > VM instances"** tab open in the Google Cloud Console.
    1.  Run the command to create `web1`.
    2.  Wait for `web1` to appear in the console and its status to change to **RUNNING** (green). ✅
    3.  Only then, run the command to create `web2`.
    4.  Repeat the monitoring process for `web2` before creating `web3`.
* **Patience with Network Services:** Services like Firewall Rules and Load Balancers are not instant. They take several minutes to "propagate" across Google's network. It is crucial to wait 1-2 minutes after creating these resources before trying to use or verify them.

### B. The "Check Progress" Rule
Do not move forward if the grader does not register your progress.

1.  **Verify Task 1:** After
#!/bin/bash
#
# SOLUTION SCRIPT FOR GSP313 LAB
#
# IMPORTANT: Before running, edit these 3 variables
# with your lab session's information.
#
export REGION="us-west4"
export ZONE="us-west4-b"
export PROJECT_ID="qwiklabs-gcp-00-..." # <-- PUT YOUR PROJECT ID HERE

echo "--- Configuring gcloud project ---"
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

# ------------------------------------
# Task 1: Create web server instances
# ------------------------------------
echo "--- Starting Task 1: Creating VMs and Firewall ---"

echo "Creating web1..."
gcloud compute instances create web1 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-12 \
--image-project=debian-cloud \
--metadata startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web1</h3>" | tee /var/www/html/index.html'

echo "Creating web2..."
gcloud compute instances create web2 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-12 \
--image-project=debian-cloud \
--metadata startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web2</h3>" | tee /var/www/html/index.html'

echo "Creating web3..."
gcloud compute instances create web3 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-12 \
--image-project=debian-cloud \
--metadata startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web3</h3>" | tee /var/www/html/index.html'

echo "Creating firewall rule for Task 1..."
gcloud compute firewall-rules create www-firewall-network-lb \
--allow=tcp:80 \
--target-tags=network-lb-tag

# ------------------------------------
# Task 2: Configure the load balancing service
# ------------------------------------
echo "--- Starting Task 2: Network Load Balancer ---"

echo "Creating static IP..."
gcloud compute addresses create network-lb-ip-1 --region=$REGION

echo "Creating HTTP Health Check (for Task 2)..."
gcloud compute http-health-checks create basic-check

echo "Creating Target Pool..."
gcloud compute target-pools create www-pool \
--region=$REGION \
--http-health-check=basic-check

echo "Adding instances to Target Pool..."
gcloud compute target-pools add-instances www-pool \
--instances=web1,web2,web3 \
--instances-zone=$ZONE

echo "Creating Forwarding Rule..."
gcloud compute forwarding-rules create www-rule \
--region=$REGION \
--ports=80 \
--address=network-lb-ip-1 \
--target-pool=www-pool

# ------------------------------------
# Task 3: Create an HTTP load balancer
# ------------------------------------
echo "--- Starting Task 3: HTTP Load Balancer ---"

echo "Creating Instance Template..."
gcloud compute instance-templates create lb-backend-template \
--region=$REGION \
--network=default \
--subnet=default \
--tags=allow-health-check \
--machine-type=e2-medium \
--image-family=debian-12 \
--image-project=debian-cloud \
--metadata startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
a2ensite default-ssl
a2enmod ssl
vm_hostname="$(curl -H "Metadata-Flavor:Google" http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "Page served from: $vm_hostname" | tee /var/www/html/index.html
systemctl restart apache2'

echo "Creating Managed Instance Group..."
gcloud compute instance-groups managed create lb-backend-group \
--template=lb-backend-template \
--size=2 \
--zone=$ZONE

echo "Creating firewall rule for Health Checks..."
gcloud compute firewall-rules create fw-allow-health-check \
--network=default \
--action=allow \
--direction=ingress \
--source-ranges=130.211.0.0/22,35.191.0.0/16 \
--target-tags=allow-health-check \
--rules=tcp:80

echo "Creating HTTP Health Check (for Task 3)..."
gcloud compute health-checks create http http-basic-check --port=80

echo "Setting Named Ports..."
gcloud compute instance-groups managed set-named-ports lb-backend-group \
--named-ports http:80 \
--zone=$ZONE

echo "Creating Backend Service..."
gcloud compute backend-services create web-backend-service \
--protocol=HTTP \
--port-name=http \
--health-checks=http-basic-check \
--global

echo "Adding Backend to Backend Service..."
gcloud compute backend-services add-backend web-backend-service \
--instance-group=lb-backend-group \
--instance-group-zone=$ZONE \
--global

echo "Creating URL Map..."
gcloud compute url-maps create web-map-http \
--default-service web-backend-service

echo "Creating HTTP Proxy..."
gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-map-http

echo "Creating Global IP for HTTP load balancer..."
gcloud compute addresses create lb-ipv4-1 \
--ip-version=IPV4 \
--global

echo "Creating Global Forwarding Rule..."
gcloud compute forwarding-rules create http-content-rule \
--address=lb-ipv4-1 \
--global \
--target-http-proxy=http-lb-proxy \
--ports=80

echo "--- Script Completed! ---"

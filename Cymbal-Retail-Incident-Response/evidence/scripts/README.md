# [Project] Cloud Incident Response & Recovery: Cymbal Retail Case

## 📖 1. Introduction & Scenario
In this project, I acted as a **Junior Cloud Security Analyst** for **Cymbal Retail**, a global retail powerhouse. The organization recently experienced a major **Data Breach** that compromised sensitive customer data, including personal and credit card information.

**Mission:** Lead the incident response lifecycle by identifying vulnerabilities, containing threats, restoring compromised systems, and ensuring regulatory compliance.

---

## 🔍 2. Analysis Phase (Identification)
I performed a comprehensive **Vulnerability Assessment** using **Security Command Center (SCC)** and prioritized findings based on their severity to understand the breach's scope.

### Critical Findings:
* **Publicly Exposed Resources:** VM instances were assigned public IP addresses, making them directly accessible from the internet.
> ![Instance Vulnerabilities](./evidence/instance-vulnerabilities.png)

* **Open Management Ports:** Firewall rules allowed unrestricted SSH (Port 22) and RDP (Port 3389) access from any IP address (`0.0.0.0/0`).
> ![Firewall Vulnerabilities](./evidence/firewall-vulnerabilities.png)

* **Data Leakage Source:** A Cloud Storage bucket was found with a Public Access Control List (ACL), exposing sensitive files like `myfile.csv`.
> ![Storage Vulnerabilities](./evidence/storage-vulnerabilities.png)

* **Initial Compliance Status:** The PCI DSS 3.2.1 report showed high-severity violations regarding firewall rules allowing broad connections.
> ![SCC Critical Findings](./evidence/pci-dss-baseline.png)

---

## 🛡️ 3. Remediation Phase (Containment & Recovery)
To mitigate the incident and prevent further data exfiltration, I implemented the following **Hardening** measures:

### A. Compute Engine Recovery
* **Isolation & Eradication:** I immediately stopped and deleted the compromised VM (`cc-app-01`) to eliminate the malware source.
> ![Containment - Stop VM](./evidence/containment-stop-vm.png)
> ![Eradication - Delete VM](./evidence/eradication-delete-vm.png)

* **Secure Restoration:** Deployed a new instance (`cc-app-02`) from a clean, pre-infection **Snapshot**.
* **Shielded VM Implementation:** Enabled **Secure Boot** to protect the instance against boot-level malware and unauthorized rootkits.

### B. Cloud Storage Protection
* **Access Revocation:** Removed all public ACLs and prevented anonymous access to the storage buckets.
* **Enforcement:** Switched to **Uniform Bucket-Level Access** to ensure that only IAM policies control resource permissions consistently.

---

## 🌐 4. Network Security & Firewall Hardening
I significantly reduced the **Attack Surface** by applying the **Principle of Least Privilege** to the VPC network:

* **Rule Cleanup:** Deleted legacy "allow-all" rules for ICMP, RDP, and SSH.
* **IAP Secure Tunneling:** Created a restricted firewall rule (`limit-ports`) to allow SSH traffic **only** from Google's **Identity-Aware Proxy (IAP)** range (`35.235.240.0/20`).
* **Advanced Monitoring:** Enabled **Firewall Rule Logging** to provide full auditability and detect future unauthorized connection attempts.

---

## ✅ 5. Compliance Verification
After remediation, I executed a follow-up audit using the **PCI DSS 3.2.1** standard in SCC. The report confirmed that all high-severity vulnerabilities related to the breach were resolved, validating the effectiveness of the security controls implemented.

---

## 🛠️ Technical Arsenal
* **Platform:** Google Cloud Platform (GCP)
* **Security Tools:** Security Command Center (SCC), Identity-Aware Proxy (IAP).
* **Infrastructure:** Compute Engine (Shielded VMs, Snapshots), Cloud Storage (IAM, Uniform Access).
* **Automation:** gcloud CLI / Bash Scripting.

---
*This project is part of the Google Cloud Cybersecurity Professional Certificate.*

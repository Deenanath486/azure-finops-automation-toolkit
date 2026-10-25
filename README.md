# Azure FinOps Automation Toolkit 💰⚡

[![FinOps Framework](https://img.shields.io/badge/FinOps-Practitioner_Standard-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://www.finops.org/)
[![PowerShell](https://img.shields.io/badge/Scripting-PowerShell_7-5391FE?style=flat&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Python](https://img.shields.io/badge/Automation-Python_3.11-3776AB?style=flat&logo=python&logoColor=white)](https://python.org)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Infracost](https://img.shields.io/badge/FinOps_CI-Infracost-00D084?style=flat)](https://www.infracost.io/)

Production-grade **Azure FinOps Automation Toolkit** designed to eliminate cloud waste, detect orphaned cloud assets, schedule compute workloads, and enforce cost governance across enterprise Azure subscriptions.

---

## 🎯 FinOps Architecture & Workflow

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                              AZURE FINOPS CONTINUOUS CYCLE                             │
 └────────────────────────────────────────────────────────────────────────────────────────┘
          │
          ├──► 1. INFORM: Continuous Detection & Audit
          │    ├── find-unattached-disks.ps1 ────► [ Identifies Orphaned Disks + Cost Waste ]
          │    └── find-unused-public-ips.ps1 ───► [ Detects Idle Static Public IPs ]
          │
          ├──► 2. OPTIMIZE: Automated Rightsizing & Schedules
          │    └── vm-auto-scheduler.ps1 ────────► [ 65% Compute Savings via Nightly Shutdown ]
          │
          └──► 3. OPERATE: CI/CD & Anomaly Notification
               ├── Infracost PR Checks ──────────► [ Shift-Left Cost Visibility in GitHub PRs ]
               └── cost_anomaly_notifier.py ─────► [ Real-Time Alerts to Microsoft Teams ]
```

---

## 📊 Estimated Enterprise Savings Matrix

| FinOps Initiative | Target Resource | Estimated Savings |
| :--- | :--- | :--- |
| **VM Non-Prod Auto-Shutdown** | Dev/Test Azure VMs (12 hrs off daily + weekends) | **~65% reduction** in non-prod compute spend |
| **Unattached Disk Cleanup** | Orphaned OS & Data Disks after VM deletion | **$1,500 – $5,000+ / mo** across 50+ VMs |
| **Unused Public IP Removal** | Idle Standard Static Public IPs | **$3.65 / IP / mo** ($300+/yr per 10 IPs) |
| **Infracost PR Guardrails** | Terraform infrastructure changes | **Prevents accidental oversized SKU provisioning** |

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── infracost.yml           # Automated PR cost estimation breakdown
├── scripts/
│   ├── find-unattached-disks.ps1   # Scans & audits orphaned disks with cost calculation
│   ├── find-unused-public-ips.ps1  # Identifies unassociated Public IPs incurring hourly fees
│   ├── vm-auto-scheduler.ps1       # Automated Start/Deallocation for non-prod environments
│   └── cost_anomaly_notifier.py    # Daily budget threshold monitor with Teams/Slack alerts
├── infra/                          # Automation Account & Schedule via Terraform
│   ├── providers.tf                # AzureRM provider
│   └── main.tf                     # Azure Automation Account + 8PM & 8AM schedules
├── .gitignore
└── README.md
```

---

## 🚀 Execution & Usage Guide

### 1. Audit Unattached Disks
```powershell
# Run audit and generate CSV report:
.\scripts\find-unattached-disks.ps1 -ExportCsvPath ".\unattached-disks.csv"
```

### 2. Audit Unused Public IPs
```powershell
.\scripts\find-unused-public-ips.ps1 -ExportCsvPath ".\unused-ips.csv"
```

### 3. Automated VM Scheduler
```powershell
# Stop all Dev VMs (saves compute charges):
.\scripts\vm-auto-scheduler.ps1 -Action Stop -EnvironmentTag "Development"

# Start all Dev VMs:
.\scripts\vm-auto-scheduler.ps1 -Action Start -EnvironmentTag "Development"

# Note: Tag critical VMs with 'ExcludeFromAutoShutdown=true' to exempt them.
```

### 4. Deploy Azure Automation Schedules (Terraform)
```bash
cd infra
terraform init
terraform plan
terraform apply
```

---

## 👨‍💻 Author

**Deenanath Yadav**  
*DevOps & Azure Cloud Engineer*  
- **LinkedIn**: [linkedin.com/in/deenanath-yadav-495110146](https://www.linkedin.com/in/deenanath-yadav-495110146)  
- **Email**: [deenanathyadav106@gmail.com](mailto:deenanathyadav106@gmail.com)

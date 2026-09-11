# Windows Intranet Zones Automation (IaC)

A production-ready infrastructure-as-code solution to automate Windows Security Zone configurations on client workstations. This project eliminates annoying and workflow-blocking Windows Security Warnings (*"Opening these files might be harmful to your computer"*) when users access corporate file shares (SMB/NAS).

## Business Problem & Context
In enterprise environments, users often work with files hosted on internal network-attached storage (NAS) or file servers. By default, modern Windows installations treat raw IP-based network shares (e.g., `\\192.168.1.252\shares`) as untrusted untrusted Internet environments.

**Impact:** 
* Users are interrupted by security prompts every time they open documents, spreadsheets, or scripts.
* Decreased operational velocity and increased IT support ticket volume.
* Automated startup scripts hosted on network drives fail silently.

**Solution:** This repository automates the injection of specific internal subnets and server identities into the **Local Intranet Zone (Zone 1)** using PowerShell and Ansible.

## Architecture & Tech Stack
* **Target OS:** Windows 10 / Windows 11 / Windows Server
* **Configuration Management:** Ansible (for fleet-wide deployment)
* **Automation Engine:** PowerShell Core / Windows PowerShell v5.1+
* **Mechanism:** Registry Manipulation via `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap`

## Deployment & Usage

### Option 1: Standalone Execution (PowerShell)
To apply the fix on a single machine local-style, execute the script with administrative privileges or under the targeted user context:

```bash
# Clone the repository
git clone https://github.com
cd windows-intranet-whitelist/scripts/

# Execute the script specifying your corporate server IP
powershell.exe -ExecutionPolicy Bypass -File .\Add-IntranetZone.ps1 -TargetAddress "192.168.1.252"
```

### Option 2: Enterprise Fleet Deployment (Ansible)
To roll out the configuration across hundreds of office workstations:

1. Update your inventory file with target hosts.
2. Run the playbook:
```bash
ansible-playbook -i inventory.ini playbooks/configure_intranet_zones.yml
```

## Verification & Healthcheck

To verify that the configuration was applied successfully without opening the GUI Control Panel, execute the following validation command in PowerShell:

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\192.168.1.252" -Name "file"
```

**Expected Output:**
```text
file         : 1
PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\...
PSChildName  : 192.168.1.252
```
*(Value `1` explicitly confirms that the server is mapped to the Local Intranet Zone).*

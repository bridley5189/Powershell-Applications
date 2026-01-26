# Remediate-WindowsUpdate

## Synopsis
Remediates Windows Update configuration and service issues to restore compliance.

## Description
This script restarts the Windows Update service, clears the update cache, and re-enables automatic updates. It's used as an Intune Proactive Remediation remediation script to automatically fix Windows Update problems detected by the corresponding detection script.

## Requirements
- Windows 7 or later
- PowerShell 3.0+
- Administrator access required
- Service must be stoppable

## Parameters
None

## Usage
```powershell
# Basic remediation (requires admin)
./Remediate-WindowsUpdate.ps1

# In Intune Proactive Remediation
# - Add as Remediation script
# - Runs if Detection exits with 1 (non-compliant)
# - Should exit 0 on success
```

## Exit Codes
- `0` Remediation successful; Windows Update restored
- `1` Remediation failed (review logs for details)

## Examples
```powershell
./Remediate-WindowsUpdate.ps1
# Output: Restarts services, clears cache, re-enables updates; exits 0 on success
```

## Notes
- Requires administrator privileges
- May restart services; can impact running tasks
- Run outside business hours if needed
- Pair with `Detect-WindowsUpdate.ps1` for full compliance check

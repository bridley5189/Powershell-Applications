# Detect-WindowsUpdate

## Synopsis
Detects if Windows Update is configured and running properly on the system.

## Description
This script checks Windows Update configuration, service status, and recent update history. It's commonly used as an Intune Proactive Remediation detection script to verify that Windows Update is operational.

## Requirements
- Windows 7 or later
- PowerShell 3.0+
- Administrator access recommended

## Parameters
None

## Usage
```powershell
# Basic detection
./Detect-WindowsUpdate.ps1

# In Intune Proactive Remediation
# - Add as Detection script
# - Exit code 0 = compliant (updates healthy)
# - Exit code 1 = non-compliant (needs remediation)
```

## Exit Codes
- `0` Windows Update is healthy and compliant
- `1` Windows Update is misconfigured or service not running (remediation needed)

## Examples
```powershell
./Detect-WindowsUpdate.ps1
# Output: Writes detailed status; exits 0 if healthy, 1 if not
```

## Notes
- Pair with `Remediate-WindowsUpdate.ps1` for auto-remediation
- Monitor Service status: `wuauserv` (Windows Update)
- Check Group Policy if script consistently reports non-compliance

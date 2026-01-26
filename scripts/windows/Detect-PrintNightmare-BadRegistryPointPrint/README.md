# Detect-PrintNightmare-BadRegistryPointPrint

## Synopsis
Detects if the PrintNightmare vulnerability mitigation registry setting is properly configured.

## Description
Checks for the CVE-2021-1675 / CVE-2021-34527 (PrintNightmare) mitigation registry key. This script verifies that the Point and Print restriction registry value is set correctly to prevent unauthorized printer installations and print spooler exploitation.

## Requirements
- Windows 10 or later (or Windows Server 2019+)
- PowerShell 3.0+
- Administrator access recommended

## Parameters
None

## Usage
```powershell
# Basic detection
./Detect-PrintNightmare-BadRegistryPointPrint.ps1

# In Intune Proactive Remediation
# - Exit code 0 = registry correctly configured (no vulnerability)
# - Exit code 1 = registry misconfigured (vulnerable, needs remediation)
```

## Exit Codes
- `0` PrintNightmare mitigation registry setting is properly configured
- `1` Registry not configured or incorrectly set (system is vulnerable)

## Examples
```powershell
./Detect-PrintNightmare-BadRegistryPointPrint.ps1
# Output: Checks registry; exits 0 if secure, 1 if vulnerable
```

## Registry Key Checked
```
HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint
Name: Restricted
Value: 1 (enabled) = secure
```

## Notes
- Part of PrintNightmare (CVE-2021-1675) remediation
- Requires Windows KB5004945 or later for full patch
- Can pair with remediation script to automatically configure registry
- Monitor using Intune Proactive Remediation for enterprise compliance

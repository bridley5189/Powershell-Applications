# Remediate-WindowsUpdate

## Synopsis

Remediates Windows Update issues by restarting services and installing pending updates.

## Description

This script is the remediation companion to `Detect-WindowsUpdate.ps1`. It attempts to fix Windows Update problems by:

- Restarting the Windows Update service (wuauserv)
- Installing targeted critical updates
- Clearing Software Distribution folders if necessary
- Logging remediation actions for monitoring

Used in Intune Proactive Remediation to automatically fix Windows Update issues detected by the detection script.

## Requirements

- Windows 10 21H1 or later
- PowerShell 5.1+
- Administrator privileges (required)
- Windows Update service available

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `DebugMode` | `bool` | `$false` | Enable debug mode for verbose logging |

## Usage

```powershell
# Basic remediation
./Remediate-WindowsUpdate.ps1

# With debug mode enabled
./Remediate-WindowsUpdate.ps1 -DebugMode $true

# In Intune Proactive Remediation
# - Add as Remediation script
# - Runs only when Detect-WindowsUpdate.ps1 exits with code 1
# - Exit code 0 = remediation successful
# - Exit code 1 = remediation failed
```

## Exit Codes

- `0` Windows Update issues successfully remediated
- `1` Remediation failed or errors encountered

## Examples

```powershell
# Run remediation with debugging
./Remediate-WindowsUpdate.ps1 -DebugMode $true

# Standard Intune deployment
# Detection: Detect-WindowsUpdate.ps1
# Remediation: Remediate-WindowsUpdate.ps1
```

## Remediation Levels

The script uses escalating remediation levels:

1. **Level 1** - Install targeted critical updates
2. **Level 2** - Restart Windows Update service
3. **Level 3** - Clear Software Distribution folders (TBC)

## Registry Flags

The script uses registry keys to track remediation attempts:

- Path: `HKLM:\SOFTWARE\Deploy\ProActiveRemediation`
- `WURemediationDate` - Timestamp of last remediation
- `WURemediationLevel` - Level of last remediation attempt
- Cooldown period: 7 days between attempts

## Notes

- **Requires Administrator rights** to restart services and install updates
- Pair with `Detect-WindowsUpdate.ps1` for complete detection/remediation workflow
- Monitor remediation cooldown to avoid excessive service restarts
- Log Analytics integration available (requires Workspace ID and Shared Key configuration)
- May trigger system reboot if critical updates are installed
- Review remediation flags in registry for troubleshooting

## Configuration

To enable Log Analytics logging, update these variables in the script:

```powershell
$LogAnalyticsWorkspaceID = "<Your Workspace ID>"
$LogAnalyticsSharedKey = "<Your Shared Key>"
```

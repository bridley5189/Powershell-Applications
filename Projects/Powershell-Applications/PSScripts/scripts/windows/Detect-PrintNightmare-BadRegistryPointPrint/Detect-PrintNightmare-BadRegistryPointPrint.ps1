<#
.SYNOPSIS
Detects if the PrintNightmare vulnerability mitigation registry setting is properly configured.

.DESCRIPTION
Checks for the CVE-2021-1675 / CVE-2021-34527 (PrintNightmare) mitigation registry key.
This script verifies that the Point and Print restriction registry value is set correctly 
to prevent unauthorized printer installations and print spooler exploitation.

This script is designed for use with Intune Proactive Remediation.
- Exit code 0 = registry correctly configured (compliant)
- Exit code 1 = registry misconfigured or missing (non-compliant, needs remediation)

.NOTES
Created for: Intune Proactive Remediation
Requires: Windows 10 or later
Purpose: Detect PrintNightmare vulnerability mitigation status

.EXAMPLE
.\Detect-PrintNightmare-BadRegistryPointPrint.ps1
Checks the registry and exits with appropriate code.

#>

[CmdletBinding()]
param()

try {
    # Define the registry path and value for PrintNightmare mitigation
    $RegPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
    $RegName = "RestrictDriverInstallationToAdministrators"
    $ExpectedValue = 1
    
    # Check if the registry path exists
    if (Test-Path $RegPath) {
        # Get the registry value
        $RegValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        
        if ($null -ne $RegValue) {
            # Check if the value matches the expected secure setting
            if ($RegValue.$RegName -eq $ExpectedValue) {
                Write-Output "PrintNightmare mitigation is properly configured. RestrictDriverInstallationToAdministrators = $ExpectedValue"
                exit 0
            }
            else {
                Write-Output "PrintNightmare mitigation is NOT properly configured. RestrictDriverInstallationToAdministrators = $($RegValue.$RegName), expected $ExpectedValue"
                exit 1
            }
        }
        else {
            Write-Output "PrintNightmare mitigation registry value 'RestrictDriverInstallationToAdministrators' not found"
            exit 1
        }
    }
    else {
        Write-Output "PrintNightmare mitigation registry path does not exist: $RegPath"
        exit 1
    }
}
catch {
    Write-Output "Error checking PrintNightmare mitigation: $($_.Exception.Message)"
    exit 1
}

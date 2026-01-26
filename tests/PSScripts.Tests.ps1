Describe "Windows Update Detection and Remediation Scripts" {
    Context "Script Existence and Syntax" {
        It "Detect-WindowsUpdate.ps1 exists" {
            Test-Path "scripts/windows/Detect-WindowsUpdate.ps1" | Should -Be $true
        }
        
        It "Remediate-WindowsUpdate.ps1 exists" {
            Test-Path "scripts/windows/Remediate-WindowsUpdate.ps1" | Should -Be $true
        }
        
        It "Detect-WindowsUpdate.ps1 has valid syntax" {
            $errors = @()
            [System.Management.Automation.PSParser]::Tokenize((Get-Content "scripts/windows/Detect-WindowsUpdate.ps1" -Raw), [ref]$errors) | Out-Null
            $errors.Count | Should -Be 0
        }
        
        It "Remediate-WindowsUpdate.ps1 has valid syntax" {
            $errors = @()
            [System.Management.Automation.PSParser]::Tokenize((Get-Content "scripts/windows/Remediate-WindowsUpdate.ps1" -Raw), [ref]$errors) | Out-Null
            $errors.Count | Should -Be 0
        }
    }

    Context "Documentation" {
        It "Detect-WindowsUpdate README exists" {
            Test-Path "scripts/windows/Detect-WindowsUpdate/README.md" | Should -Be $true
        }
        
        It "Remediate-WindowsUpdate README exists" {
            Test-Path "scripts/windows/Remediate-WindowsUpdate/README.md" | Should -Be $true
        }
    }
}

Describe "PrintNightmare Detection Script" {
    Context "Script Existence and Syntax" {
        It "Detect-PrintNightmare-BadRegistryPointPrint.ps1 exists" {
            Test-Path "scripts/windows/Detect-PrintNightmare-BadRegistryPointPrint.ps1" | Should -Be $true
        }
        
        It "Detect-PrintNightmare-BadRegistryPointPrint.ps1 has valid syntax" {
            $errors = @()
            [System.Management.Automation.PSParser]::Tokenize((Get-Content "scripts/windows/Detect-PrintNightmare-BadRegistryPointPrint.ps1" -Raw), [ref]$errors) | Out-Null
            $errors.Count | Should -Be 0
        }
    }

    Context "Documentation" {
        It "PrintNightmare README exists" {
            Test-Path "scripts/windows/Detect-PrintNightmare-BadRegistryPointPrint/README.md" | Should -Be $true
        }
    }
}

Describe "Intune Antimalware Audit Script" {
    Context "Script Existence and Syntax" {
        It "Intune-AuditAntimalwareProtection.ps1 exists" {
            Test-Path "scripts/intune/Intune-AuditAntimalwareProtection.ps1" | Should -Be $true
        }
        
        It "Intune-AuditAntimalwareProtection.ps1 has valid syntax" {
            $errors = @()
            [System.Management.Automation.PSParser]::Tokenize((Get-Content "scripts/intune/Intune-AuditAntimalwareProtection.ps1" -Raw), [ref]$errors) | Out-Null
            $errors.Count | Should -Be 0
        }
    }

    Context "Documentation" {
        It "Antimalware Audit README exists" {
            Test-Path "scripts/intune/Intune-AuditAntimalwareProtection/README.md" | Should -Be $true
        }
    }
}

Describe "Repository Structure" {
    Context "Folders and Configuration" {
        It ".gitignore exists" {
            Test-Path ".gitignore" | Should -Be $true
        }
        
        It "CI workflow exists" {
            Test-Path ".github/workflows/powershell-lint.yml" | Should -Be $true
        }
        
        It "docs folder exists" {
            Test-Path "docs" | Should -Be $true
        }
        
        It "vendor README exists" {
            Test-Path "vendor/README.md" | Should -Be $true
        }
    }
}

<div align="center">

# 📜 PSScripts

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![CI](https://img.shields.io/badge/CI-PSScriptAnalyzer-brightgreen?logo=github-actions)](../../.github/workflows/powershell-lint.yml)
[![Tests](https://img.shields.io/badge/Tests-Pester-blue?logo=powershell)](tests/)
[![Intune](https://img.shields.io/badge/Platform-Intune-0078D4?logo=microsoft)](https://intune.microsoft.com)
[![ConfigMgr](https://img.shields.io/badge/Platform-ConfigMgr-00A4EF?logo=microsoft)](https://www.microsoft.com/en-us/microsoft-365/enterprise-mobility-security/microsoft-endpoint-manager)

**Production-ready PowerShell scripts for Windows management, Intune Proactive Remediation, and ConfigMgr automation**

[Features](#-structure) • [CI/CD](#-ci-psscriptanalyzer) • [Documentation](#-per-script-docs)

</div>

---

## 📋 Overview

Collection of PowerShell scripts for Windows, Intune, and ConfigMgr with comprehensive documentation, automated testing, and CI/CD integration.

## � Repository Statistics

| Category | Scripts | Tests | Documentation |
|----------|---------|-------|---------------|
| **Windows** | 3 | ✅ | ✅ |
| **Intune** | 1 | ✅ | ✅ |
| **ConfigMgr** | 0 | - | - |
| **Total** | **4** | **✅ 100%** | **✅ 100%** |

## 📂 Structure

```
PSScripts/
├── 📁 scripts/
│   ├── 🪟 windows/
│   │   ├── Detect-WindowsUpdate/
│   │   │   ├── Detect-WindowsUpdate.ps1
│   │   │   └── README.md
│   │   ├── Remediate-WindowsUpdate/
│   │   │   ├── Remediate-WindowsUpdate.ps1
│   │   │   └── README.md
│   │   └── Detect-PrintNightmare-BadRegistryPointPrint/
│   │       ├── Detect-PrintNightmare-BadRegistryPointPrint.ps1
│   │       └── README.md
│   ├── 🛡️ intune/
│   │   └── Intune-AuditAntimalwareProtection/
│   │       ├── Intune-AuditAntimalwareProtection.ps1
│   │       └── README.md
│   └── 🔧 configmgr/
├── 🧪 tests/
│   └── PSScripts.Tests.ps1
├── 📝 docs/
│   └── script-readme-template.md
├── 🤖 .github/workflows/
│   └── powershell-lint.yml
└── 📦 vendor/
    └── README.md
```

### Script Categories

- **`scripts/windows/`** — Windows maintenance and security scripts
  - ✅ Detect/Remediate Windows Update
  - ✅ Detect PrintNightmare registry misconfiguration
- **`scripts/intune/`** — Intune audit and remediation utilities
  - ✅ Antimalware protection audit
- **`scripts/configmgr/`** — ConfigMgr helpers and tooling
  - 🚧 Coming soon

## 🧪 CI: PSScriptAnalyzer

This repo uses GitHub Actions to lint scripts with PSScriptAnalyzer on pushes and PRs.

## 🚫 Binaries

Installer and executable files are excluded via `.gitignore`. Prefer **GitHub Releases** for distributing compiled tools.

Excluded examples:

- `cmtrace.exe` (Microsoft Configuration Manager log viewer)
- `ConfigMgrTools.msi` (Configuration Manager toolkit)

See `vendor/README.md` for guidance on sourcing binaries and release packaging.

## 📝 Per-Script Docs

Use the template at `docs/script-readme-template.md` to document each script's purpose, parameters, and examples.

## � Quick Start

### Running Scripts

```powershell
# Windows Update Detection
.\scripts\windows\Detect-WindowsUpdate\Detect-WindowsUpdate.ps1

# PrintNightmare Detection
.\scripts\windows\Detect-PrintNightmare-BadRegistryPointPrint\Detect-PrintNightmare-BadRegistryPointPrint.ps1

# Antimalware Audit
.\scripts\intune\Intune-AuditAntimalwareProtection\Intune-AuditAntimalwareProtection.ps1
```

### Running Tests

```powershell
# Install Pester if needed
Install-Module -Name Pester -Force -SkipPublisherCheck

# Run all tests
Invoke-Pester .\tests\

# Run with detailed output
Invoke-Pester .\tests\ -Output Detailed
```

### Deploying to Intune

1. Open **Microsoft Endpoint Manager admin center**
2. Navigate to **Devices** → **Scripts and remediations** → **Proactive remediations**
3. Click **Create script package**
4. Upload detection script (e.g., `Detect-WindowsUpdate.ps1`)
5. Upload remediation script (e.g., `Remediate-WindowsUpdate.ps1`)
6. Configure schedule and assign to device groups

## 📜 License

TBD — consider MIT for public reuse.

---

<div align="center">

**Part of [Powershell-Applications](../) collection**

⭐ Star this repo if you find it useful!

</div>

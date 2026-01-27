<div align="center">

# ⚡ PowerShell Applications

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![GitHub Stars](https://img.shields.io/github/stars/bridley5189/Powershell-Applications?style=social)](https://github.com/bridley5189/Powershell-Applications/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/bridley5189/Powershell-Applications?style=social)](https://github.com/bridley5189/Powershell-Applications/network/members)

**Collection of professional PowerShell tools and utilities for system administration, monitoring, and automation**

[Features](#-highlights) • [Quick Start](#-quick-starts) • [Documentation](#-root-folders) • [Contributing](#-contributing)

</div>

---

> ⚠️ **Development Mode** — All tools in this repository are currently in **testing and development**. Features may change, and stability is not guaranteed. Use at your own risk in production environments.

## � Table of Contents

- [Root Folders](#-root-folders)
  - [📂 Log_Reader](#-log_reader)
  - [🎯 PS Demo](#-ps-demo)
  - [📜 PSScripts](#-psscripts)
- [✨ Highlights](#-highlights)
- [🚀 Quick Starts](#-quick-starts)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## �📁 Root Folders

### 📂 Log_Reader
Live Windows log reader with real-time monitoring, color-coded output, and both console and GUI interfaces.
- 🧾 **README.md** — Detailed features and usage.
- 🧪 **LogReader.ps1** — Console-based live log tail with filters.
- 🖥️ **LogReaderGUI.ps1** — GUI-based reader with start/stop, filtering, and clear controls.
- 🎛️ **LogReaderOption1.ps1** — Structured table view (LogViewPlus style) with detail pane and level filter.
- 🟨 **LogReaderOption2.ps1** — High-contrast striped view (BareTail style) with follow-tail and level toggles.
- 🌙 **LogReaderOption3.ps1** — Dark terminal-style view with neon accents and token colorization.

→ [Full docs](Log_Reader/README.md)

---

### 🎯 PS Demo
Professional PowerShell Script Runner GUI application for managing and executing PowerShell scripts with advanced features.
- 🧾 **README.md** — Full feature documentation and getting started guide.
- 🖥️ **PowerShell-Script-Runner.ps1** — Main application (GUI-based script manager).
- 🔧 **PowerShell-Script-Runner.exe** — Compiled executable (no PowerShell console required).
- 📋 **ENHANCEMENTS_IMPLEMENTED.md** — List of all 14+ UI/UX enhancements.
- 🎨 **PowerShell-Script-Runner.vbs** & **.bat** — Alternative launchers.
- ⚙️ **.vscode/** — Launch configuration for development.

**Key Features:**
- 🔎 Script browsing, filtering, and execution (user or admin mode)
- 📊 Execution statistics, history, and real-time monitoring
- ✏️ Built-in code editor with syntax highlighting
- 🎨 Dark/Light theme toggle with resizable panels
- ⌨️ Keyboard shortcuts: `Ctrl+R` (run), `Ctrl+E` (edit), `Ctrl+F` (find)
- 🤖 AI Assistant integration (OpenAI) for script analysis and generation
- ⏰ Script scheduler with toast notifications
- 🧹 Pre-execution syntax validation

→ [Full docs](PS%20Demo/README.md)

---

### 📜 PSScripts
Collection of PowerShell scripts for Windows, Intune, and ConfigMgr with comprehensive documentation and CI/CD integration.
- 🧾 **README.md** — Overview of script categories and structure.
- 🪟 **scripts/windows/** — Windows maintenance and security scripts (Windows Update, PrintNightmare detection).
- 🛡️ **scripts/intune/** — Intune audit and remediation utilities (Antimalware protection audit).
- 🔧 **scripts/configmgr/** — ConfigMgr helpers and tooling.
- 🧪 **tests/** — Pester test suite for validation.
- 🤖 **.github/workflows/** — PSScriptAnalyzer CI for automated linting.
- 📝 **docs/** — Script README template for consistent documentation.

**Key Features:**
- 🔍 Intune Proactive Remediation scripts for Windows Update and security vulnerabilities
- 📋 Per-script documentation following standardized template
- ✅ Automated testing with Pester and PSScriptAnalyzer
- 🚀 CI/CD pipeline with GitHub Actions
- 📦 Proper binary handling (excluded from repo, distributed via Releases)

→ [Full docs](PSScripts/README.md)

---

## ✨ Highlights

### Log_Reader
- 🔎 Real-time log monitoring without locking files
- 🎨 Color coding for `ERROR`, `WARN`, `INFO`, and more
- 🧰 Multiple UIs: console, GUI, and themed options
- 🧩 Handles log rotation and large files gracefully

### PS Demo
- 🎯 Centralized script management and execution GUI
- 📊 Execution metrics: success rate, average duration, last run time
- ✏️ Integrated syntax checker and code editor
- 🤖 AI-powered script analysis and generation
- ⏰ Schedule scripts with Windows notifications
- 🎨 Professional dark/light themes with modern styling

### PSScripts
- 🔍 Production-ready Intune Proactive Remediation scripts
- 🛡️ Windows Update detection and remediation automation
- 🔒 PrintNightmare vulnerability detection
- 📊 Antimalware protection auditing
- ✅ Automated testing and linting with CI/CD pipeline
- 📖 Comprehensive per-script documentation

## 🚀 Quick Starts

### Log_Reader (GUI)
```powershell
cd .\Log_Reader
./LogReaderGUI.ps1
```

### Log_Reader (Console)
```powershell
cd .\Log_Reader
./LogReader.ps1 -LogPath "C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\AgentExecutor.log" -FilterText "error"
```

### PS Demo (GUI Application)
```powershell
cd ".\PS Demo"
./PowerShell-Script-Runner.ps1
# OR use the compiled executable:
./PowerShell-Script-Runner.exe
```

### PSScripts (Intune Proactive Remediation)
```powershell
cd .\PSScripts

# Test Windows Update detection
./scripts/windows/Detect-WindowsUpdate/Detect-WindowsUpdate.ps1

# Run PrintNightmare detection
./scripts/windows/Detect-PrintNightmare-BadRegistryPointPrint/Detect-PrintNightmare-BadRegistryPointPrint.ps1

# Run tests
Invoke-Pester ./tests/
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by [bridley5189](https://github.com/bridley5189)**

⭐ Star this repo if you find it useful!

</div>

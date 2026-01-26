# PSScripts

Collection of PowerShell scripts for Windows, Intune, and ConfigMgr.

## 📂 Structure
- `scripts/windows/` — Windows maintenance and security scripts
	- Detect/Remediate Windows Update
	- Detect PrintNightmare registry misconfiguration
- `scripts/intune/` — Intune audit and remediation utilities
	- Antimalware protection audit
- `scripts/configmgr/` — ConfigMgr helpers and tooling

## 🧪 CI: PSScriptAnalyzer
This repo uses GitHub Actions to lint scripts with PSScriptAnalyzer on pushes and PRs.

## 🚫 Binaries
Installer and executable files are excluded via `.gitignore`. Prefer GitHub Releases for distributing compiled tools.

## 📝 Per-Script Docs
Use the template at `docs/script-readme-template.md` to document each script's purpose, parameters, and examples.

## 📜 License
TBD — consider MIT for public reuse.

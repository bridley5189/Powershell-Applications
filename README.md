# Powershell-Applications
## ⚡ PowerShell Applications

Collection of small, focused PowerShell tools and utilities.

## 📁 Root Folders

- 📂 **Log_Reader** — Live Windows log reader with real-time monitoring, color-coded output, and both console and GUI interfaces.
	- 🧾 **README.md** — Detailed features and usage.
	- 🧪 **LogReader.ps1** — Console-based live log tail with filters.
	- 🖥️ **LogReaderGUI.ps1** — GUI-based reader with start/stop, filtering, and clear controls.
	- 🎛️ **LogReaderOption1.ps1** — Structured table view (LogViewPlus style) with detail pane and level filter.
	- 🟨 **LogReaderOption2.ps1** — High-contrast striped view (BareTail style) with follow-tail and level toggles.
	- 🌙 **LogReaderOption3.ps1** — Dark terminal-style view with neon accents and token colorization.

For full details and usage examples, see: [Log_Reader/README.md](Log_Reader/README.md)

---

## ✨ Highlights
- 🔎 Real-time log monitoring without locking files
- 🎨 Color coding for `ERROR`, `WARN`, `INFO`, and more
- 🧰 Multiple UIs: console, GUI, and themed options
- 🧩 Handles log rotation and large files gracefully

## 🚀 Quick Start (GUI)
```powershell
cd .\Log_Reader
./LogReaderGUI.ps1
```

## 🧪 Quick Start (Console)
```powershell
cd .\Log_Reader
./LogReader.ps1 -LogPath "C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\AgentExecutor.log" -FilterText "error"
```

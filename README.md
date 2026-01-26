# Powershell-Applications
## ⚡ PowerShell Applications

Collection of small, focused PowerShell tools and utilities.

> ⚠️ **Development Mode** — All tools in this repository are currently in **testing and development**. Features may change, and stability is not guaranteed. Use at your own risk in production environments.

## 📁 Root Folders

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

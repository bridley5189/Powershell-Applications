# PowerShell Script Runner - Professional Edition

A professional-grade Windows desktop application for managing and executing PowerShell scripts from selected folders. Built with Windows Forms for a robust, feature-rich solution without external dependencies.

**Created by Bill Ridley**

## Overview

PowerShell Script Runner is a comprehensive GUI application designed for system administrators, developers, and power users who need a centralized way to organize, manage, and execute PowerShell scripts. The application provides an intuitive interface to browse, preview, edit, and run scripts with real-time monitoring and execution control.

## Core Features

### Script Management
- **Folder Browser**: Browse and select folders containing PowerShell scripts (.ps1 files)
- **Script Scanner**: Automatically scans and displays all .ps1 files with metadata (name, file size)
- **Search & Filter**: Real-time filtering to quickly find scripts by name
- **Script History**: Maintains a list of 15 most recent scripts for quick access
- **Clear History**: One-click history clearing functionality

### Script Execution & Control
- **Dual Execution Modes**: Run scripts as current user or with administrator privileges (UAC)
- **Stop Script Button**: Terminate running scripts immediately at any time
- **Execution Monitoring**: Live timer tracking elapsed execution time
- **Real-time Output**: Terminal output display with color support and timestamps
- **Process Management**: Proper process handling and cleanup

### Code Viewing & Editing
- **Script Code Viewer**: Display the full PowerShell code of selected scripts
- **Code Editor**: Edit script code directly within the application
- **Save Changes**: Modify and save scripts without external editors
- **Copy Code**: Copy entire script content to clipboard
- **Syntax Highlighting**: Color-coded display for better readability

### User Experience
- **Responsive Design**: Resizable GUI that adapts to different screen sizes and resolutions
- **Dark/Light Mode**: Toggle between professional dark and light themes with color schemes
- **Settings Persistence**: Auto-saves window size, position, theme preference, and last folder
- **Modern UI**: Clean, intuitive interface with professional styling and colors
- **Status Monitoring**: Real-time script execution status and file path display
- **Spinner Animation**: Visual feedback during script execution
- **Output Management**: Clear terminal output with single button click

## System Requirements

- **Operating System**: Windows 7 or later (Windows 10/11 recommended)
- **PowerShell**: Version 5.0 or later (Windows PowerShell 5.1 or PowerShell Core 7+)
- **.NET Framework**: Version 4.5 or later (typically pre-installed on Windows)
- **Administrator Access**: Required only for running scripts with elevated privileges

## Installation & Getting Started

No installation required! Choose your preferred launch method:

### Method 1: Run the PowerShell Script
```powershell
.\PowerShell-Script-Runner.ps1
```

### Method 2: Run with Execution Policy Override
```powershell
powershell -ExecutionPolicy Bypass -File "PowerShell-Script-Runner.ps1"
```

### Method 3: Use the Compiled Executable (Recommended for Distribution)
```batch
.\PowerShell-Script-Runner.exe
```

### Method 4: Use the Batch Launcher
```batch
PowerShell-Script-Runner.bat
```

### Setting Execution Policy (Optional)
If you encounter execution policy restrictions, run this command in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -CurrentUser
```

## How to Use the Application

### Step 1: Launch the Application
Choose one of the installation methods above to launch the application.

### Step 2: Select a Script Folder
1. Click the **Browse...** button in the top panel
2. Select a folder containing your PowerShell scripts (.ps1 files)
3. The folder path will be displayed in the text field

### Step 3: Browse and Search Scripts
- Scripts are automatically displayed in the left panel with name and file size
- Use the **Search** box to filter scripts by name in real-time
- Click a script to view its full code in the code viewer panel

### Step 4: View Script Code
- Selected script code is displayed in the **Script Code Viewer** panel
- Use **Edit Code** button to modify the script directly
- Click **Copy Code** to copy the entire script to clipboard
- Click **Save Code** to save modifications to the file

### Step 5: Execute Scripts
- **Run Button**: Execute script with current user privileges
- **Admin Button**: Execute script with administrator privileges (UAC prompt)
- **Stop Button**: Terminate currently running script

### Step 6: Monitor Execution
- Watch **Terminal Output** panel for real-time script output
- View **Status Bar** for execution timer and completion status
- Script path and execution details are displayed throughout execution

### Step 7: Access Recent Scripts
- View your 15 most recent scripts in the **Recent Scripts** panel
- Double-click any recent script to run it immediately
- Click **Clear History** to reset the history list

### Step 8: Customize Your Experience
- Click the **Light/Dark** button to toggle between themes
- Window size, position, and preferences are automatically saved
- Settings persist across application sessions

## Examples

### Example 1: Run a System Information Script
```powershell
# Create a test script
"Get-ComputerInfo | Format-List" | Out-File test-info.ps1

# 1. Launch PowerShell Script Runner
# 2. Click Browse and select the folder containing test-info.ps1
# 3. Select test-info.ps1 from the list
# 4. Review the code in the viewer
# 5. Click "Run" to execute and see system information
```

### Example 2: Edit and Run a User Script
```powershell
# Create a custom script
@"
Write-Host "Hello from PowerShell!" -ForegroundColor Green
Get-Date
"@ | Out-File my-script.ps1

# 1. Launch PowerShell Script Runner
# 2. Browse to the folder with my-script.ps1
# 3. Select my-script.ps1
# 4. Click "Edit Code" to modify it
# 5. Make changes and click "Save Code"
# 6. Click "Run" to execute the updated script
```

### Example 3: Run with Administrator Privileges
```powershell
# Any script requiring admin access
# 1. Select the script from the list
# 2. Click "Admin" button
# 3. Windows UAC prompt will appear - click "Yes"
# 4. Script runs with elevated privileges
# 5. View output in Terminal Output panel
```

### Example 4: Manage Script History
```powershell
# Scripts are automatically tracked:
# - Run 5 different scripts
# - They appear in "Recent Scripts" list
# - Double-click any recent script to run it instantly
# - View execution details in Terminal Output
# - Click "Clear History" to reset when needed
```

## Application Layout

### Top Panel
- **Repository Label & Path Field**: Displays currently selected folder path
- **Browse Button**: Open folder browser dialog
- **Refresh Button**: Reload scripts from current folder
- **Light/Dark Button**: Toggle between light and dark themes

### Left Panel
- **PowerShell Scripts Label**: Section header
- **Search Box**: Real-time script filtering
- **Scripts ListView**: List of all .ps1 files with name and size columns
- **Run Button**: Execute selected script as current user
- **Admin Button**: Execute selected script with administrator privileges
- **Stop Button**: Terminate currently running script
- **Recent Scripts Section**: 
  - History of 15 most recent scripts
  - Double-click to run
  - Clear History button to reset

### Right Panel - Code Viewer Section
- **Script Code Viewer Header**: Section label
- **Edit Code Button**: Switch to edit mode
- **Save Code Button**: Save modifications to file
- **Copy Code Button**: Copy entire script to clipboard
- **Code Display Area**: Syntax-highlighted script content

### Right Panel - Terminal Section
- **Terminal Output Header**: Section label
- **Output Display**: Real-time script execution output with color support
- **Clear Output Button**: Clear terminal display

### Status Bar
- **Status Label**: Current execution status and timer
- **Progress Bar**: Optional progress indication
- **Path Label**: Full path of selected script
- **Creator Attribution**: "Created by Bill Ridley"

## Security & Best Practices

### Administrator Privileges
- Scripts run as admin will prompt for Windows UAC confirmation
- Only grant admin privileges when necessary
- Review script code before running with elevated access

### Script Safety
- **Always review script code** before execution
- Only run scripts from **trusted sources**
- Verify script behavior in the code viewer before running
- Test scripts on non-critical systems first if unsure

### Execution Policy
- Ensure appropriate PowerShell execution policy is configured
- User-level policy settings won't affect system-wide policies
- Administrator privileges may be needed to change machine-wide policies

### Settings Storage
- User preferences stored in: `%APPDATA%\PowerShellScriptRunner\settings.json`
- Settings include: theme, window size/position, last folder path
- Each user account maintains separate settings
- Settings directory created automatically on first run

## File Structure

```
PowerShell Script Runner/
├── PowerShell-Script-Runner.ps1          # Main application (918 lines, 41 KB)
├── PowerShell-Script-Runner.exe          # Compiled executable (4.5 KB)
├── PowerShell-Script-Runner.bat          # Batch launcher (400 bytes)
├── PowerShell-Script-Runner.vbs          # VBScript launcher (589 bytes)
├── README.md                              # Main documentation
├── README-EXE-CREATION.md                # Executable creation guide
└── [User Scripts]                        # Your PowerShell scripts (.ps1 files)
```

## Deployment Options

### Single User
1. Copy `PowerShell-Script-Runner.ps1` to desired location
2. Run directly or create shortcut

### Network Distribution
1. Share both files on network drive:
   - `PowerShell-Script-Runner.exe` (no console window)
   - `PowerShell-Script-Runner.ps1` (required)
2. Create shortcut pointing to .exe
3. Users can run without PowerShell knowledge

### Enterprise Deployment
- Copy files to shared network location
- Create Group Policy shortcuts
- No installation required
- Updates replace PS1 file only

## Troubleshooting Guide

### Application Won't Launch

**"PowerShell-Script-Runner.ps1 is not digitally signed"**
```powershell
# Fix: Bypass execution policy
powershell -ExecutionPolicy Bypass -File "PowerShell-Script-Runner.ps1"

# Or set policy permanently
Set-ExecutionPolicy RemoteSigned -CurrentUser
```

**"Cannot find System.Windows.Forms"**
- Ensure .NET Framework 4.5+ is installed
- Check PowerShell version: `$PSVersionTable.PSVersion`
- Install .NET Framework from Microsoft if needed

**"GUI displays but doesn't respond"**
- Check Windows User Account Control settings
- Verify you have display driver support
- Try running as Administrator

### Script Execution Issues

**"Script won't run or produces no output"**
1. Select the script again
2. Check the code viewer for syntax errors
3. Try running a simple test script first
4. Review Terminal Output for error messages

**"Admin elevation doesn't work"**
- UAC must be enabled in Windows settings
- You must have administrator account privileges
- Check: `net user %username%` (Administrator group)

**"Script runs but output appears cut off"**
- Maximize the Terminal Output panel
- Use "Clear Output" to reset
- Some output may be truncated in live view

### Performance Issues

**"Application is slow or unresponsive"**
1. Close other applications
2. Clear history: Recent Scripts → Clear History
3. Restart the application
4. Check available disk space and RAM

**"Output updates slowly"**
- This is normal for long-running scripts
- Output updates in real-time
- Spinner animation shows script is running

### Theme & Display Issues

**"Dark mode colors look wrong"**
- Clear settings file:
  ```powershell
  Remove-Item "$env:APPDATA\PowerShellScriptRunner\settings.json"
  ```
- Restart application to regenerate defaults

**"Window doesn't resize properly"**
- Minimum window size is 1000×700
- Resize to at least this size
- Reset theme to restore default layout

### File & Folder Issues

**"Scripts don't appear in list"**
1. Verify folder contains .ps1 files
2. Click Refresh to rescan folder
3. Check file permissions (readable)
4. Ensure folder path is correct

**"Can't save edited script"**
- Verify script file is not read-only
- Check folder write permissions
- Close any other editors of the file

## Technical Specifications

### Architecture
- **Framework**: Windows Forms (.NET Framework)
- **Language**: PowerShell 5.0+
- **Execution Model**: Process-based with output redirection
- **Memory Profile**: Lightweight, minimal resource usage
- **Dependencies**: None (uses native Windows libraries)

### Performance
- **Startup Time**: < 2 seconds
- **Memory Usage**: ~50-100 MB
- **UI Responsiveness**: Smooth with real-time updates
- **Script Scaling**: Handles 100+ scripts efficiently

### Compatibility
- **Windows Versions**: Windows 7 SP1, 8, 8.1, 10, 11
- **PowerShell Versions**: 5.0, 5.1, Core 7+
- **.NET Frameworks**: 4.5, 4.6, 4.7, 4.8

## Advanced Features

### Custom Settings Management
Settings are stored as JSON in:
```
%APPDATA%\PowerShellScriptRunner\settings.json
```

Saved settings include:
- Dark mode state
- Last folder path
- Window dimensions and position
- Recent scripts history

### Command Line Integration
Launch with specific folder:
```powershell
# Not directly supported, but can be added
# Currently: manual folder selection via GUI
```

### Keyboard Shortcuts
- **Enter**: Execute selected script
- **Escape**: Cancel editing
- **Tab**: Navigate between controls

## License & Attribution

**Created by Bill Ridley**

PowerShell Script Runner is provided as-is for personal and commercial use.

### License
MIT License - Free to use, modify, and distribute.

### Disclaimer
This application executes PowerShell scripts. Users are responsible for:
- Reviewing all scripts before execution
- Ensuring scripts are from trusted sources
- Understanding script behavior and consequences
- Testing in safe environments first

## FAQ

**Q: Do I need to install anything?**
A: No! Just run the .ps1 file or .exe executable directly.

**Q: Can I run this on macOS or Linux?**
A: Not recommended. The application uses Windows Forms which is Windows-specific. However, PowerShell Core can run on macOS/Linux if you adapt the Windows Forms code.

**Q: Is there a portable version?**
A: Yes! The .exe executable is portable - copy both PowerShell-Script-Runner.exe and PowerShell-Script-Runner.ps1 to any location.

**Q: Can I edit scripts in the application?**
A: Yes! Click "Edit Code" to modify scripts and "Save Code" to persist changes.

**Q: How many scripts can it handle?**
A: Tested with 100+ scripts - performance remains smooth. No practical limit.

**Q: Can I run scripts remotely?**
A: Scripts must be accessible locally. Remote execution would require custom modifications.

**Q: Does it support PowerShell Core?**
A: Yes! Works with both Windows PowerShell 5.1 and PowerShell Core 7+.

**Q: How do I distribute this to other users?**
A: Copy both PowerShell-Script-Runner.exe and PowerShell-Script-Runner.ps1 to a network location or create an installer.

## Version History

### v1.0 - Professional Edition (Current)
- Full GUI implementation with Windows Forms
- Script execution with output capture
- Code viewer and editor
- Dark/Light theme support
- Settings persistence
- Script history tracking
- Admin elevation support
- Real-time monitoring and control
- Compiled executable option

## Getting Help

### Documentation
- Read this README.md file
- Check the PowerShell comment-based help: `Get-Help .\PowerShell-Script-Runner.ps1`
- Review script code in the code viewer

### Troubleshooting
- Check Terminal Output for error messages
- Verify script permissions and execution policy
- Ensure prerequisites are met
- Review Troubleshooting Guide above

### Contact & Support
For questions, issues, or contributions:
- Review the source code
- Check system event logs
- Verify PowerShell execution policy
- Test with simple scripts first

---

## Credits

**Application Development**: Bill Ridley

**Technologies Used**:
- PowerShell 5.0+
- .NET Framework / Windows Forms
- C# Compiler (for .exe generation)
- Windows Native APIs

**Features Implemented**:
- Advanced GUI with responsive layout
- Multi-threaded script execution
- Real-time output streaming
- Settings management and persistence
- Theme system with color schemes
- Process management and termination
- UAC integration for admin elevation
- Code editing and file management

---

**Created with ❤️ using PowerShell and Windows Forms**

**Professional Edition v1.0** - January 2026
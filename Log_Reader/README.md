# Live Windows Log Reader

A PowerShell-based live log reader with real-time monitoring capabilities for Windows log files.

## Features

- **Real-time monitoring**: Automatically detects and displays new log entries as they're written
- **Color-coded output**: Different colors for errors, warnings, info, and success messages
- **Text filtering**: Filter log entries by keyword
- **Multiple interfaces**: Console and GUI versions available
- **Log rotation handling**: Automatically detects when logs are rotated or truncated
- **No file locks**: Reads files without locking them, allowing other processes to write

## Files

- **LogReader.ps1**: Console-based log reader
- **LogReaderGUI.ps1**: GUI-based log reader with rich interface

## Usage

### Console Version

```powershell
# Basic usage - will prompt for file selection
.\LogReader.ps1

# Monitor specific file
.\LogReader.ps1 -LogPath "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log"

# Monitor with filter
.\LogReader.ps1 -LogPath "C:\Path\To\File.log" -FilterText "error"

# Show last 100 lines and refresh every 2 seconds
.\LogReader.ps1 -LogPath "C:\Path\To\File.log" -TailLines 100 -RefreshInterval 2
```

### GUI Version

```powershell
# Launch GUI
.\LogReaderGUI.ps1
```

Then:
1. Click **File → Open Log File** or press Ctrl+O
2. Select your log file
3. Click **Start Monitoring**
4. Use the Filter textbox to filter entries
5. Click **Clear** to clear the display

## Parameters (Console Version)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| LogPath | String | (prompt) | Path to the log file to monitor |
| TailLines | Int | 50 | Number of initial lines to display |
| RefreshInterval | Int | 1 | Refresh interval in seconds |
| FilterText | String | "" | Optional text filter (regex supported) |

## Color Coding

- **Red**: Errors, failures, exceptions, critical messages
- **Yellow**: Warnings
- **Green**: Success, completion messages
- **Cyan**: Info/Information messages
- **White**: General log entries

## Common Log Locations

- **Intune Management Extension**: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\`
- **Configuration Manager**: `C:\Windows\CCM\Logs\`
- **Windows Logs**: `C:\Windows\Logs\`
- **Event Logs**: Use Event Viewer or PowerShell cmdlets for Windows Event Logs

## Tips

- Press **Ctrl+C** in console version to stop monitoring
- The GUI version allows you to pause/resume monitoring without losing the current view
- Both versions handle log rotation (when logs are archived and new files created)
- Filter supports regex patterns for advanced filtering

## Requirements

- PowerShell 5.1 or higher
- Windows OS
- Read permissions for the log files you want to monitor

## Examples

### Monitor Configuration Manager log
```powershell
.\LogReader.ps1 -LogPath "C:\Windows\CCM\Logs\CcmExec.log"
```

### Monitor Intune logs for errors only
```powershell
.\LogReader.ps1 -LogPath "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log" -FilterText "error|fail"
```

### High-frequency monitoring
```powershell
.\LogReader.ps1 -LogPath "C:\Temp\app.log" -RefreshInterval 0.5
```

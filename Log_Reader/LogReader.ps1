#Requires -Version 5.1

<#
.SYNOPSIS
    Live Windows Log Reader with real-time updates and remote support
.DESCRIPTION
    Monitors and displays log files with live updates as new content is added.
    Supports local and remote log reading with alternate credentials.
.PARAMETER LogPath
    Path to the log file to monitor (local or UNC path)
.PARAMETER TailLines
    Number of initial lines to display (default: 50)
.PARAMETER RefreshInterval
    Refresh interval in seconds (default: 1)
.PARAMETER FilterText
    Optional text filter to show only matching lines
.PARAMETER ComputerName
    Remote computer name to read logs from
.PARAMETER Credential
    Credentials to use for remote access or RunAs
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$LogPath,
    
    [Parameter(Mandatory=$false)]
    [int]$TailLines = 50,
    
    [Parameter(Mandatory=$false)]
    [int]$RefreshInterval = 1,
    
    [Parameter(Mandatory=$false)]
    [string]$FilterText = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ComputerName,
    
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)

# Default hard-coded remote log location
$script:DefaultRemotePath = "\\cm1.corp.contoso.com\c$\Program Files\Microsoft Configuration Manager\Logs"

# Function to display header
function Show-Header {
    Clear-Host
    Write-Host "=" * 100 -ForegroundColor Cyan
    Write-Host "  LIVE LOG READER" -ForegroundColor Green
    Write-Host "=" * 100 -ForegroundColor Cyan
    if ($script:ComputerName) {
        Write-Host "  Computer: " -NoNewline -ForegroundColor Yellow
        Write-Host $script:ComputerName -ForegroundColor White
        if ($script:Credential) {
            Write-Host "  User: " -NoNewline -ForegroundColor Yellow
            Write-Host $script:Credential.UserName -ForegroundColor White
        }
    }
    Write-Host "  Log File: " -NoNewline -ForegroundColor Yellow
    Write-Host $script:CurrentLogPath -ForegroundColor White
    Write-Host "  Status: " -NoNewline -ForegroundColor Yellow
    Write-Host "MONITORING" -ForegroundColor Green
    if ($FilterText) {
        Write-Host "  Filter: " -NoNewline -ForegroundColor Yellow
        Write-Host $FilterText -ForegroundColor Magenta
    }
    Write-Host "  Press 'M' for Menu | 'F' for Filter | 'Q' to Quit" -ForegroundColor Gray
    Write-Host "=" * 100 -ForegroundColor Cyan
    Write-Host ""
}

# Function to convert CMTrace timestamp to local time
function Convert-ToLocalTime {
    param(
        [string]$Time,
        [string]$Date
    )
    
    if ([string]::IsNullOrWhiteSpace($Time) -or [string]::IsNullOrWhiteSpace($Date)) {
        return @{ Time = $Time; Date = $Date }
    }
    
    try {
        # Extract UTC offset if present (e.g., "12:34:56.789+000" or "12:34:56.789-420")
        $utcOffset = 0
        if ($Time -match '([+-])(\d+)$') {
            $sign = $matches[1]
            $offset = [int]$matches[2]
            # Convert to minutes (offset is in minutes)
            $utcOffset = if ($sign -eq '+') { $offset } else { -$offset }
            # Remove offset from time string
            $Time = $Time -replace '[+-]\d+$', ''
        }
        
        # Parse date (MM-DD-YYYY format)
        $dateParts = $Date -split '-'
        if ($dateParts.Count -eq 3) {
            $month = [int]$dateParts[0]
            $day = [int]$dateParts[1]
            $year = [int]$dateParts[2]
            
            # Parse time (HH:MM:SS.mmm format)
            $timeParts = $Time -split '\.'
            $timeOnly = $timeParts[0]
            $milliseconds = if ($timeParts.Count -gt 1) { [int]($timeParts[1].PadRight(3, '0').Substring(0, 3)) } else { 0 }
            
            $timeComponents = $timeOnly -split ':'
            if ($timeComponents.Count -eq 3) {
                $hour = [int]$timeComponents[0]
                $minute = [int]$timeComponents[1]
                $second = [int]$timeComponents[2]
                
                # Create DateTime in UTC (adjusted by the offset from log)
                $utcDateTime = New-Object DateTime($year, $month, $day, $hour, $minute, $second, $milliseconds, [DateTimeKind]::Utc)
                
                # Adjust for the UTC offset from the log file
                $utcDateTime = $utcDateTime.AddMinutes(-$utcOffset)
                
                # Convert to local time
                $localDateTime = $utcDateTime.ToLocalTime()
                
                # Format back to original format
                $localTime = $localDateTime.ToString("HH:mm:ss.fff")
                $localDate = $localDateTime.ToString("MM-dd-yyyy")
                
                return @{
                    Time = $localTime
                    Date = $localDate
                    DateTime = $localDateTime
                }
            }
        }
    } catch {
        # If conversion fails, return original
    }
    
    return @{ Time = $Time; Date = $Date }
}

# Function to parse CMTrace/Intune style log lines
function Parse-CMTraceLog {
    param([string]$Line)
    
    # Try to parse CMTrace format: <![LOG[message]LOG]!><time="HH:MM:SS.mmm+offset" date="MM-DD-YYYY" component="name" context="" type="1" thread="123" file="">
    if ($Line -match '<\!\[LOG\[(?<Message>.+?)\]LOG\]\!><time="(?<Time>[^"]+)" date="(?<Date>[^"]+)" component="(?<Component>[^"]+)" context="[^"]*" type="(?<Type>\d)" thread="(?<Thread>\d+)"') {
        $message = $matches['Message']
        $time = $matches['Time']
        $date = $matches['Date']
        $component = $matches['Component']
        $thread = $matches['Thread']
        $type = $matches['Type']
        
        # Convert to local time
        $localTime = Convert-ToLocalTime -Time $time -Date $date
        $time = $localTime.Time
        $date = $localTime.Date
        
        # Convert type to severity
        $severity = switch ($type) {
            '1' { 'INFO' }
            '2' { 'WARN' }
            '3' { 'ERROR' }
            default { 'INFO' }
        }
        
        return @{
            Message = $message
            Time = $time
            Date = $date
            Component = $component
            Thread = $thread
            Severity = $severity
            Type = $type
        }
    }
    
    # Try generic timestamp formats
    if ($Line -match '^(?<Timestamp>\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}[\.,]?\d*)\s*(?<Level>\[?(?:INFO|INFORMATION|WARN|WARNING|ERROR|DEBUG|TRACE|FATAL|CRITICAL)\]?)?\s*(?<Rest>.+)$') {
        $timestamp = $matches['Timestamp']
        $level = if ($matches['Level']) { $matches['Level'].Trim('[]') } else { 'INFO' }
        $message = $matches['Rest']
        
        return @{
            Message = $message
            Time = $timestamp
            Date = $timestamp.Split('T')[0]
            Component = 'Unknown'
            Thread = ''
            Severity = $level.ToUpper()
            Type = '1'
        }
    }
    
    # Return raw line if no pattern matches
    return @{
        Message = $Line
        Time = ''
        Date = ''
        Component = ''
        Thread = ''
        Severity = 'INFO'
        Type = '1'
    }
}

# Function to format log entry with colors
function Format-LogEntry {
    param([string]$Line, [bool]$ShowTimestamp = $false)
    
    $parsed = Parse-CMTraceLog -Line $Line
    
    # Display timestamp if requested
    if ($ShowTimestamp) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] " -NoNewline -ForegroundColor DarkGray
    }
    
    # Display parsed time/date if available
    if ($parsed.Time) {
        Write-Host "[$($parsed.Time)] " -NoNewline -ForegroundColor Gray
    }
    
    # Display severity badge
    switch ($parsed.Severity) {
        'ERROR' { Write-Host "[ERROR]" -NoNewline -ForegroundColor Black -BackgroundColor Red }
        'WARN'  { Write-Host "[WARN ]" -NoNewline -ForegroundColor Black -BackgroundColor Yellow }
        'INFO'  { Write-Host "[INFO ]" -NoNewline -ForegroundColor Black -BackgroundColor Cyan }
        default { Write-Host "[INFO ]" -NoNewline -ForegroundColor Black -BackgroundColor Cyan }
    }
    Write-Host " " -NoNewline
    
    # Display component if available
    if ($parsed.Component -and $parsed.Component -ne 'Unknown') {
        Write-Host "[$($parsed.Component)] " -NoNewline -ForegroundColor Magenta
    }
    
    # Display thread if available
    if ($parsed.Thread) {
        Write-Host "[T:$($parsed.Thread)] " -NoNewline -ForegroundColor DarkCyan
    }
    
    # Display message with appropriate color
    $color = switch ($parsed.Severity) {
        'ERROR' { 'Red' }
        'WARN'  { 'Yellow' }
        'INFO'  { 'White' }
        default { 'White' }
    }
    
    # Additional keyword highlighting
    if ($parsed.Message -match 'success|complete|finished|installed') {
        $color = 'Green'
    }
    
    Write-Host $parsed.Message -ForegroundColor $color
}

# Function to get credentials if needed
function Get-LogCredentials {
    Write-Host "`nCredentials required for access" -ForegroundColor Yellow
    $cred = Get-Credential -Message "Enter credentials for log access"
    return $cred
}

# Function to browse remote log file
function Browse-RemoteLog {
    param([string]$Computer, [PSCredential]$Cred)
    
    Write-Host "`nSelect common log location on $Computer`:" -ForegroundColor Cyan
    Write-Host "1. Intune Logs (C$\ProgramData\Microsoft\IntuneManagementExtension\Logs)" -ForegroundColor White
    Write-Host "2. SCCM Logs (C$\Windows\CCM\Logs)" -ForegroundColor White
    Write-Host "3. Windows Logs (C$\Windows\Logs)" -ForegroundColor White
    Write-Host "4. Browse custom path" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-4)"
    
    $basePath = switch ($choice) {
        "1" { "\\$Computer\C$\ProgramData\Microsoft\IntuneManagementExtension\Logs" }
        "2" { "\\$Computer\C$\Windows\CCM\Logs" }
        "3" { "\\$Computer\C$\Windows\Logs" }
        "4" { 
            $customPath = Read-Host "Enter UNC path (e.g., \\$Computer\C$\Path\To\Logs)"
            $customPath = $customPath.Trim().Trim('"').Trim("'")
            $customPath
        }
        default { "\\$Computer\C$\ProgramData\Microsoft\IntuneManagementExtension\Logs" }
    }
    
    return $basePath
}

# Function to resolve remote UNC path with credentials (maps temporary drive if needed)
function Resolve-RemotePath {
    param(
        [string]$Path,
        [PSCredential]$Cred
    )

    $trimmed = $Path.Trim().Trim('"').Trim("'")

    # If not a UNC path, just return
    if (-not ($trimmed -match '^\\\\')) {
        return @{ Path = $trimmed }
    }

    # Extract the root share (\\server\share)
    if ($trimmed -match '^\\\\([^\\]+)\\([^\\]+)') {
        $root = "\\\\$($matches[1])\\$($matches[2])"

        # Map temporary PSDrive for credentialed access
        $driveName = "LOG" + (Get-Random -Maximum 9999)
        try {
            if ($Cred) {
                New-PSDrive -Name $driveName -PSProvider FileSystem -Root $root -Credential $Cred -ErrorAction Stop | Out-Null
            } else {
                New-PSDrive -Name $driveName -PSProvider FileSystem -Root $root -ErrorAction Stop | Out-Null
            }
            $script:TempDriveName = $driveName
        } catch {
            Write-Host "Unable to access remote path $root. Error: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }

        return @{ Path = $trimmed; Drive = $driveName }
    }

    return @{ Path = $trimmed }
}

# Function to select log file
function Select-LogFile {
    param([string]$Computer, [PSCredential]$Cred)
    
    # Check if remote
    if ($Computer) {
        Write-Host "`nConnecting to remote computer: $Computer" -ForegroundColor Cyan
        $customRemotePath = Read-Host "Enter full UNC path to log or directory (e.g., \\$Computer\e$\Program Files\Microsoft Configuration Manager\Logs) or press Enter for quick picks"
        if ([string]::IsNullOrWhiteSpace($customRemotePath)) {
            $basePath = Browse-RemoteLog -Computer $Computer -Cred $Cred
        } else {
            $basePath = $customRemotePath
        }
        
        # Test access
        try {
            $resolved = Resolve-RemotePath -Path $basePath -Cred $Cred
            $testPath = Test-Path $resolved.Path -ErrorAction Stop
        } catch {
            Write-Host "Unable to access remote computer. Error: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
        
        if ($resolved) { $script:ResolvedRemotePath = $resolved.Path }
        return $resolved.Path
    }
    
    Write-Host "`nSelect a log file to monitor:" -ForegroundColor Cyan
    Write-Host "1. Browse for file" -ForegroundColor White
    Write-Host "2. Enter path manually" -ForegroundColor White
    Write-Host "3. Quick select common location" -ForegroundColor White
    Write-Host "4. Remote computer" -ForegroundColor White
    Write-Host "5. Default remote SCCM path" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-4)"
    
    switch ($choice) {
        "1" {
            try {
                # Check if we're in STA mode (required for Windows Forms)
                if ([Threading.Thread]::CurrentThread.GetApartmentState() -eq 'MTA') {
                    Write-Host "Apartment state is MTA. Restarting in STA mode..." -ForegroundColor Yellow
                    $scriptPath = $MyInvocation.ScriptName
                    if (-not $scriptPath) { $scriptPath = $PSCommandPath }
                    powershell.exe -STA -File $scriptPath
                    exit
                }
                
                Add-Type -AssemblyName System.Windows.Forms
                $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
                $openFileDialog.Filter = "Log Files (*.log)|*.log|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
                $openFileDialog.Title = "Select Log File"
                if (Test-Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs") {
                    $openFileDialog.InitialDirectory = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
                }
                $openFileDialog.Multiselect = $false
                
                $result = $openFileDialog.ShowDialog()
                if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                    return $openFileDialog.FileName
                } else {
                    Write-Host "No file selected. Exiting." -ForegroundColor Red
                    exit
                }
            } catch {
                Write-Host "Error opening file dialog: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Falling back to manual entry..." -ForegroundColor Yellow
                $path = Read-Host "Enter full path to log file"
                $path = $path.Trim().Trim('"').Trim("'")
                if (Test-Path $path) {
                    return $path
                } else {
                    Write-Host "File not found. Exiting." -ForegroundColor Red
                    exit
                }
            }
        }
        "2" {
            $path = Read-Host "Enter full path to log file (local or UNC)"
            $path = $path.Trim().Trim('"').Trim("'")
            if (Test-Path $path) {
                return $path
            } else {
                Write-Host "File not found. Exiting." -ForegroundColor Red
                exit
            }
        }
        "3" {
            Write-Host "`nCommon locations:" -ForegroundColor Cyan
            Write-Host "1. Intune Logs" -ForegroundColor White
            Write-Host "2. SCCM Logs" -ForegroundColor White
            Write-Host "3. Windows Logs" -ForegroundColor White
            $subChoice = Read-Host "Select location (1-3)"
            
            $path = switch ($subChoice) {
                "1" { "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs" }
                "2" { "C:\Windows\CCM\Logs" }
                "3" { "C:\Windows\Logs" }
                default { "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs" }
            }
            
            if (Test-Path $path) {
                return $path
            } else {
                Write-Host "Path not found. Exiting." -ForegroundColor Red
                exit
            }
        }
        "4" {
            $remoteComputer = Read-Host "Enter remote computer name"
            $remotePath = Read-Host "Enter full UNC path to log or directory (e.g., \\\\Server\\e$\\Program Files\\Microsoft Configuration Manager\\Logs)"
            $remotePath = $remotePath.Trim().Trim('"').Trim("'")
            if ([string]::IsNullOrWhiteSpace($remotePath)) {
                Write-Host "Path cannot be empty. Exiting." -ForegroundColor Red
                exit
            }
            
            $useCred = Read-Host "Use alternate credentials? (Y/N)"
            $remoteCred = $null
            if ($useCred -eq 'Y' -or $useCred -eq 'y') {
                $remoteCred = Get-Credential -Message "Enter credentials for $remoteComputer"
                $script:Credential = $remoteCred
            }
            
            $script:ComputerName = $remoteComputer
            $resolved = Resolve-RemotePath -Path $remotePath -Cred $remoteCred
            if ($resolved) { $script:ResolvedRemotePath = $resolved.Path }
            return $resolved.Path
        }
        "5" {
            $remotePath = $script:DefaultRemotePath
            Write-Host "Using default remote path: $remotePath" -ForegroundColor Cyan
            $remoteComputer = ""
            if ($remotePath -match '^\\\\([^\\]+)\\') { $remoteComputer = $matches[1] }
            $useCred = Read-Host "Use alternate credentials for $remoteComputer? (Y/N)"
            $remoteCred = $null
            if ($useCred -eq 'Y' -or $useCred -eq 'y') {
                $remoteCred = Get-Credential -Message "Enter credentials for $remoteComputer"
                $script:Credential = $remoteCred
            }
            $script:ComputerName = $remoteComputer
            $resolved = Resolve-RemotePath -Path $remotePath -Cred $remoteCred
            if ($resolved) { $script:ResolvedRemotePath = $resolved.Path }
            return $resolved.Path
        }
        default {
            if (Test-Path $choice) {
                return $choice
            } else {
                Write-Host "Invalid choice or file not found. Exiting." -ForegroundColor Red
                exit
            }
        }
    }
}

# Main execution
try {
    # Store remote settings
    $script:ComputerName = $ComputerName
    $script:Credential = $Credential
    
    # Prompt for credentials if remote but no credential provided
    if ($ComputerName -and -not $Credential) {
        $promptCred = Read-Host "Use alternate credentials for $ComputerName? (Y/N)"
        if ($promptCred -eq 'Y' -or $promptCred -eq 'y') {
            $script:Credential = Get-Credential -Message "Enter credentials for $ComputerName"
        }
    }
    
    # Get log file path
    if (-not $LogPath) {
        $script:CurrentLogPath = Select-LogFile -Computer $script:ComputerName -Cred $script:Credential
    } else {
        if (Test-Path $LogPath) {
            # Check if it's a directory
            if ((Get-Item $LogPath).PSIsContainer) {
                Write-Host "Provided path is a directory. Searching for log files..." -ForegroundColor Yellow
                
                # Try to find AgentExecutor.log first
                $agentLog = Join-Path $LogPath "AgentExecutor.log"
                if (Test-Path $agentLog) {
                    Write-Host "Found AgentExecutor.log" -ForegroundColor Green
                    $script:CurrentLogPath = $agentLog
                } else {
                    # List all .log files in directory
                    $logFiles = Get-ChildItem -Path $LogPath -Filter "*.log" -File | Sort-Object LastWriteTime -Descending
                    
                    if ($logFiles.Count -eq 0) {
                        Write-Host "Error: No log files found in $LogPath" -ForegroundColor Red
                        exit 1
                    } elseif ($logFiles.Count -eq 1) {
                        Write-Host "Found 1 log file: $($logFiles[0].Name)" -ForegroundColor Green
                        $script:CurrentLogPath = $logFiles[0].FullName
                    } else {
                        Write-Host "`nFound $($logFiles.Count) log files:" -ForegroundColor Cyan
                        for ($i = 0; $i -lt [Math]::Min($logFiles.Count, 10); $i++) {
                            Write-Host "  [$($i+1)] $($logFiles[$i].Name) - $([Math]::Round($logFiles[$i].Length/1KB, 2)) KB - Last: $($logFiles[$i].LastWriteTime)" -ForegroundColor White
                        }
                        
                        $selection = Read-Host "`nSelect log file (1-$([Math]::Min($logFiles.Count, 10))) or press Enter for most recent"
                        if ([string]::IsNullOrWhiteSpace($selection)) {
                            $script:CurrentLogPath = $logFiles[0].FullName
                            Write-Host "Selected: $($logFiles[0].Name)" -ForegroundColor Green
                        } else {
                            $index = [int]$selection - 1
                            if ($index -ge 0 -and $index -lt $logFiles.Count) {
                                $script:CurrentLogPath = $logFiles[$index].FullName
                                Write-Host "Selected: $($logFiles[$index].Name)" -ForegroundColor Green
                            } else {
                                Write-Host "Invalid selection. Using most recent." -ForegroundColor Yellow
                                $script:CurrentLogPath = $logFiles[0].FullName
                            }
                        }
                    }
                }
            } else {
                $script:CurrentLogPath = $LogPath
            }
        } else {
            Write-Host "Error: Log file not found at $LogPath" -ForegroundColor Red
            exit 1
        }
    }
    
    # Ensure we have a file, not a directory
    if (Test-Path $script:CurrentLogPath) {
        if ((Get-Item $script:CurrentLogPath).PSIsContainer) {
            Write-Host "Error: Path is a directory, not a file. Please select a specific log file." -ForegroundColor Red
            Write-Host "Searching for log files in directory..." -ForegroundColor Yellow
            
            # Try to find AgentExecutor.log first
            $agentLog = Join-Path $script:CurrentLogPath "AgentExecutor.log"
            if (Test-Path $agentLog) {
                Write-Host "Found AgentExecutor.log" -ForegroundColor Green
                $script:CurrentLogPath = $agentLog
            } else {
                # List all .log files in directory
                $logFiles = Get-ChildItem -Path $script:CurrentLogPath -Filter "*.log" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
                
                if ($logFiles.Count -eq 0) {
                    Write-Host "Error: No log files found in directory" -ForegroundColor Red
                    exit 1
                } elseif ($logFiles.Count -eq 1) {
                    Write-Host "Found 1 log file: $($logFiles[0].Name)" -ForegroundColor Green
                    $script:CurrentLogPath = $logFiles[0].FullName
                } else {
                    Write-Host "`nFound $($logFiles.Count) log files:" -ForegroundColor Cyan
                    for ($i = 0; $i -lt [Math]::Min($logFiles.Count, 10); $i++) {
                        Write-Host "  [$($i+1)] $($logFiles[$i].Name) - $([Math]::Round($logFiles[$i].Length/1KB, 2)) KB - Last: $($logFiles[$i].LastWriteTime)" -ForegroundColor White
                    }
                    
                    $selection = Read-Host "`nSelect log file (1-$([Math]::Min($logFiles.Count, 10))) or press Enter for most recent"
                    if ([string]::IsNullOrWhiteSpace($selection)) {
                        $script:CurrentLogPath = $logFiles[0].FullName
                        Write-Host "Selected: $($logFiles[0].Name)" -ForegroundColor Green
                    } else {
                        $index = [int]$selection - 1
                        if ($index -ge 0 -and $index -lt $logFiles.Count) {
                            $script:CurrentLogPath = $logFiles[$index].FullName
                            Write-Host "Selected: $($logFiles[$index].Name)" -ForegroundColor Green
                        } else {
                            Write-Host "Invalid selection. Using most recent." -ForegroundColor Yellow
                            $script:CurrentLogPath = $logFiles[0].FullName
                        }
                    }
                }
            }
        }
    }
    
    # Initial display
    Show-Header
    
    # Read initial content
    $lastSize = 0
    if (Test-Path $script:CurrentLogPath) {
        $content = Get-Content $script:CurrentLogPath -Tail $TailLines
        foreach ($line in $content) {
            if ([string]::IsNullOrWhiteSpace($FilterText) -or $line -match $FilterText) {
                Format-LogEntry $line
            }
        }
        $lastSize = (Get-Item $script:CurrentLogPath).Length
    }
    
    Write-Host "\n--- Live Updates Below (Press M for Menu, F for Filter, Q to Quit) ---\n" -ForegroundColor Green
    
    # Monitor for changes
    while ($true) {
        # Check for keyboard input
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            switch ($key.Character) {
                'M' { 
                    Write-Host "\n\n[Returning to menu...]" -ForegroundColor Cyan
                    Start-Sleep -Seconds 1
                    
                    # Ask what to do
                    Write-Host "\nOptions:" -ForegroundColor Yellow
                    Write-Host "1. Select different log file" -ForegroundColor White
                    Write-Host "2. Change filter" -ForegroundColor White
                    Write-Host "3. Change refresh interval" -ForegroundColor White
                    Write-Host "4. Resume monitoring" -ForegroundColor White
                    Write-Host "5. Quit" -ForegroundColor White
                    
                    $menuChoice = Read-Host "\nEnter choice (1-5)"
                    
                    switch ($menuChoice) {
                        "1" {
                            $script:CurrentLogPath = Select-LogFile -Computer $script:ComputerName -Cred $script:Credential
                            Show-Header
                            $lastSize = 0
                            if (Test-Path $script:CurrentLogPath) {
                                $content = Get-Content $script:CurrentLogPath -Tail $TailLines
                                foreach ($line in $content) {
                                    if ([string]::IsNullOrWhiteSpace($FilterText) -or $line -match $FilterText) {
                                        Format-LogEntry $line
                                    }
                                }
                                $lastSize = (Get-Item $script:CurrentLogPath).Length
                            }
                            Write-Host "\n--- Live Updates Below (Press M for Menu, F for Filter, Q to Quit) ---\n" -ForegroundColor Green
                        }
                        "2" {
                            $FilterText = Read-Host "Enter filter text (regex, or press Enter to clear)"
                            Show-Header
                            Write-Host "\n[Filter updated. Resuming monitoring...]\n" -ForegroundColor Green
                        }
                        "3" {
                            $newInterval = Read-Host "Enter refresh interval in seconds (current: $RefreshInterval)"
                            if ($newInterval -match '^\d+(\.\d+)?$') {
                                $RefreshInterval = [double]$newInterval
                                Write-Host "[Refresh interval updated to $RefreshInterval seconds]\n" -ForegroundColor Green
                            }
                        }
                        "4" {
                            Show-Header
                            Write-Host "\n[Resuming monitoring...]\n" -ForegroundColor Green
                        }
                        "5" {
                            Write-Host "\n[Exiting...]" -ForegroundColor Yellow
                            exit 0
                        }
                        default {
                            Show-Header
                            Write-Host "\n[Resuming monitoring...]\n" -ForegroundColor Green
                        }
                    }
                }
                'm' { 
                    # Same as 'M'
                    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
                    & { $key.Character = 'M'; break }
                }
                'F' {
                    Write-Host "\n\n[Updating filter...]" -ForegroundColor Cyan
                    $FilterText = Read-Host "Enter filter text (regex, or press Enter to clear)"
                    Show-Header
                    Write-Host "\n[Filter updated. Resuming monitoring...]\n" -ForegroundColor Green
                }
                'f' {
                    Write-Host "\n\n[Updating filter...]" -ForegroundColor Cyan
                    $FilterText = Read-Host "Enter filter text (regex, or press Enter to clear)"
                    Show-Header
                    Write-Host "\n[Filter updated. Resuming monitoring...]\n" -ForegroundColor Green
                }
                'Q' {
                    Write-Host "\n\n[Exiting...]" -ForegroundColor Yellow
                    exit 0
                }
                'q' {
                    Write-Host "\n\n[Exiting...]" -ForegroundColor Yellow
                    exit 0
                }
            }
        }
        
        # Check file for changes
        if (Test-Path $script:CurrentLogPath) {
            $currentSize = (Get-Item $script:CurrentLogPath).Length
            
            if ($currentSize -gt $lastSize) {
                # File has grown, read new content
                $stream = [System.IO.File]::Open($script:CurrentLogPath, 'Open', 'Read', 'ReadWrite')
                $stream.Seek($lastSize, [System.IO.SeekOrigin]::Begin) | Out-Null
                $reader = New-Object System.IO.StreamReader($stream)
                
                while (-not $reader.EndOfStream) {
                    $line = $reader.ReadLine()
                    if (-not [string]::IsNullOrWhiteSpace($line)) {
                        if ([string]::IsNullOrWhiteSpace($FilterText) -or $line -match $FilterText) {
                            Format-LogEntry -Line $line -ShowTimestamp $true
                        }
                    }
                }
                
                $reader.Close()
                $stream.Close()
                $lastSize = $currentSize
            }
            elseif ($currentSize -lt $lastSize) {
                # File was truncated or rotated
                Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Log file was rotated or truncated. Reloading..." -ForegroundColor Yellow
                $lastSize = 0
            }
        }
        else {
            Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Log file no longer exists. Waiting for it to reappear..." -ForegroundColor Yellow
            $lastSize = 0
        }
        
        # Sleep in smaller increments to remain responsive
        $sleepTime = $RefreshInterval
        $elapsed = 0
        while ($elapsed -lt $sleepTime) {
            Start-Sleep -Milliseconds 100
            $elapsed += 0.1
            
            # Check for keyboard input during sleep
            if ($Host.UI.RawUI.KeyAvailable) {
                break
            }
        }
    }
}
catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if ($script:TempDriveName) {
        Remove-PSDrive -Name $script:TempDriveName -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "`n`nLog monitoring stopped." -ForegroundColor Yellow
}

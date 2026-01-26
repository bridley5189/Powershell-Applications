#Requires -Version 5.1

<#
.SYNOPSIS
    Live Windows Log Reader with GUI
.DESCRIPTION
    GUI-based log viewer with real-time updates and filtering
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Live Log Reader"
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 24, 38)

# Create menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"

$openMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$openMenuItem.Text = "Open Log File..."
$openMenuItem.ShortcutKeys = [System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::O

$openRemoteMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$openRemoteMenuItem.Text = "Open Remote Log..."
$openRemoteMenuItem.ShortcutKeys = [System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::R

$exitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitMenuItem.Text = "Exit"

$fileMenu.DropDownItems.Add($openMenuItem)
$fileMenu.DropDownItems.Add($openRemoteMenuItem)
$fileMenu.DropDownItems.Add((New-Object System.Windows.Forms.ToolStripSeparator))
$fileMenu.DropDownItems.Add($exitMenuItem)
$menuStrip.Items.Add($fileMenu)

# View menu
$viewMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$viewMenu.Text = "View"

$colorSchemeMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$colorSchemeMenuItem.Text = "Color Scheme"

$scheme1MenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$scheme1MenuItem.Text = "Standard (Default)"
$scheme1MenuItem.Checked = $true

$scheme2MenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$scheme2MenuItem.Text = "High Contrast"

$scheme3MenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$scheme3MenuItem.Text = "Colorful"

$colorSchemeMenuItem.DropDownItems.Add($scheme1MenuItem)
$colorSchemeMenuItem.DropDownItems.Add($scheme2MenuItem)
$colorSchemeMenuItem.DropDownItems.Add($scheme3MenuItem)

$viewMenu.DropDownItems.Add($colorSchemeMenuItem)
$menuStrip.Items.Add($viewMenu)

$form.Controls.Add($menuStrip)

# Create toolbar
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.BackColor = [System.Drawing.Color]::FromArgb(26, 34, 52)
$toolStrip.Top = $menuStrip.Height

# Status label
$statusLabel = New-Object System.Windows.Forms.ToolStripLabel
$statusLabel.Text = "No file loaded"
$statusLabel.ForeColor = [System.Drawing.Color]::LightGray
$toolStrip.Items.Add($statusLabel)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Start/Stop button
$toggleButton = New-Object System.Windows.Forms.ToolStripButton
$toggleButton.Text = "Start Monitoring"
$toggleButton.Enabled = $false
$toolStrip.Items.Add($toggleButton)

# Clear button
$clearButton = New-Object System.Windows.Forms.ToolStripButton
$clearButton.Text = "Clear"
$toolStrip.Items.Add($clearButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Refresh button
$refreshButton = New-Object System.Windows.Forms.ToolStripButton
$refreshButton.Text = "Refresh"
$refreshButton.ToolTipText = "Reload current log"
$toolStrip.Items.Add($refreshButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Word wrap toggle
$wordWrapButton = New-Object System.Windows.Forms.ToolStripButton
$wordWrapButton.Text = "Word Wrap: Off"
$wordWrapButton.CheckOnClick = $true
$toolStrip.Items.Add($wordWrapButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Font size controls
$fontSizeLabel = New-Object System.Windows.Forms.ToolStripLabel
$fontSizeLabel.Text = "Font:"
$fontSizeLabel.ForeColor = [System.Drawing.Color]::LightGray
$toolStrip.Items.Add($fontSizeLabel)

$fontSmallerButton = New-Object System.Windows.Forms.ToolStripButton
$fontSmallerButton.Text = "A-"
$fontSmallerButton.ToolTipText = "Decrease font size"
$toolStrip.Items.Add($fontSmallerButton)

$fontLargerButton = New-Object System.Windows.Forms.ToolStripButton
$fontLargerButton.Text = "A+"
$fontLargerButton.ToolTipText = "Increase font size"
$toolStrip.Items.Add($fontLargerButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Filter textbox
$filterLabel = New-Object System.Windows.Forms.ToolStripLabel
$filterLabel.Text = "Filter:"
$filterLabel.ForeColor = [System.Drawing.Color]::LightGray
$toolStrip.Items.Add($filterLabel)

$filterTextBox = New-Object System.Windows.Forms.ToolStripTextBox
$filterTextBox.Size = New-Object System.Drawing.Size(200, 25)
$toolStrip.Items.Add($filterTextBox)

$form.Controls.Add($toolStrip)

# Create RichTextBox for log display
$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(0, ($menuStrip.Height + $toolStrip.Height))
$logTextBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width, ($form.ClientSize.Height - $menuStrip.Height - $toolStrip.Height - 30))
$logTextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor 
                     [System.Windows.Forms.AnchorStyles]::Bottom -bor 
                     [System.Windows.Forms.AnchorStyles]::Left -bor 
                     [System.Windows.Forms.AnchorStyles]::Right
$logTextBox.BackColor = [System.Drawing.Color]::FromArgb(12, 16, 26)
$logTextBox.ForeColor = [System.Drawing.Color]::FromArgb(230, 237, 247)
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$logTextBox.ReadOnly = $true
$logTextBox.WordWrap = $false
$logTextBox.DetectUrls = $false
$form.Controls.Add($logTextBox)

# Status bar
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(26, 34, 52)

$lineCountLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$lineCountLabel.Text = "Lines: 0"
$lineCountLabel.ForeColor = [System.Drawing.Color]::LightGray
$statusBar.Items.Add($lineCountLabel)

$fileSizeLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$fileSizeLabel.Text = "Size: 0 KB"
$fileSizeLabel.ForeColor = [System.Drawing.Color]::LightGray
$statusBar.Items.Add($fileSizeLabel)

$form.Controls.Add($statusBar)

# Variables
$script:currentLogPath = ""
$script:isMonitoring = $false
$script:lastSize = 0
$script:lineCounter = 0
$script:currentFontSize = 10
$script:credential = $null
$script:colorScheme = "Standard"
$script:defaultLogDirectory = "C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs"
$script:timer = New-Object System.Windows.Forms.Timer
$script:timer.Interval = 1000

# Function to show credential dialog
function Get-Credentials {
    param(
        [string]$ServerName = "Remote Server"
    )
    
    $credForm = New-Object System.Windows.Forms.Form
    $credForm.Text = "Enter Credentials for $ServerName"
    $credForm.Size = New-Object System.Drawing.Size(400, 200)
    $credForm.StartPosition = "CenterParent"
    $credForm.FormBorderStyle = "FixedDialog"
    $credForm.MaximizeBox = $false
    $credForm.MinimizeBox = $false
    $credForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    
    $usernameLabel = New-Object System.Windows.Forms.Label
    $usernameLabel.Location = New-Object System.Drawing.Point(10, 20)
    $usernameLabel.Size = New-Object System.Drawing.Size(100, 20)
    $usernameLabel.Text = "Username:"
    $usernameLabel.ForeColor = [System.Drawing.Color]::White
    $credForm.Controls.Add($usernameLabel)
    
    $usernameTextBox = New-Object System.Windows.Forms.TextBox
    $usernameTextBox.Location = New-Object System.Drawing.Point(120, 20)
    $usernameTextBox.Size = New-Object System.Drawing.Size(250, 20)
    $credForm.Controls.Add($usernameTextBox)
    
    $passwordLabel = New-Object System.Windows.Forms.Label
    $passwordLabel.Location = New-Object System.Drawing.Point(10, 50)
    $passwordLabel.Size = New-Object System.Drawing.Size(100, 20)
    $passwordLabel.Text = "Password:"
    $passwordLabel.ForeColor = [System.Drawing.Color]::White
    $credForm.Controls.Add($passwordLabel)
    
    $passwordTextBox = New-Object System.Windows.Forms.TextBox
    $passwordTextBox.Location = New-Object System.Drawing.Point(120, 50)
    $passwordTextBox.Size = New-Object System.Drawing.Size(250, 20)
    $passwordTextBox.UseSystemPasswordChar = $true
    $credForm.Controls.Add($passwordTextBox)
    
    $domainLabel = New-Object System.Windows.Forms.Label
    $domainLabel.Location = New-Object System.Drawing.Point(10, 80)
    $domainLabel.Size = New-Object System.Drawing.Size(100, 20)
    $domainLabel.Text = "Domain (optional):"
    $domainLabel.ForeColor = [System.Drawing.Color]::White
    $credForm.Controls.Add($domainLabel)
    
    $domainTextBox = New-Object System.Windows.Forms.TextBox
    $domainTextBox.Location = New-Object System.Drawing.Point(120, 80)
    $domainTextBox.Size = New-Object System.Drawing.Size(250, 20)
    $credForm.Controls.Add($domainTextBox)
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(200, 120)
    $okButton.Size = New-Object System.Drawing.Size(80, 25)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $credForm.AcceptButton = $okButton
    $credForm.Controls.Add($okButton)
    
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(290, 120)
    $cancelButton.Size = New-Object System.Drawing.Size(80, 25)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $credForm.CancelButton = $cancelButton
    $credForm.Controls.Add($cancelButton)
    
    $result = $credForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $username = $usernameTextBox.Text
        if ($domainTextBox.Text) {
            $username = "$($domainTextBox.Text)\$username"
        }
        $securePassword = ConvertTo-SecureString $passwordTextBox.Text -AsPlainText -Force
        return New-Object System.Management.Automation.PSCredential($username, $securePassword)
    }
    
    return $null
}

# Function to access remote file
function Get-RemoteFileContent {
    param(
        [string]$Path,
        [System.Management.Automation.PSCredential]$Credential,
        [int]$TailLines = 50
    )
    
    try {
        if ($Credential) {
            # Map network drive temporarily
            $uncPath = $Path
            if ($Path -match "^\\\\([^\\]+)\\") {
                $drive = Get-PSDrive | Where-Object { $_.DisplayRoot -eq "\\$($matches[1])" } | Select-Object -First 1
                if (-not $drive) {
                    New-PSDrive -Name "LogReaderTemp" -PSProvider FileSystem -Root "\\$($matches[1])" -Credential $Credential -ErrorAction Stop | Out-Null
                }
            }
        }
        return Get-Content $Path -Tail $TailLines -ErrorAction Stop
    }
    catch {
        throw "Failed to access remote file: $($_.Exception.Message)"
    }
}

# Function to add colored text
function Add-ColoredText {
    param(
        [string]$Text,
        [System.Drawing.Color]$Color,
        [switch]$NoLineNumber
    )
    
    $logTextBox.SelectionStart = $logTextBox.TextLength
    $logTextBox.SelectionLength = 0
    
    # Add line number if not system message
    if (-not $NoLineNumber) {
        $script:lineCounter++
        $lineNum = $script:lineCounter.ToString().PadLeft(5)
        $logTextBox.SelectionColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $logTextBox.AppendText("$lineNum | ")
    }
    
    $logTextBox.SelectionColor = $Color
    $logTextBox.AppendText("$Text`r`n")
    $logTextBox.SelectionColor = $logTextBox.ForeColor
    $logTextBox.ScrollToCaret()
}

# Function to add timestamped log line with coloring
function Add-LogLine {
    param([string]$Line)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $color = Get-LogColor $Line
    Add-ColoredText "[$timestamp] $Line" $color
}

# Function to refresh current log view
function Refresh-CurrentLog {
    if (-not $script:currentLogPath) {
        [System.Windows.Forms.MessageBox]::Show("No log file is currently loaded.", "Refresh", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }

    $isRemote = $script:currentLogPath -like "\\\\*"
    $logPath = $script:currentLogPath

    try {
        $logTextBox.Clear()
        $script:lineCounter = 0

        Add-ColoredText "================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
        Add-ColoredText "  Refreshing log view" ([System.Drawing.Color]::FromArgb(56, 189, 248)) -NoLineNumber
        Add-ColoredText "================================================================================`n" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber

        if ($isRemote) {
            if ($script:credential) {
                $content = Get-RemoteFileContent -Path $logPath -Credential $script:credential -TailLines 50
            }
            else {
                $content = Get-Content $logPath -Tail 50 -ErrorAction Stop
            }
        }
        else {
            $content = Get-Content $logPath -Tail 50 -ErrorAction Stop
        }

        foreach ($line in $content) {
            Add-LogLine $line
        }

        $script:lastSize = (Get-Item $logPath).Length
        $lineCount = $logTextBox.Lines.Count
        $lineCountLabel.Text = "Lines: $lineCount"
        $fileSizeLabel.Text = "Size: $([math]::Round($script:lastSize/1KB, 2)) KB"
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to refresh log:`n`n$($_.Exception.Message)", "Refresh Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
}

# Function to load a local log file with headers and counters
function Load-LocalLog {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        [System.Windows.Forms.MessageBox]::Show("Log file not found:`n`n$Path", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }

    $script:currentLogPath = $Path
    $statusLabel.Text = "File: $Path"
    $toggleButton.Enabled = $true

    $logTextBox.Clear()
    $script:lineCounter = 0

    Add-ColoredText "================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
    Add-ColoredText "  Loaded last 50 lines from log file" ([System.Drawing.Color]::FromArgb(56, 189, 248)) -NoLineNumber
    Add-ColoredText "================================================================================`n" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber

    $content = Get-Content $Path -Tail 50
    foreach ($line in $content) {
        Add-LogLine $line
    }

    $script:lastSize = (Get-Item $Path).Length
    $lineCount = $logTextBox.Lines.Count
    $lineCountLabel.Text = "Lines: $lineCount"
    $fileSizeLabel.Text = "Size: $([math]::Round($script:lastSize/1KB, 2)) KB"
}

# Function to determine color based on content
function Get-LogColor {
    param([string]$Line)
    
    # Define color schemes
    switch ($script:colorScheme) {
        "Standard" {
            if ($Line -match "\b(error|fail(ed)?|exception|critical|fatal)\b") {
                return [System.Drawing.Color]::FromArgb(255, 100, 100)
            }
            elseif ($Line -match "\b(warning|warn)\b") {
                return [System.Drawing.Color]::FromArgb(255, 200, 100)
            }
            elseif ($Line -match "\b(success|complete(d)?|finished|passed|ok)\b") {
                return [System.Drawing.Color]::FromArgb(100, 255, 100)
            }
            elseif ($Line -match "\b(debug|trace)\b") {
                return [System.Drawing.Color]::FromArgb(150, 150, 150)
            }
            elseif ($Line -match "\b(info|information)\b") {
                return [System.Drawing.Color]::FromArgb(100, 200, 255)
            }
            elseif ($Line -match "\b(start(ed|ing)?|begin|initializ(e|ing))\b") {
                return [System.Drawing.Color]::FromArgb(200, 150, 255)
            }
            elseif ($Line -match "\b(stop(ped)?|end(ed)?|terminat(e|ed|ing))\b") {
                return [System.Drawing.Color]::FromArgb(255, 150, 200)
            }
            else {
                return [System.Drawing.Color]::FromArgb(220, 220, 220)
            }
        }
        "High Contrast" {
            if ($Line -match "\b(error|fail(ed)?|exception|critical|fatal)\b") {
                return [System.Drawing.Color]::FromArgb(255, 50, 50)
            }
            elseif ($Line -match "\b(warning|warn)\b") {
                return [System.Drawing.Color]::FromArgb(255, 255, 0)
            }
            elseif ($Line -match "\b(success|complete(d)?|finished|passed|ok)\b") {
                return [System.Drawing.Color]::FromArgb(0, 255, 0)
            }
            elseif ($Line -match "\b(debug|trace)\b") {
                return [System.Drawing.Color]::FromArgb(128, 128, 128)
            }
            elseif ($Line -match "\b(info|information)\b") {
                return [System.Drawing.Color]::FromArgb(0, 255, 255)
            }
            else {
                return [System.Drawing.Color]::White
            }
        }
        "Colorful" {
            if ($Line -match "\b(error|fail(ed)?|exception|critical|fatal)\b") {
                return [System.Drawing.Color]::FromArgb(255, 100, 150)
            }
            elseif ($Line -match "\b(warning|warn)\b") {
                return [System.Drawing.Color]::FromArgb(255, 180, 50)
            }
            elseif ($Line -match "\b(success|complete(d)?|finished|passed|ok)\b") {
                return [System.Drawing.Color]::FromArgb(50, 255, 150)
            }
            elseif ($Line -match "\b(debug|trace)\b") {
                return [System.Drawing.Color]::FromArgb(180, 180, 255)
            }
            elseif ($Line -match "\b(info|information)\b") {
                return [System.Drawing.Color]::FromArgb(100, 220, 255)
            }
            elseif ($Line -match "\b(start(ed|ing)?|begin|initializ(e|ing))\b") {
                return [System.Drawing.Color]::FromArgb(220, 100, 255)
            }
            elseif ($Line -match "\b(stop(ped)?|end(ed)?|terminat(e|ed|ing))\b") {
                return [System.Drawing.Color]::FromArgb(255, 100, 220)
            }
            elseif ($Line -match "\b(powershell|cmd|script|execute)\b") {
                return [System.Drawing.Color]::FromArgb(100, 255, 220)
            }
            else {
                return [System.Drawing.Color]::FromArgb(200, 220, 240)
            }
        }
    }
}

# Timer tick event
$timer_Tick = {
    if ($script:isMonitoring -and $script:currentLogPath -and (Test-Path $script:currentLogPath)) {
        try {
            $currentSize = (Get-Item $script:currentLogPath).Length
            
            if ($currentSize -gt $script:lastSize) {
                $stream = [System.IO.File]::Open($script:currentLogPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                $stream.Seek($script:lastSize, [System.IO.SeekOrigin]::Begin) | Out-Null
                $reader = New-Object System.IO.StreamReader($stream)
                
                while (-not $reader.EndOfStream) {
                    $line = $reader.ReadLine()
                    if (-not [string]::IsNullOrWhiteSpace($line)) {
                        $filterText = $filterTextBox.Text
                        if ([string]::IsNullOrWhiteSpace($filterText) -or $line -match $filterText) {
                            Add-LogLine $line
                        }
                    }
                }
                
                $reader.Close()
                $stream.Close()
                $script:lastSize = $currentSize
                
                # Update status
                $lineCount = $logTextBox.Lines.Count
                $lineCountLabel.Text = "Lines: $lineCount"
                $fileSizeLabel.Text = "Size: $([math]::Round($currentSize/1KB, 2)) KB"
            }
            elseif ($currentSize -lt $script:lastSize) {
                Add-ColoredText "`n[SYSTEM] Log file was rotated or truncated. Reloading...`n" ([System.Drawing.Color]::Yellow) -NoLineNumber
                $script:lastSize = 0
            }
        }
        catch {
            Add-ColoredText "[ERROR] $($_.Exception.Message)" ([System.Drawing.Color]::Red) -NoLineNumber
        }
    }
}
$script:timer.Add_Tick($timer_Tick)

# Open file event
$openMenuItem_Click = {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Log Files (*.log)|*.log|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    if (Test-Path $script:defaultLogDirectory) {
        $openFileDialog.InitialDirectory = $script:defaultLogDirectory
    }
    $openFileDialog.Title = "Select Log File"
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Load-LocalLog $openFileDialog.FileName
    }
}
$openMenuItem.Add_Click($openMenuItem_Click)

# Open remote file event
$openRemoteMenuItem_Click = {
    # Remote file input form
    $remoteForm = New-Object System.Windows.Forms.Form
    $remoteForm.Text = "Open Remote Log File"
    $remoteForm.Size = New-Object System.Drawing.Size(550, 250)
    $remoteForm.StartPosition = "CenterParent"
    $remoteForm.FormBorderStyle = "FixedDialog"
    $remoteForm.MaximizeBox = $false
    $remoteForm.MinimizeBox = $false
    $remoteForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    
    $serverLabel = New-Object System.Windows.Forms.Label
    $serverLabel.Location = New-Object System.Drawing.Point(10, 20)
    $serverLabel.Size = New-Object System.Drawing.Size(150, 20)
    $serverLabel.Text = "Server Name/IP:"
    $serverLabel.ForeColor = [System.Drawing.Color]::White
    $remoteForm.Controls.Add($serverLabel)
    
    $serverTextBox = New-Object System.Windows.Forms.TextBox
    $serverTextBox.Location = New-Object System.Drawing.Point(160, 20)
    $serverTextBox.Size = New-Object System.Drawing.Size(350, 20)
    $remoteForm.Controls.Add($serverTextBox)
    
    $pathLabel = New-Object System.Windows.Forms.Label
    $pathLabel.Location = New-Object System.Drawing.Point(10, 50)
    $pathLabel.Size = New-Object System.Drawing.Size(150, 20)
    $pathLabel.Text = "Log File Path:"
    $pathLabel.ForeColor = [System.Drawing.Color]::White
    $remoteForm.Controls.Add($pathLabel)
    
    $pathTextBox = New-Object System.Windows.Forms.TextBox
    $pathTextBox.Location = New-Object System.Drawing.Point(160, 50)
    $pathTextBox.Size = New-Object System.Drawing.Size(350, 20)
    $pathTextBox.Text = "C`$\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log"
    $remoteForm.Controls.Add($pathTextBox)
    
    $exampleLabel = New-Object System.Windows.Forms.Label
    $exampleLabel.Location = New-Object System.Drawing.Point(160, 75)
    $exampleLabel.Size = New-Object System.Drawing.Size(350, 40)
    $exampleLabel.Text = "Examples:`r`nC`$\Path\To\File.log`r`nAdmin`$\Logs\app.log"
    $exampleLabel.ForeColor = [System.Drawing.Color]::Gray
    $remoteForm.Controls.Add($exampleLabel)
    
    $credCheckBox = New-Object System.Windows.Forms.CheckBox
    $credCheckBox.Location = New-Object System.Drawing.Point(10, 120)
    $credCheckBox.Size = New-Object System.Drawing.Size(200, 20)
    $credCheckBox.Text = "Use alternate credentials"
    $credCheckBox.ForeColor = [System.Drawing.Color]::White
    $credCheckBox.Checked = $true
    $remoteForm.Controls.Add($credCheckBox)
    
    $connectButton = New-Object System.Windows.Forms.Button
    $connectButton.Location = New-Object System.Drawing.Point(340, 160)
    $connectButton.Size = New-Object System.Drawing.Size(80, 25)
    $connectButton.Text = "Connect"
    $connectButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $remoteForm.AcceptButton = $connectButton
    $remoteForm.Controls.Add($connectButton)
    
    $cancelButton2 = New-Object System.Windows.Forms.Button
    $cancelButton2.Location = New-Object System.Drawing.Point(430, 160)
    $cancelButton2.Size = New-Object System.Drawing.Size(80, 25)
    $cancelButton2.Text = "Cancel"
    $cancelButton2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $remoteForm.CancelButton = $cancelButton2
    $remoteForm.Controls.Add($cancelButton2)
    
    $remoteResult = $remoteForm.ShowDialog()
    
    if ($remoteResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $serverName = $serverTextBox.Text.Trim()
        $logPath = $pathTextBox.Text.Trim()
        
        if ([string]::IsNullOrWhiteSpace($serverName) -or [string]::IsNullOrWhiteSpace($logPath)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter both server name and log path.", "Missing Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Get credentials if needed
        $script:credential = $null
        if ($credCheckBox.Checked) {
            $script:credential = Get-Credentials -ServerName $serverName
            if (-not $script:credential) {
                return
            }
        }
        
        # Build UNC path
        $uncPath = "\\$serverName\$logPath"
        
        try {
            $script:currentLogPath = $uncPath
            $statusLabel.Text = "Remote File: $uncPath"
            $toggleButton.Enabled = $true
            
            # Load initial content
            $logTextBox.Clear()
            $script:lineCounter = 0
            
            Add-ColoredText "================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
            Add-ColoredText "  Connecting to remote server: $serverName" ([System.Drawing.Color]::FromArgb(56, 189, 248)) -NoLineNumber
            Add-ColoredText "================================================================================`n" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
            
            if ($script:credential) {
                $content = Get-RemoteFileContent -Path $uncPath -Credential $script:credential -TailLines 50
            } else {
                $content = Get-Content $uncPath -Tail 50 -ErrorAction Stop
            }
            
            foreach ($line in $content) {
                Add-LogLine $line
            }
            
            $script:lastSize = (Get-Item $uncPath).Length
            
            # Update status
            $lineCount = $logTextBox.Lines.Count
            $lineCountLabel.Text = "Lines: $lineCount"
            $fileSizeLabel.Text = "Size: $([math]::Round($script:lastSize/1KB, 2)) KB"
            
            Add-ColoredText "`n================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
            Add-ColoredText "  OK Successfully connected to remote log file" ([System.Drawing.Color]::FromArgb(74, 222, 128)) -NoLineNumber
            Add-ColoredText "================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to open remote file:`n`n$($_.Exception.Message)", "Connection Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            $script:credential = $null
        }
    }
}
$openRemoteMenuItem.Add_Click($openRemoteMenuItem_Click)

# Exit event
$exitMenuItem_Click = {
    $form.Close()
}
$exitMenuItem.Add_Click($exitMenuItem_Click)

# Toggle monitoring event
$toggleButton_Click = {
    if ($script:isMonitoring) {
        $script:timer.Stop()
        $script:isMonitoring = $false
        $toggleButton.Text = "Start Monitoring"
        $statusLabel.Text += " (Paused)"
    }
    else {
        $script:timer.Start()
        $script:isMonitoring = $true
        $toggleButton.Text = "Stop Monitoring"
        $statusLabel.Text = $statusLabel.Text -replace " \(Paused\)", ""
        Add-ColoredText "`n================================================================================" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
        Add-ColoredText "  > Live Monitoring Started - New entries will appear below" ([System.Drawing.Color]::FromArgb(94, 234, 212)) -NoLineNumber
        Add-ColoredText "================================================================================`n" ([System.Drawing.Color]::FromArgb(70, 90, 140)) -NoLineNumber
    }
}
$toggleButton.Add_Click($toggleButton_Click)

# Clear event
$clearButton_Click = {
    $logTextBox.Clear()
    $script:lineCounter = 0
    $lineCountLabel.Text = "Lines: 0"
}
$clearButton.Add_Click($clearButton_Click)

# Refresh event
$refreshButton_Click = {
    Refresh-CurrentLog
}
$refreshButton.Add_Click($refreshButton_Click)

# Word wrap toggle event
$wordWrapButton_Click = {
    $logTextBox.WordWrap = $wordWrapButton.Checked
    if ($wordWrapButton.Checked) {
        $wordWrapButton.Text = "Word Wrap: On"
    } else {
        $wordWrapButton.Text = "Word Wrap: Off"
    }
}
$wordWrapButton.Add_Click($wordWrapButton_Click)

# Font size events
$fontSmallerButton_Click = {
    if ($script:currentFontSize -gt 6) {
        $script:currentFontSize--
        $logTextBox.Font = New-Object System.Drawing.Font("Consolas", $script:currentFontSize)
    }
}
$fontSmallerButton.Add_Click($fontSmallerButton_Click)

$fontLargerButton_Click = {
    if ($script:currentFontSize -lt 20) {
        $script:currentFontSize++
        $logTextBox.Font = New-Object System.Drawing.Font("Consolas", $script:currentFontSize)
    }
}
$fontLargerButton.Add_Click($fontLargerButton_Click)

# Color scheme events
$scheme1MenuItem_Click = {
    $script:colorScheme = "Standard"
    $scheme1MenuItem.Checked = $true
    $scheme2MenuItem.Checked = $false
    $scheme3MenuItem.Checked = $false
    # Refresh display if content exists
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Color scheme changed to Standard.`nReload the file to see the new colors.", "Color Scheme Changed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}
$scheme1MenuItem.Add_Click($scheme1MenuItem_Click)

$scheme2MenuItem_Click = {
    $script:colorScheme = "High Contrast"
    $scheme1MenuItem.Checked = $false
    $scheme2MenuItem.Checked = $true
    $scheme3MenuItem.Checked = $false
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Color scheme changed to High Contrast.`nReload the file to see the new colors.", "Color Scheme Changed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}
$scheme2MenuItem.Add_Click($scheme2MenuItem_Click)

$scheme3MenuItem_Click = {
    $script:colorScheme = "Colorful"
    $scheme1MenuItem.Checked = $false
    $scheme2MenuItem.Checked = $false
    $scheme3MenuItem.Checked = $true
    if ($logTextBox.Text.Length -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Color scheme changed to Colorful.`nReload the file to see the new colors.", "Color Scheme Changed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}
$scheme3MenuItem.Add_Click($scheme3MenuItem_Click)

# Show form
$form.Add_Shown({
    $form.Activate()
    $defaultLog = Join-Path $script:defaultLogDirectory "AgentExecutor.log"
    if (Test-Path $defaultLog) {
        Load-LocalLog $defaultLog
    }
})
[void]$form.ShowDialog()

#Requires -Version 5.1
<#
.SYNOPSIS
    Log Reader - Option 3: Terminal Chic (Dark, Neon Accents)
.DESCRIPTION
    Dark terminal theme with colored tokens and compact display
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Reader - Option 3: Terminal"
$form.Size = New-Object System.Drawing.Size(1400, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 20, 30)

# Menu
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.BackColor = [System.Drawing.Color]::FromArgb(25, 30, 40)
$menuStrip.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)

$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"
$fileMenu.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)

$openMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$openMenuItem.Text = "Open Log..."
$fileMenu.DropDownItems.Add($openMenuItem)

$mergeMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$mergeMenuItem.Text = "Merge Logs..."
$fileMenu.DropDownItems.Add($mergeMenuItem)

$exitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitMenuItem.Text = "Exit"
$fileMenu.DropDownItems.Add($exitMenuItem)

$menuStrip.Items.Add($fileMenu)
$form.Controls.Add($menuStrip)

# Tools menu
$toolsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$toolsMenu.Text = "Tools"
$errorLookupItem = New-Object System.Windows.Forms.ToolStripMenuItem
$errorLookupItem.Text = "Error Lookup..."
$toolsMenu.DropDownItems.Add($errorLookupItem)
$menuStrip.Items.Add($toolsMenu)

# Toolbar
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.BackColor = [System.Drawing.Color]::FromArgb(25, 30, 40)

$monitorButton = New-Object System.Windows.Forms.ToolStripButton
$monitorButton.Text = "Start Monitoring"
$monitorButton.CheckOnClick = $true
$monitorButton.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 200)
$toolStrip.Items.Add($monitorButton)

$refreshButton = New-Object System.Windows.Forms.ToolStripButton
$refreshButton.Text = "Refresh"
$refreshButton.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 200)
$toolStrip.Items.Add($refreshButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$jumpButton = New-Object System.Windows.Forms.ToolStripButton
$jumpButton.Text = "Jump to Latest"
$jumpButton.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$toolStrip.Items.Add($jumpButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$wrapButton = New-Object System.Windows.Forms.ToolStripButton
$wrapButton.Text = "Word Wrap: Off"
$wrapButton.CheckOnClick = $true
$wrapButton.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$toolStrip.Items.Add($wrapButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$searchLabel = New-Object System.Windows.Forms.ToolStripLabel
$searchLabel.Text = "Filter:"
$searchLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$toolStrip.Items.Add($searchLabel)

$searchBox = New-Object System.Windows.Forms.ToolStripTextBox
$searchBox.Size = New-Object System.Drawing.Size(200, 25)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(35, 40, 50)
$searchBox.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)
$toolStrip.Items.Add($searchBox)

$form.Controls.Add($toolStrip)

# RichTextBox for terminal-style display
$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(0, ($menuStrip.Height + $toolStrip.Height))
$logTextBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width, ($form.ClientSize.Height - $menuStrip.Height - $toolStrip.Height - 25))
$logTextBox.Anchor = "Top,Bottom,Left,Right"
$logTextBox.BackColor = [System.Drawing.Color]::FromArgb(15, 20, 30)
$logTextBox.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 240)
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logTextBox.ReadOnly = $true
$logTextBox.WordWrap = $false
$logTextBox.BorderStyle = "None"
$logTextBox.DetectUrls = $false
$form.Controls.Add($logTextBox)

# Status bar
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.BackColor = [System.Drawing.Color]::FromArgb(25, 30, 40)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "No file loaded"
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$statusStrip.Items.Add($statusLabel)

$countLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$countLabel.Text = "Lines: 0"
$countLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$statusStrip.Items.Add($countLabel)

$form.Controls.Add($statusStrip)

# Variables
$script:currentLogPath = ""
$script:allLines = @()
$script:defaultLogDirectory = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$script:lastFileSize = 0
$script:monitoringTimer = New-Object System.Windows.Forms.Timer
$script:monitoringTimer.Interval = 1000
$script:loadedPaths = @()
$script:lastFileSizes = @{}

# Color scheme
$colors = @{
    Timestamp = [System.Drawing.Color]::FromArgb(0, 255, 255)      # Cyan
    Host = [System.Drawing.Color]::FromArgb(100, 255, 200)         # Green
    Error = [System.Drawing.Color]::FromArgb(255, 80, 80)          # Red
    Warn = [System.Drawing.Color]::FromArgb(255, 200, 0)           # Yellow
    Info = [System.Drawing.Color]::FromArgb(100, 200, 255)         # Blue
    Debug = [System.Drawing.Color]::FromArgb(200, 120, 255)        # Purple
    Default = [System.Drawing.Color]::FromArgb(200, 220, 240)      # Light gray
}

# Functions
function Add-ColoredLine {
    param([string]$Line)
    
    # Parse and colorize the line
    $logTextBox.SelectionStart = $logTextBox.TextLength
    $logTextBox.SelectionLength = 0
    
    # Intune/CMTrace styled line first
    if ($Line -match '<!\[LOG\[(.*?)\]LOG!><time="([^"]+)"\s+date="([^"]+)"\s+component="([^"]*)"[\s\S]*?type="(\d+)"[\s\S]*?thread="([^"]*)"') {
        $msg = $matches[1]
        $t = $matches[2]
        $d = $matches[3]
        $comp = $matches[4]
        $type = $matches[5]
        $thr = $matches[6]
        try {
            $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss.fffffff', $null)
        } catch {
            try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss.fff', $null) } catch { try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss', $null) } catch { $dt = Get-Date } }
        }
        $logTextBox.SelectionColor = $colors.Timestamp
        $logTextBox.AppendText($dt.ToString('yyyy-MM-dd HH:mm:ss.fff'))
        $logTextBox.SelectionColor = $colors.Default
        $logTextBox.AppendText(" ")
        $logTextBox.SelectionColor = $colors.Host
        $logTextBox.AppendText("[$comp] ")
        switch ($type) { '3' { $logTextBox.SelectionColor = $colors.Error; $logTextBox.AppendText("[ERROR] ") }
                         '2' { $logTextBox.SelectionColor = $colors.Warn;  $logTextBox.AppendText("[WARN] ") }
                         default { $logTextBox.SelectionColor = $colors.Info; $logTextBox.AppendText("[INFO] ") } }
        $logTextBox.SelectionColor = $colors.Default
        $logTextBox.AppendText($msg)
    }
    else {
        # Fallback: attempt to render with timestamp + level tokens
        $timestampFound = $false
        if ($Line -match '(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:\.\d+)?)') {
            $logTextBox.SelectionColor = $colors.Timestamp
            $logTextBox.AppendText($matches[1])
            $Line = $Line.Substring($Line.IndexOf($matches[1]) + $matches[1].Length)
            $timestampFound = $true
        }
        elseif ($Line -match '\[(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') {
            $logTextBox.SelectionColor = $colors.Timestamp
            $logTextBox.AppendText($matches[1])
            $Line = $Line.Substring($Line.IndexOf($matches[1]) + $matches[1].Length)
            $timestampFound = $true
        }
        if ($timestampFound) { $logTextBox.SelectionColor = $colors.Default; $logTextBox.AppendText(" ") }
        if ($Line -match '\b(ERROR|WARN|WARNING|INFO|DEBUG|TRACE|FATAL)\b') {
            $level = $matches[1]
            $beforeLevel = $Line.Substring(0, $Line.IndexOf($level))
            $afterLevel = $Line.Substring($Line.IndexOf($level) + $level.Length)
            $logTextBox.SelectionColor = $colors.Default
            $logTextBox.AppendText($beforeLevel)
            switch ($level) {
                {$_ -in "ERROR","FATAL"} { $logTextBox.SelectionColor = $colors.Error }
                {$_ -in "WARN","WARNING"} { $logTextBox.SelectionColor = $colors.Warn }
                "INFO" { $logTextBox.SelectionColor = $colors.Info }
                {$_ -in "DEBUG","TRACE"} { $logTextBox.SelectionColor = $colors.Debug }
            }
            $logTextBox.AppendText("[$level]")
            $logTextBox.SelectionColor = $colors.Default
            $logTextBox.AppendText($afterLevel)
        } else {
            $logTextBox.SelectionColor = $colors.Default
            $logTextBox.AppendText($Line)
        }
    }
    
    $logTextBox.AppendText("`n")
    $logTextBox.ScrollToCaret()
}

function Load-LogFile {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        [System.Windows.Forms.MessageBox]::Show("File not found: $Path", "Error", "OK", "Error")
        return
    }
    
    $script:currentLogPath = $Path
    $script:loadedPaths = @($Path)
    $statusLabel.Text = "Loading: $Path"
    Refresh-AllFromFiles
    $script:lastFileSizes[$Path] = (Get-Item $Path).Length
    $statusLabel.Text = "Files: $($script:loadedPaths.Count) | Showing merged view"
}

function Refresh-AllFromFiles {
    $script:allLines = @()
    foreach ($p in $script:loadedPaths) {
        if (Test-Path $p) {
            $content = Get-Content $p -Tail 1000
            $script:allLines += $content
        }
    }
    Refresh-Display
}

function Refresh-Display {
    $logTextBox.Clear()
    $searchText = $searchBox.Text
    
    $linesToShow = $script:allLines
    if ($searchText) {
        $linesToShow = $linesToShow | Where-Object { $_ -match $searchText }
    }
    
    # Sort by time descending (newest first) if they contain timestamps
    $linesToShow = $linesToShow | Sort-Object {
        try {
            if ($_ -match '(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:\.\d+)?)') {
                # Try with milliseconds first
                if ($matches[1] -match '\.\d+$') {
                    [datetime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss.fff", $null)
                }
                else {
                    [datetime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss", $null)
                }
            }
            else {
                [datetime]::Now
            }
        }
        catch {
            [datetime]::Now
        }
    } -Descending
    
    foreach ($line in $linesToShow) {
        Add-ColoredLine $line
    }
    
    $countLabel.Text = "Lines: $($linesToShow.Count) / $($script:allLines.Count)"
}

# Event handlers
$openMenuItem.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Log Files (*.log)|*.log|All Files (*.*)|*.*"
    if (Test-Path $script:defaultLogDirectory) {
        $openFileDialog.InitialDirectory = $script:defaultLogDirectory
    }
    if ($openFileDialog.ShowDialog() -eq "OK") {
        Load-LogFile $openFileDialog.FileName
    }
})

$mergeMenuItem.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Log Files (*.log)|*.log|All Files (*.*)|*.*"
    $dlg.Multiselect = $true
    if (Test-Path $script:defaultLogDirectory) { $dlg.InitialDirectory = $script:defaultLogDirectory }
    if ($dlg.ShowDialog() -eq "OK") {
        foreach ($p in $dlg.FileNames) {
            if (-not ($script:loadedPaths -contains $p)) { $script:loadedPaths += $p; $script:lastFileSizes[$p] = (Get-Item $p).Length }
        }
        Refresh-AllFromFiles
        $statusLabel.Text = "Files: $($script:loadedPaths.Count) | Showing merged view"
    }
})

$exitMenuItem.Add_Click({ $form.Close() })

$refreshButton.Add_Click({
    if ($script:loadedPaths.Count -gt 0) { Refresh-AllFromFiles }
})

$monitorButton.Add_CheckedChanged({
    if ($monitorButton.Checked) {
        if ($script:loadedPaths.Count -gt 0) {
            $monitorButton.Text = "Stop Monitoring"
            $script:monitoringTimer.Start()
        }
        else {
            $monitorButton.Checked = $false
            [System.Windows.Forms.MessageBox]::Show("Please open a log file first", "Info", "OK", "Information")
        }
    }
    else {
        $monitorButton.Text = "Start Monitoring"
        $script:monitoringTimer.Stop()
    }
})

$jumpButton.Add_Click({
    $logTextBox.SelectionStart = $logTextBox.TextLength
    $logTextBox.ScrollToCaret()
})

$wrapButton.Add_CheckedChanged({
    $logTextBox.WordWrap = $wrapButton.Checked
    if ($wrapButton.Checked) {
        $wrapButton.Text = "Word Wrap: On"
    } else {
        $wrapButton.Text = "Word Wrap: Off"
    }
})

$searchBox.Add_TextChanged({ Refresh-Display })

$errorLookupItem.Add_Click({
    Add-Type -AssemblyName Microsoft.VisualBasic
    $codeText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Win32 Error Code (e.g., 3010)", "Error Lookup", "")
    if ($codeText) {
        try { $msg = ([System.ComponentModel.Win32Exception]::new([int]$codeText)).Message } catch { $msg = (cmd /c "net helpmsg $codeText") -join "\n" }
        if (-not $msg) { $msg = "No description found for code $codeText" }
        [System.Windows.Forms.MessageBox]::Show($msg, "Error $codeText", "OK", "Information") | Out-Null
    }
})

# Monitor timer event
$script:monitoringTimer.Add_Tick({
    if ($script:loadedPaths.Count -gt 0) {
        $changed = $false
        foreach ($p in $script:loadedPaths) {
            if (Test-Path $p) {
                $len = (Get-Item $p).Length
                if (-not $script:lastFileSizes.ContainsKey($p) -or $len -ne $script:lastFileSizes[$p]) { $script:lastFileSizes[$p] = $len; $changed = $true }
            }
        }
        if ($changed) { Refresh-AllFromFiles }
    }
})

# Auto-load default log
$form.Add_Shown({
    $form.Activate()
    $defaultLog = Join-Path $script:defaultLogDirectory "AgentExecutor.log"
    if (Test-Path $defaultLog) {
        Load-LogFile $defaultLog
    }
})

[void]$form.ShowDialog()

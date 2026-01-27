#Requires -Version 5.1
<#
.SYNOPSIS
    Log Reader - Option 2: BareTail Style (High-Contrast Row Stripes)
.DESCRIPTION
    Bright row backgrounds for severity levels, simple column view
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Reader - Option 2: BareTail Style"
$form.Size = New-Object System.Drawing.Size(1400, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::White

# Menu
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"

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
$toolsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$toolsMenu.Text = "Tools"
$errorLookupItem = New-Object System.Windows.Forms.ToolStripMenuItem
$errorLookupItem.Text = "Error Lookup..."
$toolsMenu.DropDownItems.Add($errorLookupItem)
$menuStrip.Items.Add($toolsMenu)
$form.Controls.Add($menuStrip)

# Toolbar
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)

$monitorButton = New-Object System.Windows.Forms.ToolStripButton
$monitorButton.Text = "Start Monitoring"
$monitorButton.CheckOnClick = $true
$toolStrip.Items.Add($monitorButton)

$refreshButton = New-Object System.Windows.Forms.ToolStripButton
$refreshButton.Text = "Refresh"
$toolStrip.Items.Add($refreshButton)

$followTailButton = New-Object System.Windows.Forms.ToolStripButton
$followTailButton.Text = "Follow Tail"
$followTailButton.CheckOnClick = $true
$followTailButton.Checked = $true
$toolStrip.Items.Add($followTailButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

# Level filter checkboxes
$errorCheck = New-Object System.Windows.Forms.ToolStripButton
$errorCheck.Text = "ERROR"
$errorCheck.CheckOnClick = $true
$errorCheck.Checked = $true
$errorCheck.BackColor = [System.Drawing.Color]::FromArgb(255, 200, 200)
$toolStrip.Items.Add($errorCheck)

$warnCheck = New-Object System.Windows.Forms.ToolStripButton
$warnCheck.Text = "WARN"
$warnCheck.CheckOnClick = $true
$warnCheck.Checked = $true
$warnCheck.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 150)
$toolStrip.Items.Add($warnCheck)

$infoCheck = New-Object System.Windows.Forms.ToolStripButton
$infoCheck.Text = "INFO"
$infoCheck.CheckOnClick = $true
$infoCheck.Checked = $true
$infoCheck.BackColor = [System.Drawing.Color]::FromArgb(220, 255, 220)
$toolStrip.Items.Add($infoCheck)

$debugCheck = New-Object System.Windows.Forms.ToolStripButton
$debugCheck.Text = "DEBUG"
$debugCheck.CheckOnClick = $true
$debugCheck.Checked = $true
$toolStrip.Items.Add($debugCheck)

$form.Controls.Add($toolStrip)

# ListView for log entries (CMTrace-like order)
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(0, ($menuStrip.Height + $toolStrip.Height))
$listView.Size = New-Object System.Drawing.Size($form.ClientSize.Width, ($form.ClientSize.Height - $menuStrip.Height - $toolStrip.Height - 25))
$listView.Anchor = "Top,Bottom,Left,Right"
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $false
$listView.Font = New-Object System.Drawing.Font("Courier New", 9)
$listView.BackColor = [System.Drawing.Color]::White

# Add columns Message | Component | Date/Time | Thread | Level
[void]$listView.Columns.Add("Message", 800)
[void]$listView.Columns.Add("Component", 140)
[void]$listView.Columns.Add("Date/Time", 160)
[void]$listView.Columns.Add("Thread", 90)
[void]$listView.Columns.Add("Level", 70)

$form.Controls.Add($listView)

# Status bar
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "No file loaded"
$statusStrip.Items.Add($statusLabel)

$countLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$countLabel.Text = "Lines: 0"
$statusStrip.Items.Add($countLabel)

$form.Controls.Add($statusStrip)

# Variables
$script:currentLogPath = ""
$script:allLogEntries = @()
$script:defaultLogDirectory = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$script:lastFileSize = 0
$script:monitoringTimer = New-Object System.Windows.Forms.Timer
$script:monitoringTimer.Interval = 1000
$script:loadedPaths = @()
$script:lastFileSizes = @{}

# Functions
function Parse-LogLine {
    param([string]$Line, [int]$LineNumber)
    
    $entry = [PSCustomObject]@{
        Message = $Line
        Component = ""
        Time = ""
        Thread = ""
        Level = "INFO"
        File = ""
    }
    
    # Intune/CMTrace style
    if ($Line -match '<!\[LOG\[(.*?)\]LOG!><time="([^"]+)"\s+date="([^"]+)"\s+component="([^"]*)"[\s\S]*?type="(\d+)"[\s\S]*?thread="([^"]*)"') {
        $entry.Message = $matches[1]
        $t = $matches[2]
        $d = $matches[3]
        $entry.Component = $matches[4]
        $type = $matches[5]
        $entry.Thread = $matches[6]
        try {
            $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss.fffffff', $null)
        } catch {
            try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss.fff', $null) } catch { try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss', $null) } catch { $dt = Get-Date } }
        }
        $entry.Time = $dt.ToString('yyyy-MM-dd HH:mm:ss.fff')
        switch ($type) { '3' { $entry.Level = 'ERROR' } '2' { $entry.Level = 'WARN' } default { $entry.Level = 'INFO' } }
        return $entry
    }
    
    # Fallback timestamp
    if ($Line -match '(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:\.\d+)?)') { $entry.Time = $matches[1] }
    elseif ($Line -match '\[(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') { $entry.Time = $matches[1] }
    elseif ($Line -match '(\d{2}:\d{2}:\d{2})') { $entry.Time = "$(Get-Date -Format 'yyyy-MM-dd') $($matches[1])" }
    else { $entry.Time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') }
    
    if ($Line -match '\b(ERROR|WARN|WARNING|INFO|DEBUG|TRACE|FATAL)\b') { $entry.Level = $matches[1].ToUpper(); if ($entry.Level -eq 'WARNING') { $entry.Level = 'WARN' } }
    
    return $entry
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
    $script:allLogEntries = @()
    foreach ($p in $script:loadedPaths) {
        if (Test-Path $p) {
            $content = Get-Content $p -Tail 1000
            $lineNum = 0
            foreach ($line in $content) {
                $entry = Parse-LogLine $line $lineNum
                $entry.File = $p
                $script:allLogEntries += $entry
                $lineNum++
            }
        }
    }
    Refresh-ListView
}

function Refresh-ListView {
    $listView.BeginUpdate()
    $listView.Items.Clear()
    # Sort by time descending (newest first)
    $sortedEntries = $script:allLogEntries | Sort-Object {
        try {
            if ($_.Time -match '\.\d+$') { [datetime]::ParseExact($_.Time, 'yyyy-MM-dd HH:mm:ss.fff', $null) }
            else { [datetime]::ParseExact($_.Time, 'yyyy-MM-dd HH:mm:ss', $null) }
        } catch { [datetime]::Now }
    } -Descending
    
    foreach ($entry in $sortedEntries) {
        # Filter by level checkboxes
        $skip = $false
        if ($entry.Level -eq "ERROR" -and -not $errorCheck.Checked) { $skip = $true }
        if ($entry.Level -eq "WARN" -and -not $warnCheck.Checked) { $skip = $true }
        if ($entry.Level -eq "INFO" -and -not $infoCheck.Checked) { $skip = $true }
        if ($entry.Level -eq "DEBUG" -and -not $debugCheck.Checked) { $skip = $true }
        
        if (-not $skip) {
            $item = New-Object System.Windows.Forms.ListViewItem($entry.Message)
            $item.SubItems.Add($entry.Component)
            $item.SubItems.Add($entry.Time)
            $item.SubItems.Add($entry.Thread)
            $item.SubItems.Add($entry.Level)
            
            # High-contrast colors
            switch ($entry.Level) {
                "ERROR" { 
                    $item.BackColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
                    $item.ForeColor = [System.Drawing.Color]::Black
                }
                "WARN" { 
                    $item.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 0)
                    $item.ForeColor = [System.Drawing.Color]::Black
                }
                "INFO" { 
                    $item.BackColor = [System.Drawing.Color]::FromArgb(180, 255, 180)
                    $item.ForeColor = [System.Drawing.Color]::Black
                }
                "DEBUG" { 
                    $item.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 255)
                    $item.ForeColor = [System.Drawing.Color]::Black
                }
                default {
                    $item.BackColor = [System.Drawing.Color]::White
                    $item.ForeColor = [System.Drawing.Color]::Black
                }
            }
            
            [void]$listView.Items.Add($item)
        }
    }
    
    $listView.EndUpdate()
    
    if ($followTailButton.Checked -and $listView.Items.Count -gt 0) {
        $listView.EnsureVisible($listView.Items.Count - 1)
    }
    
    $countLabel.Text = "Lines: $($listView.Items.Count) / $($script:allLogEntries.Count)"
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

$errorCheck.Add_CheckedChanged({ Refresh-ListView })
$warnCheck.Add_CheckedChanged({ Refresh-ListView })
$infoCheck.Add_CheckedChanged({ Refresh-ListView })
$debugCheck.Add_CheckedChanged({ Refresh-ListView })

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
    }
})

$errorLookupItem.Add_Click({
    Add-Type -AssemblyName Microsoft.VisualBasic
    $codeText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Win32 Error Code (e.g., 3010)", "Error Lookup", "")
    if ($codeText) {
        try { $msg = ([System.ComponentModel.Win32Exception]::new([int]$codeText)).Message } catch { $msg = (cmd /c "net helpmsg $codeText") -join "\n" }
        if (-not $msg) { $msg = "No description found for code $codeText" }
        [System.Windows.Forms.MessageBox]::Show($msg, "Error $codeText", "OK", "Information") | Out-Null
    }
})

# Auto-load default log
$form.Add_Shown({
    $form.Activate()
    $defaultLog = Join-Path $script:defaultLogDirectory "AgentExecutor.log"
    if (Test-Path $defaultLog) { Load-LogFile $defaultLog }
})

[void]$form.ShowDialog()

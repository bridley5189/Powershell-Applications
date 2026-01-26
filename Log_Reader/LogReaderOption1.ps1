#Requires -Version 5.1
<#
.SYNOPSIS
    Log Reader - Option 1: LogViewPlus Style (Structured Table)
.DESCRIPTION
    Light theme with table layout, detail pane, and level filtering
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Reader - Option 1: Table View"
$form.Size = New-Object System.Drawing.Size(1400, 900)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)

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
$toolStrip.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

$monitorButton = New-Object System.Windows.Forms.ToolStripButton
$monitorButton.Text = "Start Monitoring"
$monitorButton.CheckOnClick = $true
$toolStrip.Items.Add($monitorButton)

$refreshButton = New-Object System.Windows.Forms.ToolStripButton
$refreshButton.Text = "Refresh"
$toolStrip.Items.Add($refreshButton)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$levelLabel = New-Object System.Windows.Forms.ToolStripLabel
$levelLabel.Text = "Level:"
$toolStrip.Items.Add($levelLabel)

$levelComboBox = New-Object System.Windows.Forms.ToolStripComboBox
$levelComboBox.Items.AddRange(@("All", "ERROR", "WARN", "INFO", "DEBUG", "TRACE"))
$levelComboBox.SelectedIndex = 0
$levelComboBox.DropDownStyle = "DropDownList"
$toolStrip.Items.Add($levelComboBox)

$toolStrip.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$searchLabel = New-Object System.Windows.Forms.ToolStripLabel
$searchLabel.Text = "Search:"
$toolStrip.Items.Add($searchLabel)

$searchBox = New-Object System.Windows.Forms.ToolStripTextBox
$searchBox.Size = New-Object System.Drawing.Size(200, 25)
$toolStrip.Items.Add($searchBox)

$form.Controls.Add($toolStrip)

# Split container
$splitContainer = New-Object System.Windows.Forms.SplitContainer
$splitContainer.Orientation = "Horizontal"
$splitContainer.Location = New-Object System.Drawing.Point(0, ($menuStrip.Height + $toolStrip.Height))
$splitContainer.Size = New-Object System.Drawing.Size($form.ClientSize.Width, ($form.ClientSize.Height - $menuStrip.Height - $toolStrip.Height - 25))
$splitContainer.SplitterDistance = 500
$splitContainer.Anchor = "Top,Bottom,Left,Right"
$form.Controls.Add($splitContainer)

# DataGridView for log entries
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Dock = "Fill"
$dataGridView.BackgroundColor = [System.Drawing.Color]::White
$dataGridView.BorderStyle = "None"
$dataGridView.AllowUserToAddRows = $false
$dataGridView.AllowUserToDeleteRows = $false
$dataGridView.ReadOnly = $true
$dataGridView.SelectionMode = "FullRowSelect"
$dataGridView.MultiSelect = $false
$dataGridView.RowHeadersVisible = $false
$dataGridView.AllowUserToResizeRows = $false
$dataGridView.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
$dataGridView.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Add columns (CMTrace-like order): Message, Component, Date/Time, Thread, Level
$messageColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$messageColumn.HeaderText = "Message"
$messageColumn.AutoSizeMode = "Fill"
$messageColumn.Name = "Message"
$dataGridView.Columns.Add($messageColumn)

$componentColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$componentColumn.HeaderText = "Component"
$componentColumn.Width = 140
$componentColumn.Name = "Component"
$dataGridView.Columns.Add($componentColumn)

$timeColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$timeColumn.HeaderText = "Date/Time"
$timeColumn.Width = 180
$timeColumn.Name = "Time"
$dataGridView.Columns.Add($timeColumn)

$threadColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$threadColumn.HeaderText = "Thread"
$threadColumn.Width = 90
$threadColumn.Name = "Thread"
$dataGridView.Columns.Add($threadColumn)

$levelColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$levelColumn.HeaderText = "Level"
$levelColumn.Width = 70
$levelColumn.Name = "Level"
$dataGridView.Columns.Add($levelColumn)

$splitContainer.Panel1.Controls.Add($dataGridView)

# Detail pane
$detailBox = New-Object System.Windows.Forms.RichTextBox
$detailBox.Dock = "Fill"
$detailBox.BackColor = [System.Drawing.Color]::White
$detailBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$detailBox.ReadOnly = $true
$detailBox.BorderStyle = "None"
$splitContainer.Panel2.Controls.Add($detailBox)

# Status bar
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "No file loaded"
$statusStrip.Items.Add($statusLabel)

$countLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$countLabel.Text = "Rows: 0"
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
        Time = ""
        Level = "INFO"
        Thread = ""
        Component = ""
        Message = $Line
        FullText = $Line
        File = ""
    }
    
    # Intune/CMTrace style: <![LOG[message]LOG!><time="HH:mm:ss.fffffff" date="M-d-yyyy" component="X" ... thread="Y" ...>
        if ($Line -match '<!\[LOG\[(.*?)\]LOG!><time="([^"]+)"\s+date="([^"]+)"\s+component="([^"]*)"[\s\S]*?thread="([^"]*)"') {
        $msg = $matches[1]
        $t = $matches[2]
        $d = $matches[3]
        $comp = $matches[4]
            $thr = $matches[5]
        $entry.Message = $msg
        $entry.Component = $comp
        $entry.Thread = $thr
        try {
            $fmt = 'M-d-yyyy HH:mm:ss.fffffff'
            $dt = [datetime]::ParseExact("$d $t", $fmt, $null)
        } catch {
            try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss.fff', $null) } catch {
                try { $dt = [datetime]::ParseExact("$d $t", 'M-d-yyyy HH:mm:ss', $null) } catch { $dt = Get-Date }
            }
        }
        $entry.Time = $dt.ToString('yyyy-MM-dd HH:mm:ss.fff')
        if ($Line -match 'type="(\d+)"') {
            switch ($matches[1]) {
                '3' { $entry.Level = 'ERROR' }
                '2' { $entry.Level = 'WARN' }
                default { $entry.Level = 'INFO' }
            }
        }
        return $entry
    }

    # Parse timestamp - try multiple formats
    if ($Line -match '(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}[.\d]*)') {
        $entry.Time = $matches[1]
    }
    elseif ($Line -match '\[(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') {
        $entry.Time = $matches[1]
    }
    elseif ($Line -match '(\d{2}:\d{2}:\d{2})') {
        $entry.Time = "$(Get-Date -Format 'yyyy-MM-dd') $($matches[1])"
    }
    else {
        # No timestamp found, use current time
        $entry.Time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')
    }
    
    # Parse level
    if ($Line -match '\b(ERROR|WARN|WARNING|INFO|DEBUG|TRACE|FATAL|CRITICAL)\b') {
        $entry.Level = $matches[1].ToUpper()
        if ($entry.Level -eq "WARNING") { $entry.Level = "WARN" }
    }
    
    # Parse thread
    if ($Line -match 'Thread[_\s]*(\d+|[A-Za-z0-9_]+)') {
        $entry.Thread = $matches[1]
    }
    
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

function Merge-LogFiles {
    param([string[]]$Paths)
    foreach ($p in $Paths) {
        if (-not ($script:loadedPaths -contains $p)) {
            $script:loadedPaths += $p
            $script:lastFileSizes[$p] = (Get-Item $p).Length
        }
    }
    Refresh-AllFromFiles
    $statusLabel.Text = "Files: $($script:loadedPaths.Count) | Showing merged view"
}

function Refresh-AllFromFiles {
    $dataGridView.Rows.Clear()
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
    Refresh-Grid
}

function Refresh-Grid {
    $dataGridView.Rows.Clear()
    $filter = $levelComboBox.SelectedItem
    $searchText = $searchBox.Text
    
    $filtered = $script:allLogEntries
    if ($filter -ne "All") {
        $filtered = $filtered | Where-Object { $_.Level -eq $filter }
    }
    if ($searchText) {
        $filtered = $filtered | Where-Object { $_.FullText -match $searchText }
    }
    # Sort by time descending (newest first)
    $filtered = $filtered | Sort-Object {
        try {
            # Try with milliseconds first
            if ($_.Time -match '\.\d+$') {
                [datetime]::ParseExact($_.Time, "yyyy-MM-dd HH:mm:ss.fff", $null)
            }
            else {
                [datetime]::ParseExact($_.Time, "yyyy-MM-dd HH:mm:ss", $null)
            }
        }
        catch {
            [datetime]::Now
        }
    } -Descending
    
    
    foreach ($entry in $filtered) {
        $rowIndex = $dataGridView.Rows.Add($entry.Message, $entry.Component, $entry.Time, $entry.Thread, $entry.Level)
        $row = $dataGridView.Rows[$rowIndex]
        
        # Store entry object in row tag for later retrieval
        $row.Tag = $entry
        
        # Color by level
        switch ($entry.Level) {
            "ERROR" { 
                $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 230, 230)
                $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(180, 0, 0)
            }
            "WARN" { 
                $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 250, 220)
                $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(150, 100, 0)
            }
            "INFO" { 
                $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(230, 245, 255)
                $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(0, 80, 140)
            }
            "DEBUG" { 
                $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
            }
            "TRACE" { 
                $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
            }
        }
    }
    
    $countLabel.Text = "Rows: $($dataGridView.Rows.Count) / $($script:allLogEntries.Count)"
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
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Log Files (*.log)|*.log|All Files (*.*)|*.*"
    $openFileDialog.Multiselect = $true
    if (Test-Path $script:defaultLogDirectory) {
        $openFileDialog.InitialDirectory = $script:defaultLogDirectory
    }
    if ($openFileDialog.ShowDialog() -eq "OK") {
        Merge-LogFiles $openFileDialog.FileNames
    }
})

$exitMenuItem.Add_Click({ $form.Close() })

$refreshButton.Add_Click({
    if ($script:currentLogPath) {
        Refresh-AllFromFiles
    }
})

$monitorButton.Add_CheckedChanged({
    if ($monitorButton.Checked) {
        if ($script:currentLogPath) {
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

$levelComboBox.Add_SelectedIndexChanged({ Refresh-Grid })
$searchBox.Add_TextChanged({ Refresh-Grid })

$errorLookupItem.Add_Click({
    $codeText = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Win32 Error Code (e.g., 3010):", "Error Lookup", "")
    if ($codeText -and $codeText.Trim().Length -gt 0) {
        $msg = $null
        try {
            $code = [int]$codeText
            $msg = ([System.ComponentModel.Win32Exception]::new($code)).Message
        } catch {
            try {
                $msg = (cmd /c "net helpmsg $codeText") -join "\n"
            } catch {}
        }
        if (-not $msg) { $msg = "No description found for code $codeText" }
        [System.Windows.Forms.MessageBox]::Show($msg, "Error $codeText", "OK", "Information") | Out-Null
    }
})

# Monitor timer event across all loaded files
$script:monitoringTimer.Add_Tick({
    if ($script:loadedPaths.Count -gt 0) {
        $changed = $false
        foreach ($p in $script:loadedPaths) {
            if (Test-Path $p) {
                $len = (Get-Item $p).Length
                if (-not $script:lastFileSizes.ContainsKey($p) -or $len -ne $script:lastFileSizes[$p]) {
                    $script:lastFileSizes[$p] = $len
                    $changed = $true
                }
            }
        }
        if ($changed) { Refresh-AllFromFiles }
    }
})

$dataGridView.Add_SelectionChanged({
    if ($dataGridView.SelectedRows.Count -gt 0) {
        $selectedRow = $dataGridView.SelectedRows[0]
        $entry = $selectedRow.Tag
        $detailBox.Clear()
        $detailBox.AppendText("Full Log Entry:`n`n")
        $detailBox.AppendText($entry.FullText)
        $detailBox.AppendText("`n`n")
        $detailBox.AppendText("Date/Time: $($entry.Time)`n")
        $detailBox.AppendText("Component: $($entry.Component)`n")
        $detailBox.AppendText("Thread: $($entry.Thread)`n")
        $detailBox.AppendText("Level: $($entry.Level)`n")
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

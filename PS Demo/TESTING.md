# PowerShell Script Runner - Testing Guide

A comprehensive testing guide for the PowerShell Script Runner Professional Edition. This document provides step-by-step procedures, test cases, and checklists.

---

## Table of Contents

1. [Test Environment Setup](#test-environment-setup)
2. [Pre-Testing Checklist](#pre-testing-checklist)
3. [Functional Testing](#functional-testing)
4. [Integration Testing](#integration-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [Edge Case Testing](#edge-case-testing)
8. [Known Issues & Limitations](#known-issues--limitations)
9. [Troubleshooting](#troubleshooting)
10. [Test Result Logging](#test-result-logging)

---

## Test Environment Setup

### Required Environment
- **OS:** Windows 7 or later (Windows 10/11 recommended)
- **PowerShell:** Version 5.0+ (5.1+ recommended)
- **.NET Framework:** 4.5 or later
- **RAM:** 2 GB minimum, 4 GB+ recommended
- **Disk Space:** 500 MB free (for logs and temporary files)

### Installation Steps

```powershell
# 1. Ensure ExecutionPolicy allows script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Navigate to PS Demo folder
cd "C:\Path\To\PS Demo"

# 3. Launch the application
./PowerShell-Script-Runner.ps1
# OR use the compiled executable:
./PowerShell-Script-Runner.exe

# 4. Verify GUI appears without errors
```

### Test Data Preparation

```powershell
# Create a test scripts folder with sample scripts
$testFolder = "$env:TEMP\TestScripts"
New-Item -ItemType Directory -Path $testFolder -Force

# Create sample test scripts
@'
# Test-Sample1.ps1
Write-Host "Sample Test 1 - Success" -ForegroundColor Green
Get-Date
"@ | Set-Content "$testFolder\Test-Sample1.ps1"

@'
# Test-Sample2.ps1
Write-Host "Sample Test 2 - Info" -ForegroundColor Cyan
Get-ChildItem $env:TEMP | Select-Object Name -First 5
"@ | Set-Content "$testFolder\Test-Sample2.ps1"

@'
# Test-Sample3-Error.ps1
Write-Host "Sample Test 3 - Error" -ForegroundColor Red
Write-Error "This is a test error"
"@ | Set-Content "$testFolder\Test-Sample3-Error.ps1"

Write-Host "Test scripts created in: $testFolder"
```

---

## Pre-Testing Checklist

### Initial Application Check

- [ ] Application launches without console errors
- [ ] GUI window displays correctly and is responsive
- [ ] All buttons and controls are visible
- [ ] Menu bar is accessible (File, Tools, etc.)
- [ ] Application icon displays (if applicable)
- [ ] Window can be resized without artifacts
- [ ] No memory leaks evident on initial load

### Configuration Check

- [ ] Settings directory exists: `$env:APPDATA\PowerShellScriptRunner\`
- [ ] Previous settings load (if not first run)
- [ ] Window position/size persists between launches
- [ ] Theme preference is remembered

---

## Functional Testing

### Test 1: Script Browsing & Discovery

**Objective:** Verify application can locate and display PowerShell scripts

**Steps:**
1. Click "Browse..." button
2. Navigate to `$env:TEMP\TestScripts` (created in setup)
3. Click "Open" or confirm selection
4. Verify script list populates:
   - [ ] Test-Sample1.ps1 appears
   - [ ] Test-Sample2.ps1 appears
   - [ ] Test-Sample3-Error.ps1 appears

**Expected Result:** All .ps1 files in folder are listed in the left panel with file sizes

**Pass/Fail:** ___________

---

### Test 2: Script Code Viewing

**Objective:** Verify code viewer displays script contents correctly

**Steps:**
1. Select "Test-Sample1.ps1" from the list
2. Verify code appears in right panel
3. Check for syntax highlighting:
   - [ ] Keywords highlighted (Write-Host, Get-Date)
   - [ ] Strings highlighted (in green/brown)
   - [ ] Comments highlighted (in gray/green)
4. Test "Copy Code" button (if available)
   - [ ] Paste code into Notepad
   - [ ] Verify content matches source

**Expected Result:** Complete script code visible with color-coded syntax

**Pass/Fail:** ___________

---

### Test 3: Script Execution (User Mode)

**Objective:** Verify script execution as current user

**Steps:**
1. Select "Test-Sample1.ps1"
2. Click "Run" button (or press Ctrl+R)
3. Monitor terminal output panel:
   - [ ] Output appears in real-time
   - [ ] Timestamp displays
   - [ ] Completion message shows
   - [ ] No console windows appear
4. Check execution timer:
   - [ ] Timer shows during execution
   - [ ] Total duration displays at end

**Expected Result:** Script output visible, execution completes successfully

**Output Should Contain:**
```
Sample Test 1 - Success
[Current Date/Time]
```

**Pass/Fail:** ___________

---

### Test 4: Script Execution (Admin Mode)

**Objective:** Verify script execution with elevated privileges

**Steps:**
1. Select "Test-Sample1.ps1"
2. Click "Admin" button (or press Ctrl+Shift+R)
3. Respond to UAC prompt (click "Yes")
4. Verify script runs with administrator privileges:
   - [ ] UAC prompt appears
   - [ ] Script executes
   - [ ] Output displays normally

**Expected Result:** Script runs with admin elevation without errors

**Pass/Fail:** ___________

---

### Test 5: Script Parameters

**Objective:** Verify parameter input and passing to scripts

**Steps:**
1. Create test script with parameters:
   ```powershell
   param([string]$Name = "World")
   Write-Host "Hello, $Name!"
   ```
2. Save as `$env:TEMP\TestScripts\Test-Params.ps1`
3. In GUI, select Test-Params.ps1
4. Hold Shift + Click "Run" (or double-click script)
5. Enter parameter: `World`
6. Verify output shows: `Hello, World!`

**Expected Result:** Parameters passed correctly to script

**Pass/Fail:** ___________

---

### Test 6: Stop Script Button

**Objective:** Verify ability to terminate running scripts

**Steps:**
1. Create long-running test script:
   ```powershell
   Write-Host "Starting..."
   1..60 | ForEach-Object { Write-Host $_; Start-Sleep -Seconds 1 }
   ```
2. Save as `$env:TEMP\TestScripts\Test-Long.ps1`
3. Select and run Test-Long.ps1
4. After 5 seconds, click "Stop" button
5. Verify script terminates:
   - [ ] Counter stops incrementing
   - [ ] Process exits cleanly
   - [ ] No hanging processes

**Expected Result:** Script stops within 1-2 seconds of Stop click

**Pass/Fail:** ___________

---

### Test 7: Script Filtering/Search

**Objective:** Verify search/filter functionality

**Steps:**
1. Ensure multiple scripts in folder
2. Type "Sample1" in search/filter box
3. Verify list filters:
   - [ ] Only Test-Sample1.ps1 shows
   - [ ] Other scripts hidden
4. Clear search box
5. Verify all scripts reappear

**Expected Result:** Dynamic filtering works correctly

**Pass/Fail:** ___________

---

### Test 8: Script History

**Objective:** Verify recent scripts are tracked

**Steps:**
1. Run Test-Sample1.ps1
2. Run Test-Sample2.ps1
3. Run Test-Sample3-Error.ps1
4. Access "Recent Scripts" or History menu
5. Verify all three scripts appear in order

**Expected Result:** All recent scripts listed in reverse execution order

**Pass/Fail:** ___________

---

### Test 9: Execution Log Viewer

**Objective:** Verify execution history is recorded and viewable

**Steps:**
1. Run a few scripts as above
2. Click "View Execution Log" or History button
3. Verify log shows:
   - [ ] Script name
   - [ ] Execution timestamp
   - [ ] Status (Success/Failed)
   - [ ] Duration
4. Check color coding:
   - [ ] Success = Green
   - [ ] Failed = Red
5. Close log viewer

**Expected Result:** All executions logged with complete details

**Pass/Fail:** ___________

---

### Test 10: Dark/Light Theme Toggle

**Objective:** Verify theme switching works

**Steps:**
1. Locate theme toggle button (sun/moon icon or theme menu)
2. Click to switch to opposite theme
3. Verify visual changes:
   - [ ] Background color changes
   - [ ] Text color changes appropriately
   - [ ] Button colors adjust
4. Toggle back to original theme
5. Close and reopen application
6. Verify theme preference persisted

**Expected Result:** Theme switches smoothly and persists across sessions

**Pass/Fail:** ___________

---

### Test 11: Keyboard Shortcuts

**Objective:** Verify keyboard shortcuts work

**Steps:**
1. Test each shortcut (with script selected):
   - [ ] **Ctrl+R** → Script runs (user mode)
   - [ ] **Ctrl+Shift+R** → Script runs (admin mode)
   - [ ] **Ctrl+E** → Code editor opens
   - [ ] **Ctrl+S** → Code saves (after editing)
   - [ ] **Ctrl+F** → Find dialog opens (if implemented)
   - [ ] **Ctrl+H** → Replace dialog opens (if implemented)

**Expected Result:** All shortcuts execute their intended actions

**Pass/Fail:** ___________

---

## Integration Testing

### Test 12: Script Editor Integration

**Objective:** Verify code editing and saving

**Steps:**
1. Select a test script
2. Click "Edit" or press Ctrl+E
3. Make a small change (add comment)
4. Click "Save" or press Ctrl+S
5. Verify change is saved to file:
   ```powershell
   # Check file in PowerShell
   Get-Content "$env:TEMP\TestScripts\Test-Sample1.ps1" | Select-Object -Last 5
   ```

**Expected Result:** Changes persist on disk

**Pass/Fail:** ___________

---

### Test 13: Execution Statistics (if implemented)

**Objective:** Verify statistics tracking

**Steps:**
1. Run each test script 2-3 times
2. Click "View Stats" or Statistics button
3. Verify displays for each script:
   - [ ] Total runs
   - [ ] Success count
   - [ ] Failure count
   - [ ] Average duration
   - [ ] Last run time

**Expected Result:** Accurate statistics for each script

**Pass/Fail:** ___________

---

### Test 14: Syntax Checker (if implemented)

**Objective:** Verify pre-execution syntax validation

**Steps:**
1. Create invalid script:
   ```powershell
   Write-Host "Missing closing quote
   Get-ChildItem
   ```
2. Save as `$env:TEMP\TestScripts\Test-BadSyntax.ps1`
3. Select invalid script
4. Click "Run"
5. Verify error dialog appears:
   - [ ] Error message displayed
   - [ ] Line number indicated
   - [ ] Script doesn't execute

**Expected Result:** Syntax errors prevented from running

**Pass/Fail:** ___________

---

### Test 15: AI Assistant Integration (if configured)

**Objective:** Verify OpenAI integration (requires API key)

**Prerequisites:**
- OpenAI API key available
- Internet connectivity

**Steps:**
1. Click "AI Assistant" or "Settings"
2. Enter OpenAI API key when prompted
3. Click "Review Script" on a test script
4. Verify AI analysis returns:
   - [ ] Issues identified (if any)
   - [ ] Suggestions provided
   - [ ] Response displays without errors

**Expected Result:** AI assistant functions without errors

**Pass/Fail:** ___________

---

## Performance Testing

### Test 16: Large Script Handling

**Objective:** Verify application handles large scripts

**Steps:**
1. Create large script (500 KB):
   ```powershell
   # Generate 10,000 lines
   1..10000 | ForEach-Object { "Write-Host 'Line $_'" } | Out-File "$env:TEMP\TestScripts\Test-Large.ps1"
   ```
2. Load folder containing large script
3. Select the script
4. Verify UI remains responsive:
   - [ ] Code loads without hanging
   - [ ] Can scroll through code
   - [ ] Syntax highlighting applies
   - [ ] Can execute without errors

**Expected Result:** Large scripts handled efficiently

**Pass/Fail:** ___________

---

### Test 17: Many Scripts Handling

**Objective:** Verify application handles large numbers of scripts

**Steps:**
1. Create 100+ test scripts:
   ```powershell
   1..100 | ForEach-Object { "Write-Host 'Test $_'" | Set-Content "$env:TEMP\TestScripts\Test-$_.ps1" }
   ```
2. Load folder in application
3. Verify UI responsiveness:
   - [ ] All scripts list loads
   - [ ] Scrolling is smooth
   - [ ] Filtering works quickly
   - [ ] Selection responsive

**Expected Result:** Application scales well with many scripts

**Pass/Fail:** ___________

---

### Test 18: Memory Usage Monitoring

**Objective:** Verify application doesn't leak memory

**Steps:**
1. Launch application
2. Note baseline memory (Task Manager)
3. Run 20 scripts in succession
4. Note memory after runs
5. Close/reopen application
6. Memory should return to baseline

**Expected Result:** No significant memory growth after repeated operations

**Pass/Fail:** ___________

---

## Security Testing

### Test 19: API Key Security

**Objective:** Verify API keys are stored securely

**Steps:**
1. Configure OpenAI API key if not done
2. Locate settings file: `$env:APPDATA\PowerShellScriptRunner\openai_key.txt`
3. Verify key is encrypted:
   ```powershell
   Get-Content "$env:APPDATA\PowerShellScriptRunner\openai_key.txt"
   # Should NOT contain actual API key in plaintext
   ```
4. Verify file permissions are restricted

**Expected Result:** Key file contains encrypted data only

**Pass/Fail:** ___________

---

### Test 20: Script Injection Prevention

**Objective:** Verify application safely handles suspicious scripts

**Steps:**
1. Create script with potential injection:
   ```powershell
   # Script-Injection.ps1
   Write-Host "$(whoami)"
   Remove-Item -Force "C:\Windows\System32\test.txt" -ErrorAction SilentlyContinue
   ```
2. Load and preview in application
3. Verify:
   - [ ] Script preview shows code safely
   - [ ] User can review before running
   - [ ] Execution is explicit (not automatic)

**Expected Result:** No automatic execution; user controls when scripts run

**Pass/Fail:** ___________

---

### Test 21: Elevated Execution Safety

**Objective:** Verify admin elevation requires user confirmation

**Steps:**
1. Select any script
2. Click "Admin" button
3. Verify UAC prompt appears:
   - [ ] User must explicitly confirm
   - [ ] Cannot bypass elevation check
4. Deny UAC prompt
5. Verify script does NOT run

**Expected Result:** Admin execution requires explicit user approval

**Pass/Fail:** ___________

---

## Edge Case Testing

### Test 22: Scripts with Special Characters

**Objective:** Verify handling of special characters in filenames/content

**Steps:**
1. Create scripts with special names:
   - `Test-[Special].ps1`
   - `Test-&Ampersand.ps1`
   - `Test-$Dollar.ps1`
2. Verify application displays all scripts
3. Select and run each
4. All should execute correctly

**Expected Result:** Special characters handled without errors

**Pass/Fail:** ___________

---

### Test 23: Empty Script File

**Objective:** Verify handling of empty scripts

**Steps:**
1. Create empty script: `New-Item "$env:TEMP\TestScripts\Test-Empty.ps1"`
2. Load and select in application
3. Verify:
   - [ ] Application doesn't crash
   - [ ] Empty code viewer shows nothing
   - [ ] Can execute without error

**Expected Result:** Empty scripts handled gracefully

**Pass/Fail:** ___________

---

### Test 24: Very Long Script Names

**Objective:** Verify long filenames are displayed correctly

**Steps:**
1. Create script with very long name (>200 chars):
   ```powershell
   $longName = "Test-VeryLongScriptNameThatExceedsNormalLengthAndShouldStillDisplayCorrectlyInTheApplicationUI-" + ([string]::new('x', 150)) + ".ps1"
   "Write-Host 'OK'" | Set-Content "$env:TEMP\TestScripts\$longName"
   ```
2. Verify script appears in list (may be truncated for display)
3. Can still select and execute

**Expected Result:** Long names displayed/handled appropriately

**Pass/Fail:** ___________

---

### Test 25: Rapid Successive Executions

**Objective:** Verify stability under rapid script launching

**Steps:**
1. Select a script
2. Click "Run" 5 times rapidly
3. Verify:
   - [ ] No race conditions
   - [ ] Scripts queue or prevent overlap
   - [ ] No crashes or hangs
   - [ ] Output displays correctly

**Expected Result:** Application handles rapid execution safely

**Pass/Fail:** ___________

---

## Known Issues & Limitations

### Development Phase Status

This application is in **DEVELOPMENT/TESTING MODE**. The following are known limitations:

| Issue | Severity | Status | Workaround |
|-------|----------|--------|-----------|
| (Example) Some keyboard shortcuts may not work in Dark mode | Low | Open | Use menus instead |
| (Example) AI features require internet connectivity | Medium | By Design | Test with internet access |
| (Example) Very large scripts (>10MB) may load slowly | Low | Open | Split large scripts |

### How to Report Issues

When reporting issues found during testing:

1. **Document the issue:**
   - What was being tested
   - Steps to reproduce
   - Expected vs actual result
   - Screenshots (if applicable)

2. **Environment details:**
   - Windows version
   - PowerShell version
   - .NET Framework version
   - Any error messages

3. **Log Files:**
   - Check: `$env:APPDATA\PowerShellScriptRunner\logs\`
   - Include relevant log entries

---

## Troubleshooting

### Application Won't Launch

**Symptom:** No GUI appears when launching

**Solutions:**
```powershell
# 1. Check execution policy
Get-ExecutionPolicy

# 2. Set if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Try with explicit path
& "C:\Full\Path\To\PowerShell-Script-Runner.ps1"

# 4. Try via PowerShell console directly
powershell -NoProfile -ExecutionPolicy Bypass -File "PowerShell-Script-Runner.ps1"
```

### Scripts Not Appearing

**Symptom:** Folder selected but no scripts show

**Solutions:**
1. Verify folder contains .ps1 files: `Get-ChildItem -Filter "*.ps1"`
2. Check "Recursive" checkbox if scripts in subfolders
3. Try selecting different folder to test

### Script Output Not Appearing

**Symptom:** Run script but no output shown

**Solutions:**
1. Verify script has output (try Test-Sample1.ps1)
2. Check if script completed before checking output
3. Look for error messages in terminal
4. Try running script directly in PowerShell to verify it works

### Settings Not Persisting

**Symptom:** Window position/theme not remembered

**Solutions:**
```powershell
# Verify settings directory exists
Test-Path "$env:APPDATA\PowerShellScriptRunner"

# Check for write permissions
icacls "$env:APPDATA\PowerShellScriptRunner"

# Manually create if needed
New-Item -ItemType Directory -Path "$env:APPDATA\PowerShellScriptRunner" -Force
```

---

## Test Result Logging

### Simple Test Log Template

```
TEST SESSION: [DATE]
TESTER: [NAME]
ENVIRONMENT: [OS VERSION, PowerShell VERSION]

Test 1: [TEST NAME]
Status: [PASS/FAIL/SKIP]
Notes: [Any observations]

Test 2: [TEST NAME]
Status: [PASS/FAIL/SKIP]
Notes: [Any observations]

...

SUMMARY:
- Total Tests: X
- Passed: X
- Failed: X
- Skipped: X

Issues Found:
1. [Issue description]
2. [Issue description]

Recommendations:
1. [Recommendation]
2. [Recommendation]
```

### Automated Test Logging (PowerShell)

```powershell
# Create test log
$logPath = "$env:APPDATA\PowerShellScriptRunner\logs\test_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
New-Item -ItemType Directory -Path (Split-Path $logPath) -Force -ErrorAction SilentlyContinue

# Log test execution
Add-Content -Path $logPath -Value "TEST SESSION: $(Get-Date)"
Add-Content -Path $logPath -Value "PowerShell: $($PSVersionTable.PSVersion)"
Add-Content -Path $logPath -Value "---"

# Run test and log
$startTime = Get-Date
& ".\PowerShell-Script-Runner.ps1"
$duration = (Get-Date) - $startTime

Add-Content -Path $logPath -Value "Execution Time: $($duration.TotalSeconds)s"
Add-Content -Path $logPath -Value "Status: SUCCESS"
```

---

## Sign-Off

| Phase | Status | Date | Tester |
|-------|--------|------|--------|
| Pre-Testing | ✅ | _____ | _________ |
| Functional Testing | _____ | _____ | _________ |
| Integration Testing | _____ | _____ | _________ |
| Performance Testing | _____ | _____ | _________ |
| Security Testing | _____ | _____ | _________ |
| Edge Cases | _____ | _____ | _________ |
| **FINAL APPROVAL** | _____ | _____ | _________ |

---

## Contact & Support

For testing support or questions:
- See [README.md](README.md) for features overview
- See [TEST_RESULTS.md](TEST_RESULTS.md) for automated test results
- See [ENHANCEMENTS_IMPLEMENTED.md](ENHANCEMENTS_IMPLEMENTED.md) for feature details

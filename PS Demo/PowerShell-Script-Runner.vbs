' PowerShell Script Runner - VBScript Wrapper
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strCurrentDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Build the command to execute PowerShell script
strPS1File = objFSO.BuildPath(strCurrentDir, "PowerShell-Script-Runner.ps1")
strCommand = "powershell.exe -ExecutionPolicy Bypass -File """ & strPS1File & """"

' Run the PowerShell script
objShell.Run strCommand, 0

' Clean exit
Set objShell = Nothing
Set objFSO = Nothing

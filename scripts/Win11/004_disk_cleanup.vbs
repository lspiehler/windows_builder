Option Explicit

'running disk cleanup

WScript.Echo "Running Disk Cleanup"

Dim objFSO, objShell, script, scriptdir, outFile, EnableAutoUpdateCheck, EnableJavaUpdate, NotifyDownload, NotifyInstall, wshShell, wshSystemEnv

Set wshShell = CreateObject( "WScript.Shell" )
Set wshSystemEnv = wshShell.Environment( "SYSTEM" )

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Set objShell = CreateObject("Wscript.Shell")

If wshSystemEnv("VIEW") = "TRUE" Then
	WScript.Echo "This is a View desktop. Install required software and then pick up from here."
	objShell.Run "cmd /c pause", ,True
	WScript.Quit
End If

objShell.Run "powershell -command Get-AppxPackage -AllUsers | where-object {$_.IsFramework -eq $False -and $_.SignatureKind -eq 'Store' -and $_.Name -notlike '*Microsoft.WindowsStore*' -and $_.Name -notlike '*Microsoft.WindowsCalculator*' -and $_.Name -notlike '*Microsoft.ScreenSketch*' -and $_.Name -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxPackage", ,True

objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike '*Microsoft.WindowsStore*' -and $_.DisplayName -notlike '*Microsoft.WindowsCalculator*' -and $_.DisplayName -notlike '*Microsoft.ScreenSketch*' -and $_.DisplayName -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxProvisionedPackage -Online -AllUsers", ,True

objShell.Run "powershell -command Get-AppxPackage -AllUsers | where-object {$_.IsFramework -eq $False -and $_.SignatureKind -eq 'Store' -and $_.Name -notlike '*Microsoft.WindowsStore*' -and $_.Name -notlike '*Microsoft.WindowsCalculator*' -and $_.Name -notlike '*Microsoft.ScreenSketch*' -and $_.Name -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxPackage", ,True

objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike '*Microsoft.WindowsStore*' -and $_.DisplayName -notlike '*Microsoft.WindowsCalculator*' -and $_.DisplayName -notlike '*Microsoft.ScreenSketch*' -and $_.DisplayName -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxProvisionedPackage -Online -AllUsers", ,True

objShell.Run "powershell -command Get-AppxPackage -AllUsers | where-object {$_.IsFramework -eq $False -and $_.SignatureKind -eq 'Store' -and $_.Name -notlike '*Microsoft.WindowsStore*' -and $_.Name -notlike '*Microsoft.WindowsCalculator*' -and $_.Name -notlike '*Microsoft.ScreenSketch*' -and $_.Name -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxPackage", ,True

objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike '*Microsoft.WindowsStore*' -and $_.DisplayName -notlike '*Microsoft.WindowsCalculator*' -and $_.DisplayName -notlike '*Microsoft.ScreenSketch*' -and $_.DisplayName -notlike '*Microsoft.MicrosoftStickyNotes*' } | Remove-AppxProvisionedPackage -Online -AllUsers", ,True

'objShell.Run "regedit /s " & scriptdir & "\install_files\cleanmgr.reg", ,True

'objShell.Run "cleanmgr /sagerun:1", ,True
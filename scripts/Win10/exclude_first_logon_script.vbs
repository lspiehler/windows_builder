Option Explicit

Dim nextscript, objShell, runnext, objFSO, script, scriptdir, searchboxtaskbarmode, showtaskviewbutton

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Set objShell = WScript.CreateObject("WScript.Shell")

'objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq 'microsoft.windowscommunicationsapps'} | Remove-AppxProvisionedPackage -AllUsers", ,True
'objShell.Run "powershell -command Get-AppxPackage -AllUsers | Where-Object {$_.Name -notlike '*Microsoft.WindowsStore*' } | Remove-AppxPackage -AllUsers", ,True
'objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike '*Microsoft.WindowsStore*' } | Remove-AppxProvisionedPackage -Online -AllUsers", ,True

nextscript = "HKEY_USERS\ntuser.dat\Software\Microsoft\Windows\CurrentVersion\Runonce\RemoveEdge"

'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\RemoveEdge.vbs"" C:\Windows\", ,True

'objShell.Run "cmd /c del C:\Windows\Setup\Scripts\FirstLogon.cmd", ,True

objShell.Run "reg load HKU\ntuser.dat C:\Users\Default\ntuser.dat", ,True

searchboxtaskbarmode = "HKEY_USERS\ntuser.dat\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode"
objShell.RegWrite searchboxtaskbarmode, "0", "REG_DWORD"

showtaskviewbutton = "HKEY_USERS\ntuser.dat\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton"
objShell.RegWrite showtaskviewbutton, "0", "REG_DWORD"

'objShell.RegWrite nextscript, "wscript C:\Windows\RemoveEdge.vbs", "REG_SZ"
objShell.RegWrite nextscript, "wscript \\smhplus.org\NETLOGON\Scripts\RemoveEdge.vbs", "REG_SZ"

objShell.Run "reg delete ""HKEY_USERS\ntuser.dat\Software\Microsoft\Windows\CurrentVersion\Run"" /v OneDriveSetup /f", ,True

objShell.Run "reg unload HKU\ntuser.dat", ,True
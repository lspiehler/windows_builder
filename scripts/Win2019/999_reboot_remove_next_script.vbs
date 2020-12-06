Option Explicit

Dim type2, labordelivery, nicu, scriptdir, objFSO, script, file, uac

Dim objShell
Dim RegLocAutoLogon
Dim keyDefaultDomainName
Dim valDefaultDomainName
Dim keyDefaultUserName
Dim valDefaultUserName
Dim keyDisableCAD
Dim valDisableCAD
Dim keyAutoAdminLogon
Dim valAutoAdminLogon
Dim keyForceAutoLogon
Dim valForceAutoLogon
Dim keyDefaultPassword
Dim valDefaultPassword

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)


Function rebootNow(message)
	Dim objFSO, script, scriptdir, objShell, z

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set script = objFSO.GetFile(WScript.ScriptFullName)
	scriptdir = objFSO.GetParentFolderName(script)
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""", ,True
	objShell.Run "cscript """ & scriptdir & "\exclude_reboot.vbs" & "", ,True
	
	objShell.Run "cmd /c rmdir C:\Windows\setup\scripts /s /q", ,True
	
	While True
		WScript.Echo (message)
		z = WScript.StdIn.ReadLine()
	Wend
End Function

valAutoAdminLogon = "0"
valDefaultUserName = ""
valDefaultPassword = ""

'''
'Define keys and values'
'''
RegLocAutoLogon = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\"
'keyDefaultDomainName = "DefaultDomainName"
'valDefaultDomainName = "[your domain name here]"
keyDefaultUserName = "DefaultUserName"
keyDisableCAD = "DisableCAD"
valDisableCAD = 0
keyAutoAdminLogon = "AutoAdminLogon"
'keyForceAutoLogon = "ForceAutoLogon"
'valForceAutoLogon = "1"
keyDefaultPassword = "DefaultPassword"

Set objShell = CreateObject("WScript.Shell")

'objShell.RegWrite RegLocAutoLogon & _
'keyDefaultDomainName, 1, "REG_SZ"
'objShell.RegWrite RegLocAutoLogon & _
'keyDefaultDomainName, valDefaultDomainName, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyDefaultUserName, 1, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyDefaultUserName, valDefaultUserName, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyDisableCAD, 1, "REG_DWORD"
objShell.RegWrite RegLocAutoLogon & _
keyDisableCAD, valDisableCAD, "REG_DWORD"
objShell.RegWrite RegLocAutoLogon & _
keyAutoAdminLogon, 1, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyAutoAdminLogon, valAutoAdminLogon, "REG_SZ"
'objShell.RegWrite RegLocAutoLogon & _
'keyForceAutoLogon, 1, "REG_SZ"
'objShell.RegWrite RegLocAutoLogon & _
'keyForceAutoLogon, valForceAutoLogon, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyDefaultPassword, 1, "REG_SZ"
objShell.RegWrite RegLocAutoLogon & _
keyDefaultPassword, valDefaultPassword, "REG_SZ"

'objShell.Run "cmd /c mkdir C:\Scripts", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\Printers.vbs"" ""C:\Scripts\""", ,True
'objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /f /v ""Map Printers"" /t REG_SZ /d ""wscript.exe C:\Scripts\Printers.vbs""", ,True

objShell.Run "cmd /c wmic UserAccount where Name='Admin' set PasswordExpires=False", ,True

file = "C:\Windows\System32\Sysprep\autounattend.xml"

If objFSO.FileExists(file) Then
	objFSO.DeleteFile(file), True
	'WScript.Echo "File exists"
End If

uac = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA"
objShell.RegWrite uac, "1", "REG_DWORD"

objShell.Run "cmd /c NetSh Advfirewall set allprofiles state on", ,True

rebootNow("Wait while the system reboots...")
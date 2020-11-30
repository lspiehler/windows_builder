Option Explicit

Dim objShell, objFSO, script, scriptdir, xmlhttp, mac, usertoken, apitoken, strComputer, objWMIService, objItem, colItems

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Function rebootNow(message)
	Dim objFSO, script, scriptdir, objShell, z

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set script = objFSO.GetFile(WScript.ScriptFullName)
	scriptdir = objFSO.GetParentFolderName(script)
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""" & " /runnext:""" & scriptdir & "\_run_all.vbs /last:" & WScript.ScriptName & "", ,True
	objShell.Run "shutdown /r /t 0", ,True
	
	While True
		WScript.Echo (message)
		z = WScript.StdIn.ReadLine()
	Wend
End Function

'rebootNow("good night")
'WScript.Quit

Function getMACs
	Dim strComputer, objWMIService, colItems, strMACs, objItem

	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

	Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled = True")

	strMACs = ""

	For Each objItem in colItems
		strMACs = strMACs & ",""" & objItem.MACAddress & """"
	Next

	getMACs = Right(strMACs, Len(strMACs)-1)
End Function

Set objShell = CreateObject("Wscript.Shell")

'mac = getMACs
'usertoken = "MDFjOWYwYzE2N2E5NmM4NDRmNWNlNzJjODAzNzNhMDZjZjQ3YjcxNzVhMDQxMmYzMDcwNzBkOTY5MmQzMjQ2ZDAzZmE4ZmNlODFmNjJmN2Q1YmU2NWI5NGU1OTViZTc2YmU5Y2M2MDk2YTU2MTkzNjViZDZiMWUzODg2MzJjOWQ="
'apitoken = "NDRiZTcxZmNiNjlhMWZiNDcwZjZkYmUxNDlmOTI3MTg1MDg3NTkxOGViNjE2ZjhjZjM2YTk3MmJmNThhMDY2YTBhNGU3MDBkYjJhNmU4ZTQ4NmFmYjAyOWFlMWM3M2Y0ZjY4MGFjZjQyZDRlYjk4ZWYxNTBiZWE4YzE1YmVkMTA="

'Set xmlhttp = Createobject("Microsoft.XmlHttp")

'xmlhttp.Open "PUT","http://fog.smhplus.org/fog/host/76/edit",false
'xmlhttp.setRequestHeader "fog-user-token", usertoken
'xmlhttp.setRequestHeader "fog-api-token", apitoken
'xmlhttp.send "{""macs"": [" & mac & "]}"
'WScript.Echo xmlhttp.responseText

'Set xmlhttp = Createobject("Microsoft.XmlHttp")

'xmlhttp.Open "POST","http://fog.smhplus.org/fog/host/76/task",false
'xmlhttp.setRequestHeader "fog-user-token", usertoken
'xmlhttp.setRequestHeader "fog-api-token", apitoken
'xmlhttp.send "{""taskTypeID"":2, ""shutdown"":true}"
'WScript.Echo xmlhttp.responseText
'WScript.Quit

objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\autounattend.xml"" C:\Windows\System32\sysprep\", ,True
'objShell.Run "cmd /c copy /Y """ & scriptdir & "\install_files\unattended\autounattendEFI.xml"" C:\Windows\System32\sysprep\autounattend.xml", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\FirstLogon.cmd"" C:\Windows\setup\scripts\", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\offline_drivers.vbs"" C:\Windows\setup\scripts\", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\wireless_config.vbs"" C:\Windows\setup\scripts\", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\SMH_Employee.xml"" C:\Windows\setup\scripts\", ,True

'objShell.Run "powershell -command Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notlike '*Microsoft.WindowsStore*' } | Remove-AppxProvisionedPackage -Online -AllUsers & Read-Host", ,True

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_DiskPartition WHERE Index = 0 AND DiskIndex = 0",,48)
For Each objItem in colItems
    If InStr(objItem.Type, "GPT") > 0 Then
		'objShell.Run "diskpart /s """ & scriptdir & "\install_files\diskpart_shrink_efi.txt""", ,True
		objShell.Run "cmd /c copy /Y ""C:\Windows\setup\scripts\autounattend.xml"" C:\Windows\System32\sysprep\autounattend.xml", ,True
		objShell.Run "cmd /c rmdir C:\Windows\setup\scripts /s /q", ,True
		'objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /reboot /unattend:autounattend.xml", ,True
		objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /shutdown /unattend:autounattend.xml", ,True
	Else
		'objShell.Run "diskpart /s """ & scriptdir & "\install_files\diskpart_shrink.txt""", ,True
		'WScript.Echo "here"
		'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\autounattend.xml"" C:\Windows\System32\sysprep\", ,True
		objShell.Run "cmd /c copy /Y ""C:\Windows\setup\scripts\autounattend.xml"" C:\Windows\System32\sysprep\autounattend.xml", ,True
		objShell.Run "cmd /c rmdir C:\Windows\setup\scripts /s /q", ,True
		objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /reboot /unattend:autounattend.xml", ,True
	End If
Next
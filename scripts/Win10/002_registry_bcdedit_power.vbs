Option Explicit
On Error Resume Next

'disables ipv6 and uac and reboots. 

Function rebootNow(message)
	Dim objFSO, script, scriptdir, objShell, z

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set script = objFSO.GetFile(WScript.ScriptFullName)
	scriptdir = objFSO.GetParentFolderName(script)
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""" & " /runnext:""" & scriptdir & "\_run_all.vbs /last:" & WScript.ScriptName & "", ,True
	objShell.Run "cscript """ & scriptdir & "\exclude_reboot.vbs" & "", ,True
	
	While True
		WScript.Echo (message)
		z = WScript.StdIn.ReadLine()
	Wend
End Function

Dim objShell, strIPv6, uac, actioncenter, objFSO, script, scriptdir, wshShell, wshSystemEnv, cortana, websearch, connectedsearch, windowsstore, ServiceManager, NewUpdateService

Set wshShell = CreateObject( "WScript.Shell" )
Set wshSystemEnv = wshShell.Environment( "SYSTEM" )

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Set objShell = WScript.CreateObject("WScript.Shell")
strIPv6 = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents"
objShell.RegWrite strIPv6, "255", "REG_DWORD"
uac = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA"
objShell.RegWrite uac, "0", "REG_DWORD"

cortana = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana"
objShell.RegWrite cortana, "0", "REG_DWORD"

websearch = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch"
objShell.RegWrite websearch, "1", "REG_DWORD"

connectedsearch = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search\ConnectedSearchUseWeb"
objShell.RegWrite connectedsearch, "0", "REG_DWORD"

windowsstore = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search\RemoveWindowsStore"
objShell.RegWrite windowsstore, "1", "REG_DWORD"

'actioncenter = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\HideSCAHealth"
'objShell.RegWrite actioncenter, "1", "REG_DWORD"

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"" /v EnableLUA /t REG_DWORD /d 0 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"" /v AllowCortana /t REG_DWORD /d 0 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"" /v DisableWebSearch /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"" /v RemoveWindowsStore /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent"" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent"" /v DisableSoftLanding /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer"" /v NoNewAppAlert /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive"" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System"" /v DisableLogonBackgroundImage /t REG_DWORD /d 1 /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"" /v ""\\*\SYSVOL"" /t REG_SZ /d ""RequireMutualAuthentication=0, RequireIntegrity=0, RequirePrivacy=0"" /f", ,True

objShell.Run "reg add ""HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"" /v ""\\*\NETLOGON"" /t REG_SZ /d ""RequireMutualAuthentication=0, RequireIntegrity=0, RequirePrivacy=0"" /f", ,True

objShell.Run "cmd /c bcdedit /set {default} bootstatuspolicy ignoreallfailures", , True

objShell.Run "DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:""D:\sources\sxs""", , True

'objShell.Run "C:\Windows\SysWOW64\cmd.exe /c xcopy /Y """ & scriptdir & "\install_files\AutoItX3.dll"" ""C:\Windows\SysWOW64\""", ,True
'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\AutoItX3_x64.dll"" ""C:\Windows\System32\""", ,True

objShell.Run "cmd /c regsvr32 /s ""C:\Windows\System32\AutoItX3_x64.dll""", ,True
objShell.Run "C:\Windows\SysWOW64\cmd.exe /c regsvr32 /s ""C:\Windows\SysWOW64\AutoItX3.dll""", ,True

objShell.Run "cmd /c NetSh Advfirewall set allprofiles state off", ,True
objShell.Run "reg add ""hklm\system\currentcontrolset\control\terminal server"" /f /v fDenyTSConnections /t REG_DWORD /d 0", ,True

'objShell.Run "cmd /c regedit /s """ & scriptdir & "\install_files\Restore_Windows_Photo_Viewer_ALL_USERS.reg""", ,True

objShell.Run "powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c", , True
objShell.Run "powercfg -h off", , True
objShell.Run "powercfg.exe -change -monitor-timeout-ac 0", , True
objShell.Run "powercfg.exe -change -monitor-timeout-dc 0", , True
objShell.Run "powercfg.exe -change -disk-timeout-ac 0", , True
objShell.Run "powercfg.exe -change -disk-timeout-dc 0", , True
objShell.Run "powercfg.exe -change -standby-timeout-ac 0", , True
objShell.Run "powercfg.exe -change -standby-timeout-dc 0", , True
objShell.Run "powercfg.exe -change -hibernate-timeout-ac 0", , True
objShell.Run "powercfg.exe -change -hibernate-timeout-dc 0", , True

'Give me updates for other Microsoft products when I update Windows
Set ServiceManager = CreateObject("Microsoft.Update.ServiceManager")
ServiceManager.ClientApplicationID = "My App"

'add the Microsoft Update Service, GUID
Set NewUpdateService = ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

rebootNow("Wait while the system reboots...")
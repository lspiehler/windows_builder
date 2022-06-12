Option Explicit

'install adobe reader, disable update checks, accept eula

WScript.Echo "Activating windows via KMS"

Dim objFSO, objShell, script, scriptdir, eula, updates

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Set objShell = CreateObject("Wscript.Shell")
'MAK
objShell.Run "cscript //B C:\Windows\System32\slmgr.vbs /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43", ,True
objShell.Run "cscript //B //nologo C:\Windows\System32\slmgr.vbs /skms 192.168.1.60:1688", ,True
'KMS
'objShell.Run "cscript //B C:\Windows\System32\slmgr.vbs /ipk DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ", ,True
objShell.Run "cscript //B C:\Windows\System32\slmgr.vbs /ato", ,True
'objShell.Run "cscript //B ""C:\Program Files (x86)\Microsoft Office\Office14\OSPP.VBS"" /act", ,True
'objShell.Run "cscript //B ""C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS"" /act", ,True
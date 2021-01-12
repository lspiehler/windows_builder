'sets up the next script to run

Option Explicit
On Error Resume Next

Dim nextscript, objShell, colArgs, runnext

Set colArgs = WScript.Arguments.Named

Set objShell = WScript.CreateObject("WScript.Shell")
nextscript = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\next"

If colArgs.Exists("runnext") Then  
   objShell.RegWrite nextscript, "cmd /c timeout /T 30 & cscript " & colArgs.Item("runnext") & " & pause", "REG_SZ"
Else  
   objShell.RegDelete nextscript
End If
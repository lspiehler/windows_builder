Option Explicit

Dim oShell 
Set oShell = CreateObject("WScript.Shell")

'restart, wait 5 seconds, force running apps to close
oShell.Run "%comspec% /c shutdown /r /t 5 /f", , TRUE
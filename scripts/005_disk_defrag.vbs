Option Explicit

'running disk defrag

WScript.Echo "Running Disk Defragmenter"

Dim objFSO, objShell, script, scriptdir, outFile, EnableAutoUpdateCheck, EnableJavaUpdate, NotifyDownload, NotifyInstall

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Set objShell = CreateObject("Wscript.Shell")

objShell.Run "defrag /C /H /X /V /U", ,True

objShell.Run "defrag /C /H /V /U", ,True
Option Explicit
On Error Resume Next

Dim objShell, objFSO, objStartFolder, objFolder, colFiles, objFile, list, script, scriptdir, colArgs, last, start, wshShell, wshSystemEnv

Set wshShell = CreateObject( "WScript.Shell" )
Set wshSystemEnv = wshShell.Environment( "SYSTEM" )

Set colArgs = WScript.Arguments.Named

If colArgs.Exists("last") Then  
   last = colArgs.Item("last")
Else  
   last = false
End If

'WScript.Echo last

Set objShell = CreateObject("Wscript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

'If wshSystemEnv("VIEW") = "TRUE" Then
'	objShell.Run "cmd /c """ & scriptdir & "\install_files\nircmd.exe"" setdisplay 1280 1024 32", ,True
'End If

'If objFSO.FolderExists("C:\ffmpeg") Then
'	If wshSystemEnv("VIEW") = "TRUE" Then
'		'do nothing
'	Else
'		objShell.Run "cmd /c del ""%TEMP%\bginfo.bmp"" & """ & scriptdir & "\install_files\bginfo.exe"" /timer:0 /silent /NOLICPROMPT", ,False
'		objShell.Run "C:\ffmpeg\bin\ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -rtbufsize 1500M -f dshow -i video=""UScreenCapture"" -c:v libx264 -vf ""scale=trunc(iw/2)*2:trunc(ih/2)*2"" -crf 40 -profile:v baseline -x264opts level=31 -pix_fmt yuv420p -preset ultrafast -f flv rtmp://its-lyas.smhplus.org/view/" & objShell.ExpandEnvironmentStrings("%USERNAME%") & "-" & objShell.ExpandEnvironmentStrings("%COMPUTERNAME%"), 0, False
'	End If
'End If

'If objFSO.FileExists("C:\Windows\Setup\scripts\SetupComplete.cmd") Then
'	objShell.Run "cmd /c del ""C:\Windows\Setup\scripts\SetupComplete.cmd"" && rmdir ""C:\Windows\Setup\scripts""", ,True
'End If

Set list = CreateObject("ADOR.Recordset")
list.Fields.Append "name", 200, 255
list.Fields.Append "path", 200, 255
list.Open

objStartFolder = scriptdir
Set objFolder = objFSO.GetFolder(objStartFolder)
Set colFiles = objFolder.Files

For Each objFile in colFiles
    If (objFile.Type = "VBScript Script File" AND NOT objFile.Name = WScript.ScriptName AND InStr(objFile.Name,"exclude") < 1) Then
		'WScript.Echo "Running " & objFile.Name
		'objShell.Run "wscript """ & objFile.Path & "", ,True
		list.AddNew
		list("name").Value = objFile.Name
		list("path").Value = objFile.Path
		list.Update
	End If
Next

If NOT last = false Then
	start = false
Else
	start = true
End If

list.Sort = "name ASC"
list.MoveFirst
Do Until list.EOF
  'WScript.Echo list("name").Value & vbTab & list("path").Value
	If (start) Then
		WScript.Echo "Running " & list("name").Value
		objShell.Run "cscript """ & list("path").Value & "", ,True
	End If
	If list("name").Value = last Then
		'WScript.Echo "here"
		start = true
	End If
	list.MoveNext
Loop
Function rebootNow(message,finished)
	Dim objFSO, script, scriptdir, objShell, z

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set script = objFSO.GetFile(WScript.ScriptFullName)
	scriptdir = objFSO.GetParentFolderName(script)
	Set objShell = CreateObject("Wscript.Shell")
	If finished Then
		objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""" & " /runnext:""" & scriptdir & "\_run_all.vbs /last:" & WScript.ScriptName & "", ,True
	Else
		objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""" & " /runnext:""" & scriptdir & "\" & WScript.ScriptName & "", ,True
	End If
	objShell.Run "cscript """ & scriptdir & "\exclude_reboot.vbs" & "", ,True
	
	While True
		WScript.Echo (message)
		z = WScript.StdIn.ReadLine()
	Wend
End Function

' "2976978","2977759","2952664" http://www.infoworld.com/article/3040069/microsoft-windows/deja-vu-all-over-again-microsoft-reissues-kb-2952664-kb-2976978-kb-2977759.html http://www.askwoody.com/2016/three-obnoxious-win78-1-updates-return-plus-two-warmed-over-patches-kb-3138612-and-3138615/

' "3154070" breaks API web interface

Set wshShell = CreateObject( "WScript.Shell" )
Set wshSystemEnv = wshShell.Environment( "SYSTEM" )

If wshSystemEnv( "VIEW" ) = "TRUE" Then
	interestingkb = Array("3035583","3012973","2976978","2977759","2952664","3154070","2847311","2855844","2862330","2862335","2863725","2864202","2868038","2884256","2883150","2876284","2887069","2930275","2553154","2553140","2596927","2984939","2956109","2596912","2956106","2956103")
Else
	interestingkb = Array("3035583","3012973","2976978","2977759","2952664","3154070","4464330","4465477")
End If

totaltoinstall = 0

Set wshShell = WScript.CreateObject( "WScript.Shell" )
strComputerName = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )
username = wshShell.ExpandEnvironmentStrings( "%USERNAME%" )

logFile = "C:\Users\" & username & "\Desktop\" & strComputerName & "_patching.txt"

function writeFile(text)	
	Const ForReading = 1, ForWriting = 2, ForAppending = 8
	' The following line contains constants for the OpenTextFile
	' format argument, which is not used in the code below.
	Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
	Dim fso, MyFile, FileName, TextLine

	Set fso = CreateObject("Scripting.FileSystemObject")

	' Open the file for output.
	FileName = logFile

	Set MyFile = fso.OpenTextFile(FileName, ForAppending, True)

	' Write to the file.
	MyFile.WriteLine text
	MyFile.Close

	' Open the file for input.
	'Set MyFile = fso.OpenTextFile(FileName, ForReading)

	' Read from the file and display the results.
	'Do While MyFile.AtEndOfStream <> True
	'	TextLine = MyFile.ReadLine
	'	Document.Write TextLine & "<br />"
	'Loop
	'MyFile.Close
End function

WriteFile("Searching for updates...")
WScript.Echo("Searching for updates...")

'Microsoft magic
    Set updateSession = CreateObject("Microsoft.Update.Session")
    Set updateSearcher = updateSession.CreateupdateSearcher()        
    Set searchResult = updateSearcher.Search("IsInstalled=0 and Type='Software'")
	Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
	Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")
'End Microsoft magic

If searchResult.Updates.Count <> 0 Then 'If updates were found
    'This is where you add your code to send an E-Mail.
    'Send E-mail including a list of updates needed.
	WriteFile(vbCrLf & "Adding the following approved updates:")
	WScript.Echo(vbCrLf & "Adding the following approved updates:")
    'This is how you can list the title of each update that was found.
    'You could include the list in the body of your E-Mail.
    For i = 0 To searchResult.Updates.Count - 1
        Set update = searchResult.Updates.Item(i)
        'WScript.Echo update.Title
		Set articleids = update.KBArticleIDs
		For j = 0 To articleids.Count - 1
			found = false
			For k = 0 To UBound(interestingkb)+1 - 1
				If(interestingkb(k)=articleids(j)) Then
					If(found=false) Then
						'WScript.Echo articleids(j) & " - " & i
						'WScript.Echo update.Title
						found = true
					Else
						found = true
					End If
				End If
			Next
			If(found=false) Then 'if false do all except interesting KBs if true only include interesting KBs
				totaltoinstall = totaltoinstall + 1
				WriteFile(update.Title)
				WScript.Echo(update.Title)
				updatesToDownload.Add(update)
				If update.EulaAccepted = False Then
					WriteFile("Accepting EULA for " & articleids(j) & ".")
					WScript.Echo("Accepting EULA for " & articleids(j) & ".")
					update.AcceptEula
				End If
				'WScript.Echo update.Title
				updatesToInstall.Add(update)
			End If
		Next
    Next
Else
	WriteFile("No updates found. This system is completely up to date.")
	WScript.Echo("No updates found. This system is completely up to date.")
	rebootNow "Wait while the system reboots...",true
End If

If totaltoinstall < 1 Then
	WriteFile(vbCrLf & "The system has pending microsoft updates, but they were either not in the approved list or the only ones found were in the denied list, depending on the configuration.")
	WScript.Echo(vbCrLf & "The system has pending microsoft updates, but they were either not in the approved list or the only ones found were in the denied list, depending on the configuration.")
	rebootNow "Wait while the system reboots...",true
End If

WriteFile(vbCrLf & "Downloading Updates...")
WScript.Echo(vbCrLf & "Downloading Updates...")
Set downloader = updateSession.CreateUpdateDownloader() 
downloader.Updates = updatesToDownload
downloader.Download()

WriteFile(vbCrLf & "Installing Updates...")
WScript.Echo(vbCrLf & "Installing Updates...")
Set installer = updateSession.CreateUpdateInstaller()
installer.Updates = updatesToInstall
Set installationResult = installer.Install()

'Output results of install
WScript.Echo(vbCrLf & "Installation Result: " & installationResult.ResultCode )
WriteFile(vbCrLf & "Installation Result: " & installationResult.ResultCode )
'installationResult.ResultCode 
WriteFile(vbCrLf & "Reboot Required: " & installationResult.RebootRequired)
WScript.Echo(vbCrLf & "Reboot Required: " & installationResult.RebootRequired)
'installationResult.RebootRequired & vbCRLF 
WriteFile(vbCrLf & "Listing of updates installed and individual installation results:")
WScript.Echo(vbCrLf & "Listing of updates installed and individual installation results:")

For I = 0 to updatesToInstall.Count - 1
	WriteFile(I + 1 & "> " & updatesToInstall.Item(i).Title & ": " & installationResult.GetUpdateResult(i).ResultCode)
	WScript.Echo(I + 1 & "> " & updatesToInstall.Item(i).Title & ": " & installationResult.GetUpdateResult(i).ResultCode)
Next

rebootNow "Wait while the system reboots...",false
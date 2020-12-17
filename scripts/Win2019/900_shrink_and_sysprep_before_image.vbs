Option Explicit

Dim objShell, objFSO, script, scriptdir, xmlhttp, mac, usertoken, apitoken, strComputer, objWMIService, objItem, colItems

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    '
    ' Returns:
    ' the [string] value for the specified key in the specified section
    '
    ' CAVEAT:     Will return a space if key exists but value is blank
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )

            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )

                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        WScript.Echo strFilePath & " doesn't exists. Exiting..."
        Wscript.Quit 1
    End If
End Function

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

If UCase(ReadIni(scriptdir & "\build.ini", "installer", "sysprep")) = "FALSE" Then
	objShell.Run "wscript """ & scriptdir & "\999_reboot_remove_next_script.vbs""", ,True
	WScript.Quit
End If

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
		objShell.Run "cmd /c del C:\Windows\setup\scripts\FirstLogon.cmd", ,True
		objShell.Run "cmd /c move C:\Windows\setup\scripts\SecondLogon.cmd C:\Windows\setup\scripts\FirstLogon.cmd", ,True
		'objShell.Run "cmd /c rmdir C:\Windows\setup\scripts /s /q", ,True
		objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /"& ReadIni(scriptdir & "\build.ini", "installer", "sysprepaction") &" /unattend:autounattend.xml", ,True
		'objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /shutdown /unattend:autounattend.xml", ,True
	Else
		'objShell.Run "diskpart /s """ & scriptdir & "\install_files\diskpart_shrink.txt""", ,True
		'WScript.Echo "here"
		'objShell.Run "cmd /c xcopy /Y """ & scriptdir & "\install_files\unattended\autounattend.xml"" C:\Windows\System32\sysprep\", ,True
		objShell.Run "cmd /c del C:\Windows\setup\scripts\FirstLogon.cmd", ,True
		objShell.Run "cmd /c move C:\Windows\setup\scripts\SecondLogon.cmd C:\Windows\setup\scripts\FirstLogon.cmd", ,True
		objShell.Run "cmd /c copy /Y ""C:\Windows\setup\scripts\autounattend.xml"" C:\Windows\System32\sysprep\autounattend.xml", ,True
		'objShell.Run "cmd /c rmdir C:\Windows\setup\scripts /s /q", ,True
		objShell.Run "cmd /c cd C:\Windows\System32\sysprep & sysprep.exe /oobe /generalize /"& ReadIni(scriptdir & "\build.ini", "installer", "sysprepaction") &" /unattend:autounattend.xml", ,True
	End If
Next
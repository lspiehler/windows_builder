Option Explicit
'On Error Resume Next

Dim imagename, objFSO, script, scriptdir, iso, cdrom, efi, argument, hypervisor, boot, imageindex, osname, arch, args, arg, argstr

Set args = Wscript.Arguments

For Each arg In args
	argstr = argstr & " " & arg
Next

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

imagename = ReadIni(scriptdir & "\build.ini", "installer", "name")

Function forceUAC
	Dim objShell

	If WScript.Arguments.Named.Item("uac") = "" Then
		'WScript.Echo "No UAC"
		Set objShell = CreateObject("Shell.Application")
		objShell.ShellExecute "cscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & argstr & " /uac:true", "", "runas", 1
		WScript.Quit
	End If
End Function

Function forceCScriptExecution
    Dim Arg, Str
    If Not LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" Then
        CreateObject( "WScript.Shell" ).Run("cscript //nologo """ & WScript.ScriptFullName & """" & argstr)
        WScript.Quit
    End If
End Function

forceUAC()
forceCScriptExecution()

Function getISO()
	Dim directory, files, file

	Set directory = objFSO.getFolder( scriptdir & "\ISO"  )
	set files = directory.Files
	For Each file in files
		If InStr(file.name, ".ISO") > 0 Then
			getISO = scriptdir & "\ISO\" & file.name
			Exit Function
		End If
	Next
	getISO = ""

End Function

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

Function copyFiles(src, dst)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "robocopy " & src & " """ & dst & """ /E", ,True
	objShell.Run "attrib -r """ & dst & "\*.*"" /S /D", ,True
End Function

Function findDisk()
	Dim strComputer, objWMIService, colItems, objItem

	strComputer = "."
	Set objWMIService = GetObject(_
		"winmgmts:\\" & strComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery( _
		"Select * from Win32_CDROMDrive WHERE Name = 'Microsoft Virtual DVD-ROM'")
	For Each objItem in colItems
		findDisk = objItem.Drive
		Exit Function
	Next
	findDisk = ""
End Function

Function mountDisk(path)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "powershell -command Mount-DiskImage -ImagePath """ & path & """", ,True
End Function

Function unmountDisk(path)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "powershell -command Dismount-DiskImage -ImagePath """ & path & """", ,True
End Function

Function removeISOBuild(path)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "cmd /c rmdir /S /Q """ & path & """", ,True
	objShell.Run "cmd /c mkdir """ & path & """", ,True
End Function

Function mountWIM(wim, dir)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	'WScript.Echo "dism /Mount-Wim /WimFile:""" & wim & """ /Index:1 /MountDir:""" & dir & """"
	objShell.Run "cmd /c mkdir """ & dir & """", ,True
	objShell.Run "dism /Mount-Wim /WimFile:""" & wim & """ /Index:" & imageindex & " /MountDir:""" & dir & """" , ,True	
End Function

Function addDriversToWIM(dir)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	'WScript.Echo "dism /Mount-Wim /WimFile:""" & wim & """ /Index:1 /MountDir:""" & dir & """"
	'objShell.Run "cmd /c mkdir """ & dir & """", ,True
	objShell.Run "dism /Image:""" & dir & """ /Add-Driver /Driver:""" & scriptdir & "\drivers\" & osname & "\" & arch & """ /Recurse" , ,True	
End Function

Function cleanupWIM(dir)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	'WScript.Echo "dism /Mount-Wim /WimFile:""" & wim & """ /Index:1 /MountDir:""" & dir & """"
	objShell.Run "cmd /c mkdir """ & dir & """", ,True
	objShell.Run "dism /Image:""" & dir & """ /Cleanup-Image /startComponentCleanup /ResetBase" , ,True	
End Function

Function unmountWIM(dir)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "dism /Unmount-Wim /MountDir:""" & dir & """ /Commit" , ,True	
End Function

Function splitImage()
	Dim objShell, fso

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "Dism /Split-Image /ImageFile:""" & scriptdir & "\Build_ISO\sources\install.wim"" /SWMFile:""" & scriptdir & "\Build_ISO\sources\install.swm"" /FileSize:3800" , ,True
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	fso.DeleteFile(scriptdir & "\Build_ISO\sources\install.wim")
	
End Function

Function copySetupFiles(setupdir)
	Dim objShell, fso, folder, files, item, sourcexml
	
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "cmd /c mkdir """ & setupdir & "\Scripts""", ,True
	objShell.Run "cmd /c mkdir """ & scriptdir & "\Build_ISO\Drivers""", ,True
	
	Set fso = CreateObject("Scripting.FileSystemObject")

	Set folder = fso.GetFolder(scriptdir & "\scripts\" & osname)
	Set files = folder.Files
	
	For each item In files
		'WScript.Echo item.Path
		'WScript.Echo item.Name
		fso.CopyFile item.Path, setupdir & "\Scripts\" & item.Name, true
	Next
	
	If fso.FolderExists(scriptdir & "\drivers\install\" & osname & "\" & arch) Then
		Set folder = fso.GetFolder(scriptdir & "\drivers\install\" & osname & "\" & arch)
		Set files = folder.Files
		
		For each item In files
			'WScript.Echo item.Path
			'WScript.Echo item.Name
			fso.CopyFile item.Path, scriptdir & "\Build_ISO\Drivers\" & item.Name, true
		Next
	End If

	objShell.Run "xcopy """ & scriptdir & "\build.ini"" """ & setupdir & "\Scripts\"" /Y", ,True
	If efi Then
		'WScript.Echo "copy """ & scriptdir & "\autounattendEFI.xml"" """ & scriptdir & "\Build_ISO\autounattend.xml"" /Y"
		'objShell.Run "cmd /c copy """ & scriptdir & "\autounattend\" & osname & "\autounattendEFI.xml"" """ & scriptdir & "\Build_ISO\autounattend.xml"" /Y", ,True
		'objShell.Run "cmd /c copy """ & scriptdir & "\autounattend\" & osname & "\autounattendEFI.xml"" """ & setupdir & "\Scripts\autounattend.xml"" /Y", ,True
		sourcexml = scriptdir & "\autounattend\" & osname & "\autounattendEFI.xml"
	Else
		sourcexml = scriptdir & "\autounattend\" & osname & "\autounattend.xml"
		'objShell.Run "xcopy """ & scriptdir & "\autounattend\" & osname & "\autounattend.xml"" """ & scriptdir & "\Build_ISO"" /Y", ,True
		'objShell.Run "xcopy """ & scriptdir & "\autounattend\" & osname & "\autounattend.xml"" """ & setupdir & "\Scripts\"" /Y", ,True
	End If
	
	autoUnattendTemplate sourcexml, scriptdir & "\Build_ISO\autounattend.xml"
	autoUnattendTemplate sourcexml, setupdir & "\Scripts\autounattend.xml"
	
End Function

Function autoUnattendTemplate(source, destination)

	Dim objFSO, s, d, line, var, vars
	
	vars = Array("imageindex", "name", "fullname", "orgname", "productkey", "displayname", "adminuser", "adminpass", "uilanguage", "inputlocale", "systemlocale", "userlocale", "uilanguage", "uilanguagefallback", "timezone")

	Set objFSO = CreateObject( "Scripting.FileSystemObject" )

	Set s = objFSO.OpenTextFile(source)
	Set d = objFSO.CreateTextFile(destination,True)

	Do Until s.AtEndOfStream
		line = s.ReadLine
		For Each var In vars
			'WScript.Echo "{{" & var & "}}"
			If InStr(line, "{{" & var & "}}") >= 1 Then
				'WScript.Echo "Yep"
				line = Replace(line, "{{" & var & "}}", ReadIni("C:\Users\Lyas\Documents\windows_builder\build.ini", "installer", var))
				Exit For
			Else
				'WScript.Echo "Nope"
			End If
		Next
		'WScript.Echo line
		d.Write line & vbCrlf
	Loop
	s.Close
	d.Close

End Function

Function createISO()
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "cmd /c del /Q """ & scriptdir & "\" & imagename & ".iso""", ,True
	objShell.Run "cmd /c del /Q """ & scriptdir & "\" & imagename & ".mds""", ,True
	'objShell.Run "wscript """ & scriptdir & "\click_imgburn_prompt.vbs""", ,False
	'objShell.Run """C:\Program Files (x86)\ImgBurn\ImgBurn.exe"" /MODE BUILD /BUILDMODE IMAGEFILE /SRC """ & scriptdir & "\Build_ISO\"" /DEST """ & scriptdir & "\" & imagename & ".iso"" /FILESYSTEM UDF /VOLUMELABEL ""Windows 10 x64"" /PRESERVEFULLPATHNAMES NO /RECURSESUBDIRECTORIES YES /INCLUDEHIDDENFILES YES /INCLUDESYSTEMFILES YES /BOOTEMUTYPE 0 /BOOTIMAGE """ & scriptdir & "\Build_ISO\efi\microsoft\boot\cdboot.efi"" /BOOTDEVELOPERID ""Microsoft Corporation"" /BOOTLOADSEGMENT 07C0 /BOOTSECTORSTOLOAD 8 /VERIFY NO /START /CLOSE", ,True
	'objShell.Run """C:\Program Files (x86)\ImgBurn\ImgBurn.exe"" /MODE BUILD /BUILDMODE IMAGEFILE /SRC """ & scriptdir & "\Build_ISO\"" /DEST """ & scriptdir & "\" & imagename & ".iso"" /FILESYSTEM UDF /VOLUMELABEL ""Windows 10 x64"" /PRESERVEFULLPATHNAMES NO /RECURSESUBDIRECTORIES YES /INCLUDEHIDDENFILES YES /INCLUDESYSTEMFILES YES /BOOTEMUTYPE 0 /BOOTIMAGE """ & scriptdir & "\Build_ISO\boot\etfsboot.com"" /BOOTDEVELOPERID ""Microsoft Corporation"" /BOOTLOADSEGMENT 07C0 /BOOTSECTORSTOLOAD 8 /VERIFY NO /START /CLOSE", ,True
	objShell.Run """" & scriptdir & "\mkisofs\mingw\mkisofs.exe"" -iso-level 4 -l -R -UDF -D -volid ""UEFI_BIOS_BOOT"" -b boot/etfsboot.com -no-emul-boot -boot-load-size 8 -hide boot.catalog -eltorito-alt-boot -eltorito-platform efi -no-emul-boot -b efi/microsoft/boot/efisys_noprompt.bin -o """ & scriptdir & "\" & imagename & ".iso"" """ & scriptdir & "\Build_ISO""", ,True
End Function

Function startVMBuild(hypervisor)
	Dim objShell
	
	Set objShell = CreateObject("Wscript.Shell")

	If hypervisor = "vmware" Then
		objShell.Run "C:\Windows\SYSWOW64\WindowsPowerShell\v1.0\powershell.exe -executionpolicy unrestricted -command "". '" & scriptdir & "\vm_build\vmware\vmware_build.ps1'""", ,False
	ElseIf hypervisor = "virtualbox" Then
		'WScript.Echo """" & scriptdir & "\vm_build\virtualbox\virtualbox_build.bat"" ""Windows10"" """ & scriptdir & "\" & imagename & ".iso"""
		objShell.Run """" & scriptdir & "\vm_build\virtualbox\virtualbox_build.vbs"" /name:""" & imagename & """ /osname:""" & osname & """ /arch:""" & arch & """ /iso:""" & scriptdir & "\" & imagename & ".iso""", ,False
	End If
End Function

osname = ReadIni(scriptdir & "\build.ini", "installer", "osname")
iso = ReadIni(scriptdir & "\build.ini", "installer", "iso")
boot = ReadIni(scriptdir & "\build.ini", "installer", "boot")
arch = ReadIni(scriptdir & "\build.ini", "installer", "arch")
imageindex = ReadIni(scriptdir & "\build.ini", "installer", "imageindex")
hypervisor = ReadIni(scriptdir & "\build.ini", "hypervisor", "type")

efi = false
'If WScript.Arguments(1) = "EFI" Then
'	efi = true
'End If

If UCase(boot) = "EFI" OR UCase(boot) = "UEFI" Then
	efi = true
End If

'copySetupFiles scriptdir & "\WimMount\Windows\Setup"
'createISO()
'startVMBuild(hypervisor)
'WScript.Quit

If objFSO.FileExists(iso) Then
	mountDisk(iso)
	cdrom = findDisk()
	removeISOBuild scriptdir & "\Build_ISO"
	'WScript.Quit
	If NOT cdrom = "" Then
		'WScript.Echo "copy files"
		copyFiles cdrom & "\", scriptdir & "\Build_ISO"
		unmountDisk(iso)
		mountWIM scriptdir & "\Build_ISO\sources\install.wim", scriptdir & "\WimMount"
		copySetupFiles scriptdir & "\WimMount\Windows\Setup"
		addDriversToWIM scriptdir & "\WimMount"
		'cleanupWIM scriptdir & "\WimMount"
		unmountWIM scriptdir & "\WimMount"
		splitImage()
		createISO()
		startVMBuild(hypervisor)
	Else
		WScript.Echo "Either more than one or no virtual cdroms were found"
		WScript.Quit
	End If
Else
	WScript.Echo "Could not find the windows 10 ISO"
	WScript.Quit
End If
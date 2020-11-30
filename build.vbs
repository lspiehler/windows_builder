Option Explicit
'On Error Resume Next

Dim objFSO, script, scriptdir, iso, cdrom, efi, argument

Const imagename = "Win10Build"
	
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

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
	objShell.Run "dism /Mount-Wim /WimFile:""" & wim & """ /Index:3 /MountDir:""" & dir & """" , ,True	
End Function

Function addDriversToWIM(dir)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")
	'WScript.Echo "dism /Mount-Wim /WimFile:""" & wim & """ /Index:1 /MountDir:""" & dir & """"
	'objShell.Run "cmd /c mkdir """ & dir & """", ,True
	objShell.Run "dism /Image:""" & dir & """ /Add-Driver /Driver:""\\deploy\push\install\win10\install_files\drivers"" /Recurse" , ,True	
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

Function copySetupFiles(setupdir)
	Dim objShell, fso, folder, files, item
	
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "cmd /c mkdir """ & setupdir & "\Scripts""", ,True
	
	Set fso = CreateObject("Scripting.FileSystemObject")

	Set folder = fso.GetFolder(scriptdir & "\scripts")
	Set files = folder.Files
	
	For each item In files
		'WScript.Echo item.Path
		'WScript.Echo item.Name
		fso.CopyFile item.Path, setupdir & "\Scripts\" & item.Name, true
	Next

	objShell.Run "xcopy """ & scriptdir & "\FirstLogon.cmd"" """ & setupdir & "\Scripts\"" /Y", ,True
	If efi Then
		'WScript.Echo "copy """ & scriptdir & "\autounattendEFI.xml"" """ & scriptdir & "\Build_ISO\autounattend.xml"" /Y"
		objShell.Run "cmd /c copy """ & scriptdir & "\autounattend\Win10\autounattendEFI.xml"" """ & scriptdir & "\Build_ISO\autounattend.xml"" /Y", ,True
		objShell.Run "cmd /c copy """ & scriptdir & "\autounattend\Win10\autounattendEFI.xml"" """ & setupdir & "\Scripts\autounattend.xml"" /Y", ,True
	Else
		objShell.Run "xcopy """ & scriptdir & "\autounattend\Win10\autounattend.xml"" """ & scriptdir & "\Build_ISO"" /Y", ,True
		objShell.Run "xcopy """ & scriptdir & "\autounattend\Win10\autounattend.xml"" """ & setupdir & "\Scripts\"" /Y", ,True
	End If
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
		objShell.Run """" & scriptdir & "\vm_build\virtualbox\virtualbox_build.bat"" ""Windows10"" """ & scriptdir & "\" & imagename & ".iso""", ,False
	End If
End Function

'iso = getISO()
efi = false
'If WScript.Arguments(1) = "EFI" Then
'	efi = true
'End If

For Each argument in WScript.Arguments
	If UCase(argument) = "EFI" OR UCase(argument) = "UEFI" Then
		efi = true
	End If
Next

'copySetupFiles scriptdir & "\WimMount\Windows\Setup"
'WScript.Quit

If objFSO.FileExists(WScript.Arguments(0)) Then
	mountDisk(WScript.Arguments(0))
	cdrom = findDisk()
	removeISOBuild scriptdir & "\Build_ISO"
	'WScript.Quit
	If NOT cdrom = "" Then
		'WScript.Echo "copy files"
		copyFiles cdrom & "\", scriptdir & "\Build_ISO"
		unmountDisk(WScript.Arguments(0))
		mountWIM scriptdir & "\Build_ISO\sources\install.wim", scriptdir & "\WimMount"
		copySetupFiles scriptdir & "\WimMount\Windows\Setup"
		addDriversToWIM scriptdir & "\WimMount"
		'cleanupWIM scriptdir & "\WimMount"
		unmountWIM scriptdir & "\WimMount"
		createISO()
		startVMBuild("virtualbox")
	Else
		WScript.Echo "Either more than one or no virtual cdroms were found"
		WScript.Quit
	End If
Else
	WScript.Echo "Could not find the windows 10 ISO"
	WScript.Quit
End If
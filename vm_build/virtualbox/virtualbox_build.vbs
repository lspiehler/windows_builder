Dim objShell, ostype, objFSO, script, scriptdir, imagename, osname, iso, boot, arch, vmdir, disksize, cpu, memory, firmware, buildisofile, buildiso

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)
	
Set objShell = CreateObject("Wscript.Shell")

imagename = ReadIni(scriptdir & "\..\..\build.ini", "installer", "name")
osname = ReadIni(scriptdir & "\..\..\build.ini", "installer", "osname")
iso = ReadIni(scriptdir & "\..\..\build.ini", "installer", "iso")
boot = ReadIni(scriptdir & "\..\..\build.ini", "installer", "boot")
arch = ReadIni(scriptdir & "\..\..\build.ini", "installer", "arch")
vmdir = ReadIni(scriptdir & "\..\..\build.ini", "hypervisor", "vmdir")
disksize = ReadIni(scriptdir & "\..\..\build.ini", "hypervisor", "disksize")
cpu = ReadIni(scriptdir & "\..\..\build.ini", "hypervisor", "cpu")
memory = ReadIni(scriptdir & "\..\..\build.ini", "hypervisor", "memory")

Set buildisofile = objFSO.GetFile(scriptdir & "\..\..\" & imagename & ".iso")

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

If boot = "efi" Then
	firmware = "efi"
Else
	firmware = "BIOS"
End If

If osname = "Win10" Then
	If arch = "64" Then
		ostype = "Windows10_64"
	Else
		ostype = "Windows10"
	End If
ElseIf osname = "Win2019" Then
	If arch = "64" Then
		ostype = "Windows2019_64"
	Else
		ostype = "Windows2019_64"
	End If
Else 
	ostype = "Windows10_64"
End If

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" createvm --name """ & imagename & """ --ostype """ & ostype & """ --register", ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" createmedium disk --size " & disksize & " --filename """ & vmdir & "\" & imagename & "\" & imagename & ".vdi""", ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" modifyvm """ & imagename & """ --memory " & memory & " --nic1 nat --graphicscontroller vboxsvga --vram 128 --pae off --audiocontroller hda --usbohci on --firmware " & firmware & " --cpus " & cpu, ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" storagectl """ & imagename & """ --name ""SATA"" --add sata --controller IntelAHCI --portcount 2 --bootable on", ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" storageattach """ & imagename & """ --storagectl ""SATA"" --device 0 --port 0 --type hdd --medium """ & vmdir & "\" & imagename & "\" & imagename & ".vdi""", ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" storageattach """ & imagename & """ --storagectl ""SATA"" --device 0 --port 1 --type dvddrive --medium """ & buildisofile.Path & """", ,True

objShell.Run """C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"" startvm """ & imagename & """ --type gui", ,True
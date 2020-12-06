Option Explicit

Dim hostname, kacehostname, strUser, strPassword, title, message, createhostname, objShell, objFSO, script, scriptdir, foghostname

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set script = objFSO.GetFile(WScript.ScriptFullName)
scriptdir = objFSO.GetParentFolderName(script)

strUser = "Admin"
strPassword = "adminpassword"

Function processDrives
	Dim ComputerName, wmiDiskDrives, wmiServices, wmiDiskDrive, query, wmiDiskPartitions, wmiDiskPartition, wmiLogicalDisks, wmiLogicalDisk

	ComputerName = "."
	Set wmiServices  = GetObject ( _
		"winmgmts:{impersonationLevel=Impersonate}!//" _
		& ComputerName)
	' Get physical disk drive
	Set wmiDiskDrives =  wmiServices.ExecQuery ( _
		"SELECT Caption, DeviceID, Index, Model FROM Win32_DiskDrive")

	For Each wmiDiskDrive In wmiDiskDrives
		'WScript.Echo "Disk drive Caption: " _
		'    & wmiDiskDrive.Caption _ 
		'    & VbNewLine & "DeviceID: " _
		'    & " (" & wmiDiskDrive.DeviceID & ")"

		'Use the disk drive device id to
		' find associated partition
		query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" _
			& wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"    
		Set wmiDiskPartitions = wmiServices.ExecQuery(query)

		For Each wmiDiskPartition In wmiDiskPartitions
			'Use partition device id to find logical disk
			Set wmiLogicalDisks = wmiServices.ExecQuery _
				("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" _
				 & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 

			For Each wmiLogicalDisk In wmiLogicalDisks
				If wmiLogicalDisk.DeviceID = "C:" Then
					'WScript.Echo wmiDiskDrive.Index
					processDrives = wmiDiskDrive.Index
				End If
			Next      
		Next
	Next
End Function

Function createDiskpartScript(index)
	Dim WshShell, temp, objFSO, objFile, strComputer, objWMIService, objItem, colItems
	
	Set wshShell = CreateObject( "WScript.Shell" )
	temp = WshShell.ExpandEnvironmentStrings("%TEMP%") + "\diskpart_extend.txt"
	Set objFSO=CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.CreateTextFile(temp,True)
	
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery("Select * from Win32_DiskPartition WHERE Index = 0 AND DiskIndex = 0",,48)
	For Each objItem in colItems
		If InStr(objItem.Type, "GPT") > 0 Then
			objFile.Write "select disk " & index & vbCrLf & "select partition 4" & vbCrLf & "extend"
		Else
			objFile.Write "select disk " & index & vbCrLf & "select partition 2" & vbCrLf & "extend"
		End If
	Next
	objFile.Close
	
	createDiskpartScript = temp
End Function

Function setHostname(newComputerName)
	Dim objComputer, strComputer, ErrCode
	
	strComputer = getHostname
	
	Set objComputer = GetObject("winmgmts:{impersonationLevel=Impersonate}!\\" & _
    strComputer & "\root\cimv2:Win32_ComputerSystem.Name='" & _
    strComputer & "'")
	
	ErrCode = objComputer.Rename(newComputerName, strPassword, strUser)
    If ErrCode = 0 Then
        WScript.Echo "Computer renamed correctly."
    Else
        WScript.Echo "Eror changing computer name. Error code: " & ErrCode
    End If
End Function

Function rebootNow(message)
	Dim objFSO, script, scriptdir, objShell, z

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set script = objFSO.GetFile(WScript.ScriptFullName)
	scriptdir = objFSO.GetParentFolderName(script)
	Set objShell = CreateObject("Wscript.Shell")
	objShell.Run "wscript """ & scriptdir & "\exclude_next_script.vbs""" & " /runnext:""" & scriptdir & "\_run_all.vbs /last:" & WScript.ScriptName & "", ,True
	objShell.Run "cscript """ & scriptdir & "\exclude_reboot.vbs" & "", ,True
	
	While True
		WScript.Echo (message)
		z = WScript.StdIn.ReadLine()
	Wend
End Function

Function getHostname()
	Dim objNetwork

	Set objNetwork = CreateObject("WScript.Network")
	getHostname = objNetwork.ComputerName
End Function

Set objShell = CreateObject("Wscript.Shell")
objShell.Run "cmd /c timeout /T 60", ,True
'objShell.Popup("before")
objShell.Run "diskpart /s """ & createDiskpartScript(processDrives) & "", ,True
objShell.Run "diskpart /s """ & createDiskpartScript(processDrives) & "", ,True
'objShell.Popup("after")
'objShell.Run "cmd /c del /F C:\Windows\System32\sysprep\unattend.xml", ,True
objShell.Run "cmd /c net start w32time && w32tm /resync /force", ,True

title = "Hostname"
message = "Please enter a hostname:"
createhostname = InputBox(message, title)
setHostname(createhostname)
rebootNow("Wait while the system reboots...")
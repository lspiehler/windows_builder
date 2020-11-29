Import-Module VMware.VimAutomation.Core

$name = "Win10Build"

$path = (Split-Path $script:MyInvocation.MyCommand.Path) + '\' + $name + '.iso'

Connect-VIServer -user domain\username -Password "password" vcenterfqdn

$oldvm = Get-VM $name

If ($oldvm.count -eq 1) {
	$oldvm[0] | Stop-VM -Kill -Confirm:$False
	$oldvm[0] | Remove-VM -DeletePermanently -Confirm:$False
}

$Datastore = "ISO"
Get-Datastore $Datastore | New-DatastoreDrive -Name ds
Copy-DatastoreItem -Item $path -Destination "ds:\$name.iso"

$myCluster = Get-Cluster -Name "clustername"

$vm = New-VM -Name $name -GuestId windows9_64Guest -ResourcePool $myCluster -Datastore Unity_Infrastructure-03 -NumCPU 2 -CoresPerSocket 2 -MemoryGB 4 -DiskGB 60 -NetworkName "LAN-10.1.80.x" -CD -DiskStorageFormat Thin

$vm | Get-CDDrive | Set-CDDrive -StartConnected $True -IsoPath "[$Datastore] $name.iso" -Confirm:$false

#$vm | Set-VM -GuestId windows9_64Guest -Confirm:$False

$rule = Get-DrsRule -Name $name -Cluster $myCluster

#Set-DrsRule -Rule $rule -VM $vm.Name,"PGONDB4"

$vm | Start-VM

$vmview = $vm | Get-View

$strBootNICDeviceName = "Network adapter 1"

$strBootHDiskDeviceName = "Hard disk 1"
 
$intNICDeviceKey = ($vmview.Config.Hardware.Device | ?{$_.DeviceInfo.Label -eq $strBootNICDeviceName}).Key
$oBootableNIC = New-Object -TypeName VMware.Vim.VirtualMachineBootOptionsBootableEthernetDevice -Property @{"DeviceKey" = $intNICDeviceKey}
 
$intHDiskDeviceKey = ($vmview.Config.Hardware.Device | ?{$_.DeviceInfo.Label -eq $strBootHDiskDeviceName}).Key
$oBootableHDisk = New-Object -TypeName VMware.Vim.VirtualMachineBootOptionsBootableDiskDevice -Property @{"DeviceKey" = $intHDiskDeviceKey}
 
$oBootableCDRom = New-Object -Type VMware.Vim.VirtualMachineBootOptionsBootableCdromDevice
 
## create the VirtualMachineConfigSpec with which to change the VM's boot order
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec -Property @{
    "BootOptions" = New-Object VMware.Vim.VirtualMachineBootOptions -Property @{
        ## set the boot order in the spec as desired
        BootOrder = $oBootableNIC, $oBootableHDisk, $oBootableCDRom
    } ## end new-object
} ## end new-object
 
## reconfig the VM to use the spec with the new BootOrder
$vmview.ReconfigVM_Task($spec)

#Read-Host "test"
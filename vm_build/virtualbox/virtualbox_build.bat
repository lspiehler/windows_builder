setlocal enableDelayedExpansion

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name "%~1" --ostype "Windows10_64" --register

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --size 61440 --filename "%USERPROFILE%\VirtualBox VMs\%~1\%~1.vdi"

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%~1" --memory 4096 --nic1 nat --graphicscontroller vboxsvga --vram 128 --pae off --audiocontroller hda --usbohci on --firmware efi --cpus 2

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl "%~1" --name "SATA" --add sata --controller IntelAHCI --portcount 2 --bootable on

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "%~1" --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%USERPROFILE%\VirtualBox VMs\%~1\%~1.vdi"

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "%~1" --storagectl "SATA" --device 0 --port 1 --type dvddrive --medium "%~2"

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "%~1" --type gui
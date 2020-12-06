REM reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f
timeout /T 30
cscript C:\Windows\Setup\Scripts\901_interrupt_or_change_hostname_and_extend.vbs
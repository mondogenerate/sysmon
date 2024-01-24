# Import PSWindowsUpdate module
powershell -ep Unrestricted
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate -Force

# Get and install updates
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

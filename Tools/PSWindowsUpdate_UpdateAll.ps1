# Import PSWindowsUpdate module
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate -Force

# Get and install updates
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

Set-ExecutionPolicy -Bypass
mkdir "C:\sysmon";
Invoke-WebRequest -Uri "https://github.com/mellonaut/sysmon/raw/main/sysmon.zip" -OutFile "C:\sysmon\sysmon.zip";
Expand-Archive "c:\sysmon\sysmon.zip" -DestinationPath "C:\sysmon";
cd "c:\sysmon";
c:\sysmon\sysmon.exe -acceptEula -i c:\sysmon\sysmonconfig.xml

# Looks sexy:
# powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mellonaut/sysmon/master/sysmon.ps1'))"

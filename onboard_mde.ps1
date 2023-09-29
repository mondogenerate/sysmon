powershell Set-ExecutionPolicy -Bypass
mkdir "C:\sysmon";
$fileName = "onboard_mde"
Invoke-WebRequest -Uri "https://github.com/mondogenerate/sysmon/raw/main/$fileName.zip" -OutFile "C:\sysmon\$fileName.zip" -UseBasicParsing;
Expand-Archive "c:\sysmon\$fileName.zip" -DestinationPath "C:\sysmon";
cd "c:\sysmon";
c:\sysmon\sysmon.exe -acceptEula -i c:\sysmon\$fileName.xml
Remove-Item c:\sysmon\$fileName.xml
Remove-Item c:\sysmon\$fileName.zip
Remove-Item c:\sysmon\$fileName.ps1

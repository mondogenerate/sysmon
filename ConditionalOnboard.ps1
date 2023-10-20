$tag = "swift" 

if (Get-Process -Name "sysmon" -ErrorAction SilentlyContinue) {
    Write-Output "sysmon.exe is running, changing configuration to $tag"
    $fileName = "onboard_$tag"
    powershell Set-ExecutionPolicy Bypass

    # Check if Sysmon is running, meaning we need to update rather than install
    if(Test-Path C:\sysmon){ Remove-Item  -r c:\sysmon -Force}
    
    # Remove the directory for a clean install / Upgrade
    mkdir "C:\sysmon";
    Invoke-WebRequest -Uri "https://github.com/mondogenerate/sysmon/raw/main/$fileName.zip" -OutFile "C:\sysmon\$fileName.zip" -UseBasicParsing;
    Expand-Archive "c:\sysmon\$fileName.zip" -DestinationPath "C:\sysmon";
    cd "c:\sysmon";
    c:\sysmon\sysmon.exe -acceptEula -c c:\sysmon\$fileName.xml
    Write-Output "Cleaning up artifacts.."
    Remove-Item c:\sysmon\$fileName.xml
    Remove-Item c:\sysmon\$fileName.zip
    Remove-Item c:\sysmon\$fileName.ps1
    Remove-Item C:\Sysmon\*.zip
    Remove-Item C:\Sysmon\*.xml

} else {
    Write-Output "sysmon.exe is not running, starting clean install of Sysmon using $tag"
    $fileName = "onboard_$tag"
    powershell Set-ExecutionPolicy Bypass
    
    # Clear the Sysmon Path, if it exists from a failed Install, etc
    if(Test-Path C:\sysmon){ Remove-Item  -r c:\sysmon -Force}
    mkdir "C:\sysmon";
    Invoke-WebRequest -Uri "https://github.com/mondogenerate/sysmon/raw/main/$fileName.zip" -OutFile "C:\sysmon\$fileName.zip" -UseBasicParsing;
    Expand-Archive "c:\sysmon\$fileName.zip" -DestinationPath "C:\sysmon";
    cd "c:\sysmon";
    c:\sysmon\sysmon.exe -acceptEula -i c:\sysmon\$fileName.xml
    Remove-Item c:\sysmon\$fileName.xml
    Remove-Item c:\sysmon\$fileName.zip
    Remove-Item c:\sysmon\$fileName.ps1
}
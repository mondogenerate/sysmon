# Process Creation and File Creation
$events = Get-WinEvent  -LogName "Microsoft-Windows-Sysmon/Operational" | where { $_.id -eq 1 -or $_.id -eq 11}

# Process Creation
$events = Get-WinEvent  -LogName "Microsoft-Windows-Sysmon/Operational" | where { $_.id -eq 1 }

# Parse 
$events = Get-WinEvent  -LogName "Microsoft-Windows-Sysmon/Operational" | where { $_.id -eq 1 -or $_.id -eq 11}
foreach ($event in $events)  {
    $ev = $event.Message -split "`r`n"
    $jsons="{ "
    foreach ($line in $ev) {
        $line=$line -replace "\\","\\" `
               -replace "\{"," " `
               -replace "\}"," " `
               -replace '"','\"' `
               -replace "`n"," " 
        $line=$line -replace '(\s*[\w\s]+):\s*(.*)', '"$1":"$2",'
        $jsons = $jsons + $line } 

        $jsons =$jsons + '"blah" : "blah" }' 
        ConvertFrom-Json -InputObject $jsons 
    }


# Use the Module, Get-Sysmon.psm1
Import-Module Get-Sysmon.psm1

# Query image and process
get-SysmonLogs | where {($_.parentImage -like "*office*") -and ($_.CommandLine -like "*powershell*")}
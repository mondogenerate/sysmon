function Set-WindowsLogLimits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $Computers,

        [Parameter(Mandatory = $false)]
        [switch] $CheckLogs,

        [Parameter(Mandatory = $false)]
        [int] $SizeMB,

        [Parameter(Mandatory = $false)]
        [string] $OutputDirectory = "C:\logs"
    )

    foreach ($computer in $Computers) {
        # Check log sizes
        if ($CheckLogs) {
            Write-Host "Checking log sizes on $($computer.ToUpper())" -ForegroundColor Cyan
            $logs = Get-EventLog -List -ComputerName $computer | Where-Object { $_.Log -in @("System", "Security", "Application", $logname) }
            foreach ($log in $logs) {
                $maxSize = $log.MaximumKilobytes / 1MB
                Write-Host "Current size of $($log.LogDisplayName) log: $($maxSize) MB" -ForegroundColor Yellow
            }
        }

        # Change log sizes
        if ($SizeMB) {
            foreach ($log in @("System", "Security", "Application", $logname)) {
                $limitParam = @{
                    Computername = $computer
                    LogName = $log
                    Maximumsize = $SizeMB * 1MB
                    RetentionDays = 30
                    OverflowAction = "OverwriteOlder"
                }
                Write-Host "Changing $($log) log size to $($SizeMB) MB on $($computer.ToUpper())" -ForegroundColor Cyan
                Limit-EventLog @limitParam
                Get-EventLog -List -ComputerName $computer | Where-Object { $_.Log -eq $limitParam.LogName } | Format-Table MachineName,Log,MaximumKilobytes,MinimumRetentionDays,@{Name="Entries";Expression={$_.Entries.count}},OverflowAction -AutoSize
            }
        }

        # Enable PowerShell logging
        Write-Output "Enabling Powershell Transcription Logging. Log Location: $OutputDirectory "
        Enable-PSTranscriptionLogging $OutputDirectory
        Write-Output "Enabling Powershell Script Block Logging"
        Enable-PSScriptBlockLogging
    }
}

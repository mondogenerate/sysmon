$computers = "adc2022","ais1","aas"
$computers="domain.shrine.earth"
$logParams = @{
    System = @{
        Maximumsize = 128MB
        RetentionDays = 30
        OverflowAction = "OverwriteOlder"
    }
    Security = @{
        Maximumsize = 128MB
        RetentionDays = 30
        OverflowAction = "OverwriteOlder"
    }
}

function Enable-PowerShellLogging {
    $logPath = "$env:windir\System32\WindowsPowerShell\v1.0\PowerShell.log"
    $logSize = 50MB
    $logLevel = "Verbose"

    # Create logging folder if it does not exist
    if (!(Test-Path -Path $env:windir\Logs\WindowsPowerShell)) {
        New-Item -Path $env:windir\Logs\WindowsPowerShell -ItemType Directory
    }

    # Set the size of the log file
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Windows\EventLog\Windows PowerShell" `
        -Name "MaxSize" -Value $logSize -Type DWord

    # Enable PowerShell logging
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" `
        -Name "EnableTranscripting" -Value 1 -Type DWord
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" `
        -Name "EnableInvocationHeader" -Value 1 -Type DWord
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" `
        -Name "OutputDirectory" -Value "$env:windir\Logs\WindowsPowerShell" -Type String
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" `
        -Name "MaxSize" -Value $logSize -Type DWord
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription" `
        -Name "Level" -Value $logLevel -Type String

    # Restart WinRM service for changes to take effect
    Restart-Service -Name WinRM -Force

    Write-Output "PowerShell logging enabled with log file location: $logPath"
}


function Set-WindowsLogLimits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $Computers,

        [Hashtable] $LogParams = @{
            System = @{
                Maximumsize = 32MB
                RetentionDays = 21
                OverflowAction = "OverwriteOlder"
            }
            Security = @{
                Maximumsize = 128MB
                RetentionDays = 30
                OverflowAction = "OverwriteOlder"
            }
        }
    )

    foreach ($computer in $Computers) {
        # Enable PowerShell logging
        Write-Host "Enabling PowerShell logging on $($computer.ToUpper())" -ForegroundColor Cyan
        Enable-PowerShellLogging -ComputerName $computer

        foreach ($log in $LogParams.Keys) {
            $limitParam = @{
                Computername = $computer
                LogName = $log
                Maximumsize = $LogParams[$log].Maximumsize
                RetentionDays = $LogParams[$log].RetentionDays
                OverflowAction = $LogParams[$log].OverflowAction
            }

            Write-Host "Setting limits on $($limitParam.LogName) log on $($computer.ToUpper())" -ForegroundColor Cyan
            Limit-EventLog @limitParam
            Get-EventLog -List -ComputerName $computer | Where-Object { $_.Log -eq $limitParam.LogName } | Format-Table MachineName,Log,MaximumKilobytes,MinimumRetentionDays,@{Name="Entries";Expression={$_.Entries.count}},OverflowAction -AutoSize
        }
    }
}
Set-WindowsLogLimits



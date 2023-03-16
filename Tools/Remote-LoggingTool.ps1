# Remote Logging Configuration Tool
$computers = $env:COMPUTERNAME
# $computers="domain.shrine.earth"
$logname = "Windows Powershell"



function Enable-PSTranscriptionLogging {
	param(
		[Parameter(Mandatory)]
		[string]$OutputDirectory
	)

     # Registry path
     $basePath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\Transcription'

     # Create the key if it does not exist
     if(-not (Test-Path $basePath))
     {
         $null = New-Item $basePath -Force

         # Create the correct properties
         New-ItemProperty $basePath -Name "EnableInvocationHeader" -PropertyType Dword
         New-ItemProperty $basePath -Name "EnableTranscripting" -PropertyType Dword
         New-ItemProperty $basePath -Name "OutputDirectory" -PropertyType String
     }

     # These can be enabled (1) or disabled (0) by changing the value
     Set-ItemProperty $basePath -Name "EnableInvocationHeader" -Value "1"
     Set-ItemProperty $basePath -Name "EnableTranscripting" -Value "1"
     Set-ItemProperty $basePath -Name "OutputDirectory" -Value $OutputDirectory

}


# Script Block Logging Enabled
function Enable-PSScriptBlockLogging
 {
 # Registry key 
 $basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 
# Create the key if it does not exist 
if(-not (Test-Path $basePath)) 
{     
$null = New-Item $basePath -Force     
# Create the correct properties      
New-ItemProperty $basePath -Name "EnableScriptBlockLogging" -PropertyType Dword 
} 

# These can be enabled (1) or disabled (0) by changing the value 
Set-ItemProperty $basePath -Name "EnableScriptBlockLogging" -Value "1"
}





function Set-WindowsLogLimits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $Computers,

        [Hashtable] $LogParams = @{
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
            Application = @{
                Maximumsize = 128MB
                RetentionDays = 30
                OverflowAction = "OverwriteOlder"
            }
            $logname = @{
            Maximumsize = 128MB
            RetentionDays = 30
            OverflowAction = "OverwriteOlder"
            }
        }
    )

    foreach ($computer in $Computers) {
        # Enable PowerShell logging
        # Write-Host "Enabling PowerShell logging on $($computer.ToUpper())" -ForegroundColor Cyan
        # Enable-PowerShellLogging -ComputerName $computer

        foreach ($log in $LogParams.Keys) {
            $limitParam = @{
                Computername = $computer
                LogName = $log
                Maximumsize = $LogParams[$log].Maximumsize
                RetentionDays = $LogParams[$log].RetentionDays
                OverflowAction = $LogParams[$log].OverflowAction
            }

            # Windows Event Logs bit
            Write-Host "Setting limits on $($limitParam.LogName) log on $($computer.ToUpper())" -ForegroundColor Cyan
            Limit-EventLog @limitParam
            Get-EventLog -List -ComputerName $computer | Where-Object { $_.Log -eq $limitParam.LogName } | Format-Table MachineName,Log,MaximumKilobytes,MinimumRetentionDays,@{Name="Entries";Expression={$_.Entries.count}},OverflowAction -AutoSize
            
            # PowerShell Logging
            $OutputDirectory = "\\192.168.0.238\Share\PSTranscipts"
            Write-Output "Enabling Powershell Transcription Logging. Log Location: $OutputDirectory "
            Enable-PSTranscriptionLogging $OutputDirectory
            Write-Output "Enabling Powershell Script Block Logging"
            Enable-PSScriptBlockLogging
            
            # PowerShell Complete
            # Write-Output "Enabling POwershell Module Logging. WIll increase log size dramatically."
            # Enable-PSModuleLogging 
            # Write-Output "Enabling Module Logging for ALL Sessions. Will increase further."
            # Enable-AllModuleLogging

        }
    }
}

Set-WindowsLogLimits -Computers $computers
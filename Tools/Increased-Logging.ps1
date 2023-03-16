# Windows Event Logs increased
function Set-WindowsLogLimits {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]] $Computers = $env:COMPUTERNAME,

        [Hashtable] $LogParams = @{
            System = @{
                Maximumsize = 128MB
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

            Write-Host "Setting limits on $($limitParam.LogName) log on $($computer.ToUpper())" -ForegroundColor Cyan
            Limit-EventLog @limitParam
            Get-EventLog -List -ComputerName $computer | Where-Object { $_.Log -eq $limitParam.LogName } | Format-Table MachineName,Log,MaximumKilobytes,MinimumRetentionDays,@{Name="Entries";Expression={$_.Entries.count}},OverflowAction -AutoSize
        }
    }
}
Set-WindowsLogLimits





# Transcription Logging Enabled
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

$OutputDirectory = "TranscriptionLogging"
Enable-PSTranscriptionLogging $OutputDirectory

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

Enable-PSScriptBlockLogging





# Module Logging ( Uses Signigicantly More Space )
# This function checks for the correct registry path and creates it
# if it does not exist, then enables it.
function Enable-PSModuleLogging
{

    # Registry path
    $basePath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
    
    # Create the key if it does not exist
    if(-not (Test-Path $basePath))
    {

        $null = New-Item $basePath -Force
        # Create the correct properties
        New-ItemProperty $basePath -Name "EnableModuleLogging" -PropertyType Dword

    }

    # These can be enabled (1) or disabled (0) by changing the value
    Set-ItemProperty $basePath -Name "EnableModuleLogging" -Value "1"

}

# This function creates another key value to enable logging
# for all modules
Function Enable-AllModuleLogging
{
    # Registry Path     $basePath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' 
    
    # Create the key if it does not exist
    if(-not (Test-Path $basePath))
    {
	$null = New-Item $basePath -Force
    }
    # Set the key value to log all modules
    Set-ItemProperty $basePath -Name "*" -Value "*"
}
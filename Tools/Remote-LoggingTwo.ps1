[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]] $Computers,

    [Parameter(Mandatory = $false)]
    [string] $LogName = $logname,

    [Parameter(Mandatory = $false)]
    [int] $SizeInMB,

    [Parameter(Mandatory = $false)]
    [switch] $CheckOnly,

    [Parameter(Mandatory = $false)]
    [string] $InputFile
)

function Get-EventLogLimit {
    param (
        [string] $Computer,
        [string] $LogName
    )
    $limit = Get-EventLog -List -ComputerName $Computer | Where-Object { $_.Log -eq $LogName }
    return @{
        Computer = $Computer
        LogName = $LogName
        MaximumSize = $limit.MaximumKilobytes / 1024
        RetentionDays = $limit.MinimumRetentionDays
        OverflowAction = $limit.OverflowAction
    }
}

function Get-InputComputers {
    param (
        [string] $InputFile
    )
    if (-not $InputFile) {
        return
    }
    if (-not (Test-Path $InputFile)) {
        Write-Warning "The specified input file '$InputFile' does not exist."
        return
    }
    return Get-Content $InputFile
}

function Set-WindowsLogLimits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $Computers,

        [string] $LogName = $logname,

        [int] $SizeInMB,

        [switch] $CheckOnly
    )

    if (-not $LogName) {
        Write-Warning "No log name specified, using default '$logname'."
        $LogName = $logname
    }

    $logParams = @{
        System = @{
            MaximumSize = 128
            RetentionDays = 30
            OverflowAction = "OverwriteOlder"
        }
        Security = @{
            MaximumSize = 128
            RetentionDays = 30
            OverflowAction = "OverwriteOlder"
        }
        Application = @{
            MaximumSize = 128
            RetentionDays = 30
            OverflowAction = "OverwriteOlder"
        }
        $LogName = @{
            MaximumSize = if ($SizeInMB) { $SizeInMB } else { 128 }
            RetentionDays = 30
            OverflowAction = "OverwriteOlder"
        }
    }

    $computers = Get-InputComputers -InputFile $InputFile | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    if (-not $computers) {
        Write-Warning "No valid computers specified."
        return
    }

    foreach ($computer in $computers) {
        if ($CheckOnly) {
            Write-Host "Checking log limit for $($LogName) log on $($computer.ToUpper())" -ForegroundColor Cyan
            $limit = Get-EventLogLimit -Computer $computer -LogName $LogName
            if ($limit) {
                Write-Output $limit
            }
            else {
                Write-Warning "Log '$LogName' not found on computer '$computer'."
            }
        }
        else {
            # Set log limits
            Write-Host "Setting limits on $($LogName) log on $($computer.ToUpper())" -ForegroundColor Cyan
            $limitParam = @{
                ComputerName = $computer
                LogName = $LogName
                MaximumSize = $logParams[$LogName].MaximumSize * 1MB
                RetentionDays = $logParams[$LogName].RetentionDays
                OverflowAction = $logParams[$LogName].OverflowAction
            }
    
            Limit-EventLog @limitParam
            $limit = Get-EventLogLimit -Computer $computer -LogName $LogName
            Write-Host "New limit for $($LogName) log on $($computer.ToUpper()): $($limit.MaximumSize) MB" -ForegroundColor Cyan
        }
    }

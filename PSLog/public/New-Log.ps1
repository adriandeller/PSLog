Function New-Log
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        $NewLogInstance = [PSCustomObject]@{
            Id         = [Guid]::NewGuid().Guid
            Command    = (Get-PSCallStack)[1].Command
            LogEntries = @()
            Settings   = Copy-Object -Object $Script:PSLog.Settings
        }

        if ($null -eq $Script:PSLog.Instances)
        {
            $Script:PSLog.Instances = New-Object System.Collections.ArrayList
        }
        $null = ($Script:PSLog.Instances).Add($NewLogInstance)

        Write-Verbose "[$Command] Created new Log Instance with Id = $($NewLogInstance.Id)"

        [PSCustomObject]$NewLogInstance
        #$NewLogInstance
    }
    End
    {
    }
}

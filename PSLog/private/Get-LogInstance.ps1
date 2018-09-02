Function Get-LogInstance
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false)]
        [string]
        $Id
    )

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        Write-Verbose "[$Command] [Param] Id = $Id"

        $LogInstances = $Script:PSLog.Instances

        if ($Id)
        {
            $LogInstances | Where-Object { $PSItem.Id -eq $Id }
        }
        elseif ($LogInstances.Count -eq 1)
        {
            Write-Verbose "[$Command] Return the only available Log Instance"

            $LogInstances[0]
        }
        elseif ($LogInstances.Count -gt 1)
        {
            Write-Verbose "[$Command] Multiple Log Instances registered. You must provide an Id."
            $false
        }
        else
        {
            Write-Verbose "[$Command] No Log Instances registered."
            $false
        }
    }
    End
    {
    }
}

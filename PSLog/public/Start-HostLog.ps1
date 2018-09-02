<#
.SYNOPSIS
   Turns on writing formatted log events to the host display.
.DESCRIPTION
   Starts writing formatted log events to the host display. Includes timestamp,
   color-coded entry type, and message text.
.PARAMETER LogLevel
   Specifies the minimum log entry severity to write to the host. The default value is "Error".
.OUTPUTS
   None.
#>
Function Start-HostLog
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Id,

        [Parameter(Mandatory = $false)]
        [Severity]
        $LogLevel = 'Information'
    )

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        Write-Verbose "[$Command] [Param] Id = $Id"
        Write-Verbose "[$Command] [Param] LogLevel = $LogLevel"

        #$LogInstances = Get-LogInstances
        $LogInstance = Get-LogInstance -Id $Id
        if (-not ($LogInstance))
        {
            Write-Warning "[$Command] Cannot start a HostLog."
        }
        else
        {
            $Id = $LogInstance.Id
            #if ($Id)
            #{
            #    $LogInstance = $LogInstances | Where-Object { $PSItem.Id -eq $Id }
            #    $Id = $LogInstance.Id
            #}
            #elseif ($LogInstances.Count -eq 1)
            #{
            #    $LogInstance = $LogInstances[0]
            #    $Id = $LogInstance.Id
            #}
            #else
            #{
            #    Write-Verbose "[$Command] Multiple Log Instances available."
            #    break
            #}

            Write-Verbose "[$Command] Using the Log Instance with Id $Id"

            Write-Verbose "[$Command] [Setting] Enabled = $($LogInstance.Settings.Host.Enabled)"
            Write-Verbose "[$Command] [Setting] LogLevel = $($LogInstance.Settings.Host.LogLevel)"
            if ($LogInstance.Settings.Host.Enabled -eq $true)
            {    
                Write-Verbose "[$Command] HostLog is already enabled for this Log Instance"
            }
            else
            {
                $LogInstance.Settings.Host.Enabled = $true
                $LogInstance.Settings.Host.LogLevel = Get-LogLevel -EntryType $LogLevel

                Write-Verbose "[$Command] [Setting] Enabled = $($LogInstance.Settings.Host.Enabled)"
                Write-Verbose "[$Command] [Setting] LogLevel = $($LogInstance.Settings.Host.LogLevel)"
            }
        }
    }
    End
    {
        #$LogInstances = $LogInstances = $Script:PSLog.Instances
        #$LogInstances | ConvertTo-Json -Depth 4
    }
}

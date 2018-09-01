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

    Param (
        [Parameter(Mandatory = $false)]
        [Severity]
        $LogLevel = 'Information'
    )

    Begin
    {        
    }
    Process
    {
        $Script:Settings["Host"].Enabled = $true
        $Script:Settings["Host"].LogLevel = Get-LogLevel -EntryType $LogLevel

        $Command = (Get-PSCallStack)[0].Command
        Write-Verbose "[$Command] Enabled = $($Script:Settings["Host"].Enabled)"
        Write-Verbose "[$Command] LogLevel = $LogLevel ($($Script:Settings["Host"].LogLevel))"
    }
}

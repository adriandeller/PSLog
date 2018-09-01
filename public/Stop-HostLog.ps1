<#
.SYNOPSIS
   Turns off writing log messages to the host display.
.DESCRIPTION
   Turns off writing log messages to the host display.
.OUTPUTS
   None.
#>
Function Stop-HostLog
{
    [CmdletBinding()]
    
    Param ()

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        $Script:Settings["Host"].Enabled = $false

        Write-Verbose "[$Command] Enabled = $($Script:Settings["Host"].Enabled)"
    }
    End
    {
    }
}

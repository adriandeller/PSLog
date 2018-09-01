<#
.SYNOPSIS
   Stops writing log output to file.
.DESCRIPTION
   Stops writing log output to file. Any log data that has already been written will remain.
.OUTPUTS
   None.
#>
Function Stop-FileLog
{
    [CmdletBinding()]

    Param ()

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        $Script:Settings["File"].Enabled = $false
        $Script:Settings["File"].Path = $null

        Write-Verbose "[$Command] Enabled = $($Script:Settings["File"].Enabled)"
        Write-Verbose "[$Command] Path = $($Script:Settings["File"].Path)"
    }
    End
    {
    }
}

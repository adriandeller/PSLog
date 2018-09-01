<#
.SYNOPSIS
   Starts recording log events so that they can be e-mailed.
.DESCRIPTION
   Starts recording log events so that they can be e-mailed. A separate Cmdlet
   (Send-EmailLog) must be issued to actually send an e-mail.
.PARAMETER ClearEntryCache
   Specifies whether any existing recorded log entries from the cache of
   entries to be e-mailed should be removed.
.OUTPUTS
   None.
#>
Function Start-EmailLog
{
    [CmdletBinding()]

    Param
    (
        [Parameter()]
        [switch]$ClearEntryCache = $false
    )

    Process
    {
        $Script:Settings["Email"].Enabled = $true

        if ($ClearEntryCache) {
            $Script:LogEntries = @()
        }
    }
}

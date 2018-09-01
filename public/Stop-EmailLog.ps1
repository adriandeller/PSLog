<#
.SYNOPSIS
   Stops the recording of log events to the e-mail cache.
.DESCRIPTION
   Stops the recording of log events to the e-mail cache. By default, the cache is also cleared.
.PARAMETER RetainEntryCache
   Specifies whether any log entries that have already been recorded should be kept or discarded.
.OUTPUTS
   None.
#>
Function Stop-EmailLog
{
    [CmdletBinding(SupportsShouldProcess = $true)]

    Param
    (
        [Parameter()]
        [switch]$RetainEntryCache = $false
    )

    Process
    {
        $Script:Settings["Email"].Enabled = $false

        if (!$RetainEntryCache)
        {
            $Script:LogEntries = @()
        }
    }
}

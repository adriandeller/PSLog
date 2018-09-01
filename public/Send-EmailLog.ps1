<#
.SYNOPSIS
   Sends an e-mail containing one or more of the log messages collected since e-mail logging was enabled.
.DESCRIPTION
   Sends an e-mail containing one or more of the log messages collected since
   e-mail logging was enabled in the current session. Parameters can be used to
   control the severity of log message required to trigger sending an e-mail
   and also what levels are sent when an e-mail is triggered.
.PARAMETER SmtpServer
   Specifies the SMTP server to use to send e-mail.
.PARAMETER To
   Specifies one or more recipients for the e-mail.
.PARAMETER From
   Specifies a from address to use when sending the e-mail. Note that some SMTP servers require this to be a valid mailbox.
.PARAMETER Subject
   Specifies the subject of the e-mail message.
.PARAMETER Message
   Specifies additional text to include in the e-mail message before the log data.
.PARAMETER TriggerLogLevel
   Specifies the condition for sending an e-mail. A log entry at or above the
   specified level must have been recorded for an e-mail to be sent.
.PARAMETER SendLogLevel
   Specifies what log events to include when sending an e-mail. This can be
   different than the TriggerLogLevel.
.PARAMETER RetainEntryCache
   Specifies whether or not to keep the log entries that have been recorded.
   The default behavior is to clear them.
.PARAMETER SendOnEmpty
   Specifies whether or not to send an e-mail if there are no log events that match the SendLogLevel parameter.
.OUTPUTS
   None.
#>
Function Send-EmailLog
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$SmtpServer,

        [Parameter(Mandatory = $false)]
        [int]$SmtpPort = 25,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$To,

        [Parameter(Mandatory = $true)]
        [string]$From,

        [Parameter()]
        [string]$Subject = "",

        [Parameter()]
        [string]$Message = "",

        [Parameter()]
        [ValidateSet("Information", "Warning", "Error")]
        [string]$TriggerLogLevel = "Error",

        [Parameter()]
        [ValidateSet("Information", "Warning", "Error")]
        [string]$SendLogLevel = "Error",

        [Parameter()]
        [switch]$RetainEntryCache = $false,

        [Parameter()]
        [switch]$SendOnEmpty = $false,

        [Parameter()]
        [ValidateSet("Information", "Warning", "Error")]
        [string]$LogLevel = "Error"
    )

    Begin
    {
        $Bypass = $false

        if ($PSBoundParameters.ContainsKey("LogLevel"))
        {
            # Deprecated functionality.
            Write-Warning -Message ([string]::Format($Script:r.Parameter_F0_Deprecated_F1, "LogLevel", "TriggerLogLevel and SendLogLevel"))
            $TriggerLogLevel = $LogLevel
            $SendLogLevel = $LogLevel
        }

        # Start by checking if anything was logged that fits our trigger level.
        $TriggerLogLevelNumber = Get-LogLevel -EntryType $TriggerLogLevel
        if ((!$PSBoundParameters.ContainsKey("TriggerLogLevel") -and !$PSBoundParameters.ContainsKey("LogLevel")) -or ($Script:LogEntries | Where-Object -FilterScript { $_.LogLevel -le $TriggerLogLevelNumber }))
        {
            if (!$Subject)
            {
                $Subject = $Script:r.EmailLogSubject
            }
            $EmailBody = "<style>
                        .log-entries {font-family: `"Lucida Console`", Monaco, monospace;font-size: 10pt;}</style>  <body>"

            if ($Message)
            {
                $EmailBody += "<p>$Message</p>"
            }

            $SendLogLevelNumber = Get-LogLevel -EntryType $SendLogLevel
            $Entries = $Script:LogEntries | Where-Object -FilterScript { $_.LogLevel -le $SendLogLevelNumber }
            $Empty = $false
            if ($Entries)
            {
                $EmailBody += "<div class=`"log-entries`">"

                $FormatScriptBlock = {
                    Param ($Entry)
                    
                    #$DateTime = (Get-Date $Entry.Timestamp.ToString("u"))
                    $DateTime = $Entry.Timestamp
                    $Line = "[$DateTime] "

                    switch ($Entry.EntryType)
                    {
                        "Information"
                        {
                            # Add whitespaces on the rgith side, then replace them with HTML explicit whitespace
                            $SeverityString = ("[$($Entry.EntryType)]".PadRight(13, ' ')).Replace(' ', '&nbsp;')
                            $Line += "<span style=`"color: Teal`">$SeverityString</span>"
                        }

                        "Warning"
                        {
                            $SeverityString = ("[$($Entry.EntryType)]".PadRight(13, ' ')).Replace(' ', '&nbsp;')
                            $Line += "<span style=`"color: GoldenRod`">$SeverityString</span>"
                        }

                        "Error"
                        {
                            $SeverityString = ("[$($Entry.EntryType)]".PadRight(13, ' ')).Replace(' ', '&nbsp;')
                            $Line += "<span style=`"color: Red`">$SeverityString</span>"
                        }
                    }

                    $Line += " $($Entry.Message)"

                    if ($Entry.Exception)
                    {
                        $Line += "<ul><li>$($Script:r.Message): $($Entry.Exception.Message)</li><li>$($Script:r.Source): $($Entry.Exception.Source)</li><li>$($Script:r.StackTrace):"

                        if ($Entry.Exception.StackTrace -and $Entry.Exception.StackTrace.Count -gt 0)
                        {
                            $Line += "<ul>"
                            foreach ($Stack in $Entry.Exception.StackTrace)
                            {
                                $Line += "<li>$Stack</li>"
                            }
                            $Line += "</ul>"
                        }

                        $Line += "</li><li>$($Script:r.TargetSite): $($Entry.Exception.TargetSite)</li></ul>"
                    }

                    $Line
                }

                $EmailBody += $Entries | ConvertTo-HtmlUnorderedList -FormatScript $FormatScriptBlock
                $EmailBody += "</div>"
            }
            else
            {
                $Empty = $true
                $EmailBody += "<p>$($Script:r.NoEntriesToReport)</p>"
            }

            $EmailBody += "</body>"
        }
        else
        {
            # No events occurred that would trigger us to send an e-mail.
            $Bypass = $true
        }
    }

    Process
    {
        if (!$Bypass -and (!$Empty -or $SendOnEmpty))
        {
            Send-MailMessage -From $From -To $To -Subject $Subject -Body $EmailBody -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -BodyAsHtml -Credential (Get-Credential)
            Write-Verbose "Sent Email"
        }
    }
    End
    {
        if (!$Bypass -and !$RetainEntryCache)
        {
            $Script:LogEntries = @()
        }
    }
}

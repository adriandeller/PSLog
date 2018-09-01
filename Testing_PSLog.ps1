#Region Functions
<#
function LogTester
{
    [CmdletBinding()]
    param
    (
        $Text = 'Lorem ipsum dolor sit amet'
    )

    Begin
    {
    }
    
    Process
    {
        $Command = (Get-PSCallStack)[0].Command
        $TextTitle = "[$Command] $Text"

        Write-Log -Message $TextTitle -Severity Information
        Write-Log -Message $Text -Severity Error -Indent 1
        Write-Log -Message $Text -Severity Warning -Indent 1 -Indicator Success

        $FilePath = "C:\this-does-not-exist.log"
        try
        { 
            Write-Log -Message 'Get content from not existing file $FilePath' -Severity Information -Indent 1
            Get-Content -Path $FilePath -ErrorAction Stop
        }
        catch
        {
            Write-Log -Severity Error -Indent 1 -ErrorRecord $Error[0] -Verbose
        }
    }
    End
    {

    }
}

function LogTesterLong
{
    [CmdletBinding()]
    Param
    (
        $Text = 'Lorem ipsum dolor sit amet'
    )

    $Command = (Get-PSCallStack)[0].Command
    $TextTitle = "[$Command] $Text"

    Write-Log -Message $TextTitle -Severity Information
    Write-Log -Message $Text -Severity Information -Indent 1
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Failure
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Success
    Write-Log -Message $Text -Severity Information -Indent 1
    Write-Log -Message $Text -Severity Warning -Indent 1
    Write-Log -Message $Text -Severity Warning -Indent 1 -Indicator Failure
    Write-Log -Message $Text -Severity Error -Indent 2
    Write-Log -Message $TextTitle
}

function LogTesterSuperLong
{
    [CmdletBinding()]
    Param
    (
        $Text = 'Lorem ipsum dolor sit amet'
    )
    Write-Log -Message $Text -Severity Information
    Write-Log -Message $Text -Severity Information -Indent 1
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Failure
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Success
    Write-Log -Message $Text -Severity Information -Indent 0
    Write-Log -Message $Text -Severity Warning -Indent 1
    Write-Log -Message $Text -Severity Warning -Indent 1 -Indicator Success
    Write-Log -Message $Text -Severity Warning -Indent 1 -Indicator Failure
    Write-Log -Message $Text -Severity Error -Indent 2
    Write-Log -Message $Text -Indicator Success

    try
    { 
        do-something
    }
    catch
    {
        $Text = 'Oooops an error'
        Write-Log -Message $Text -Severity Error -Indicator Failure -Indent 1 -ErrorRecord $Error[0] -Verbose
    }

}
#>
#EndRegion

#Import-Module PSLog
#Import-Module "C:\Users\Adrian\Documents\Dev\PSLog"
Import-Module "$PSScriptRoot\PSLog"
Import-Module "$PSScriptRoot\TestingPSLog.psm1"

#$PSDefaultParameterValues.Add('*Log:Verbose', $true)
$PSDefaultParameterValues.Add('*HostLog:Verbose', $true)
$PSDefaultParameterValues.Add('*FileLog:Verbose', $true)

#Start-HostLog -LogLevel Error
Start-HostLog
#Start-FileLog -Path C:\Temp\logfileNew.log -Append:$true #-LogLevel Error 
Start-FileLog -Path C:\Temp\logfileNew.log
start-EmailLog

#$Text = 'Lorem ipsum dolor sit amet'
#Write-Log -Message $Text -Severity Error
#Write-Log -Message $Text -Severity Error -Indicator Neutral
#Write-Log -Message $Text -Severity Error -Indicator Success

#
$FilePath = "C:\this-does-not-exist.log"
try
{ 
    Write-Log -Message "Get content from not existing file $FilePath" -Severity Information
    Get-Content -Path $FilePath -ErrorAction Stop
}
catch
{
    Write-Log -Severity Error -ErrorRecord $_
}

try
{ 
    Write-Log -Message "Get content from not existing file $FilePath" -Severity Information
    Get-Content -Path $FilePath -ErrorAction Stop
}
catch
{
    Write-Log -Severity Error -Message "Oooops something went wrong" -ErrorRecord $_
}

try
{ 
    Write-Log -Message "Get content from not existing file $FilePath" -Severity Information
    Get-Content -Path $FilePath -ErrorAction Stop
}
catch
{
    Write-Log -Severity Error -Message "Something went wrong, but no big deal" -Indicator Neutral
    Write-Log -Severity Error -ErrorRecord $_ -Indent 1
}
#

#LogTesterLong
LogTester
#LogTesterSuperLong

Stop-HostLog
Stop-FileLog
Invoke-Item C:\Temp\logfileNew.log

break
$SendEmailLogParam = @{
    SmtpServer      = 'smtp-ext.unibas.ch'
    SmtpPort        = 587
    To              = 'adrian@deller.ch'
    From            = 'adrian.deller@unibas.ch'
    Subject         = 'Email log'
    Message         = ''
    TriggerLogLevel = 'Information'   # Specifies what log events to include when sending an e-mail.
    SendLogLevel    = 'Information'   # Specifies the condition for sending an e-mail.
}

Send-EmailLog @SendEmailLogParam -Verbose

Stop-EmailLog

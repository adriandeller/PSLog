#Import-Module PSLog
#Import-Module "C:\Users\Adrian\Documents\Dev\PSLog"
Import-Module "$PSScriptRoot\PSLog"
Import-Module "$PSScriptRoot\TestingPSLog.psm1"

$PSDefaultParameterValues.Add('*Log*:Verbose', $true)
$PSDefaultParameterValues.Add('*LogInstance:Verbose', $true)
$PSDefaultParameterValues.Add('*HostLog:Verbose', $true)
$PSDefaultParameterValues.Add('*FileLog:Verbose', $true)


Start-HostLog
Write-Host ""

$MyLog1 = New-Log
Start-HostLog
Write-Host ""

$MyLog1 | Start-HostLog
Write-Host ""

New-Log | Start-HostLog -LogLevel Error
break
$MyLog2 = New-Log
$MyLog2  | Start-HostLog -LogLevel Error
#$MyLog1 | Start-HostLog
#$MyLog1, $MyLog2  | Start-HostLog
#$MyLogId = $MyLog1.Id
#Start-HostLog -Id $MyLogId
#Trace-Command -Name ParameterBinding -Expression { Get-Sugus | Start-HostLog } -PSHost
#Trace-Command -Name ParameterBinding -Expression { Start-HostLog -Id $MyLog.Id } -PSHost

#Start-FileLog -Path C:\Temp\logfileNew.log -Append:$true #-LogLevel Error 
#Start-FileLog -Path C:\Temp\logfileNew.log
#Start-EmailLog

$Text = 'Lorem ipsum dolor sit amet'
#Write-Log -Message $Text -Severity Error
#Write-Log -Message $Text -Severity Error -Indicator Neutral
#Write-Log -Message $Text -Severity Error -Indicator Success

<#
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
#>

#LogTesterLong
#LogTester
#LogTesterSuperLong

#Stop-HostLog
#Stop-FileLog
#Invoke-Item C:\Temp\logfileNew.log

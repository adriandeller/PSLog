<#
.SYNOPSIS
   Begins to log output to file.
.DESCRIPTION
   Begins to log output to file. Only entries with a severity at or above the specified level will be written.
.PARAMETER Path
  Specifies the path and name of the log file that will be written.
.PARAMETER LogLevel
   Specifies the minimum log entry severity to include in the file log. The default value is "Error".
.PARAMETER Append
   Specifies that the file at <Path> should not be deleted if it already exists. New entries will be appended to the end of the file.
.OUTPUTS
   None.
#>
Function Start-FileLog
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Append,

        [Parameter(Mandatory = $false)]
        [Severity]
        $LogLevel = 'Information'
    )

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
        
        Set-FunctionNameMaxLength
    }
    Process
    {
        $Script:Settings["File"].Enabled = $false
        
        # First attempt to remove existing file if necessary
        if (!$Append -and (Test-Path -LiteralPath $Path))
        {
            try
            {
                Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
            }
            catch
            {
                Write-Error -Exception $_.Exception -Message 'Unable to remove existing log file.'
                return
            }
        }

        # Create file if necessary
        if (!(Test-Path -LiteralPath $Path))
        {
            try
            {
                New-Item -Path $Path -ItemType File -Force -ErrorAction Stop | Out-Null
            }
            catch
            {
                Write-Error -Exception $_.Exception -Message 'Unable to create log file.'
                return
            }
        }

        $Script:Settings["File"].Enabled = $true
        $Script:Settings["File"].LogLevel = Get-LogLevel -EntryType $LogLevel
        $Script:Settings["File"].Path = $Path

        Write-Verbose "[$Command] Enabled = $($Script:Settings["File"].Enabled)"
        Write-Verbose "[$Command] LogLevel = $LogLevel ($($Script:Settings["File"].LogLevel))"
        Write-Verbose "[$Command] Path = $($Script:Settings["File"].Path)"
    }
    End
    {
    }
}
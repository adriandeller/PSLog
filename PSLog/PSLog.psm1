#Region Import public and private function definition files
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
foreach ($import in @($Public + $Private))
{
    try
    {
        . $import.FullName
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.Basename
#EndRegion


#Region Define enum
enum Severity
{
    Information
    Warning
    Error
}

enum Indicator
{
    Neutral
    Success
    Failure
}
#EndRegion


#Region Set default settings for each of the log types
$Script:PSLog = @{

    #Instances = @{}
    #$Instances = New-Object System.Collections.ArrayList
    Instances = $null
    
    Settings  = @{
        File  = New-Object -TypeName psobject -Property @{
            Enabled  = $false
            LogLevel = 0
            Path     = $null
        }

        Host  = New-Object -TypeName psobject -Property @{
            Enabled          = $false
            LogLevel         = 0
            IndicatorSymbols = @{
                Neutral = '*'
                Success = '+'
                Failure = '-'
            }
        }

        Email = New-Object -TypeName psobject -Property @{
            Enabled = $false
        }
    }
}
<#
$Script:PSLog = @{

    Instances = @(

    )

    Settings  = @{
        File  = New-Object -TypeName psobject -Property @{
            Enabled  = $false
            LogLevel = 0
            Path     = $null
        }

        Host  = New-Object -TypeName psobject -Property @{
            Enabled          = $false
            LogLevel         = 0
            IndicatorSymbols = @{
                Neutral = '*'
                Success = '+'
                Failure = '-'
            }
        }

        Email = New-Object -TypeName psobject -Property @{
            Enabled = $false
        }
    }
}
#>
#EndRegion


# Array to hold log entries that will be e-mailed when using e-mail logging.
#$Script:LogEntries = @()

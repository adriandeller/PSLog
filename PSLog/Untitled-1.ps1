$Script:PSLog = @{

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

function Copy-Object
{
    # Clone an object
    # https://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell
    param($Object)
    $memStream = New-Object IO.MemoryStream
    $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream, $Object)
    $memStream.Position = 0
    $formatter.Deserialize($memStream)
}

1..3 | ForEach-Object {
    $NewLogInstance = @{
        Id         = $PSItem #[Guid]::NewGuid().Guid
        Command    = (Get-PSCallStack)[0].Command
        LogEntries = @()
        Settings   = Copy-Object -Object $Script:PSLog.Settings
    }

    if ($Script:PSLog.Instances -eq $null)
    {
        $Script:PSLog.Instances = New-Object System.Collections.ArrayList
    }
    $null = ($Script:PSLog.Instances).Add($NewLogInstance)
    #$Script:PSLog['Instances'] += @($NewInstanceGUID)
}

#$Script:PSLog.Instances.GetEnumerator() | ForEach-Object {
#
#    $Script:PSLog.Instances
#}

#$Script:PSLog | ConvertTo-Json -Depth 3

#$Script:PSLog.Instances.Id
#$Script:PSLog.Instances.ForEach('Id')
#$Script:PSLog.Instances[0].Id

foreach ($Instance in $Script:PSLog.Instances)
{
    $Instance.Id
    $Instance.Settings.Host.Enabled

}

$CurrentInstance = $Script:PSLog.Instances | Where-Object { $PSItem.Id -eq 2 }

$CurrentInstance.Settings.Host.Enabled = $true

foreach ($Instance in $Script:PSLog.Instances)
{
    $Instance.Id
    $Instance.Settings.Host.Enabled

}


#$Script:PSLog | ConvertTo-Json -Depth 3

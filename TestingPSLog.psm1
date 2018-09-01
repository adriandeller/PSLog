function LogTester
{
    [CmdletBinding()]
    param
    (
        $Text = 'Lorem ipsum dolor sit amet'
    )

    Begin
    {
        #Start-FileLog -Path C:\Temp\logfileNew.log -Append:$true -Verbose
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
            Write-Log -Severity Error -Indent 1 -ErrorRecord $_
        }
        finally
        {
            Write-Log -Message "Exiting function $Command" -Severity Information -Indent 1
        }
    }
    End
    {
        #Stop-FileLog -Verbose
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

    $Command = (Get-PSCallStack)[0].Command
    $TextTitle = "[$Command] $Text"

    Write-Log -Message $TextTitle -Severity Information
    Write-Log -Message $Text -Severity Information -Indent 1
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Failure
    Write-Log -Message $Text -Severity Information -Indent 2 -Indicator Success
    Write-Log -Message $Text -Severity Information -Indent 1
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
        Write-Log -Message $Text -Severity Error -Indicator Failure -Indent 1 -ErrorRecord $_
    }

}
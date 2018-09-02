Function Get-LogInstances
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    Process
    {
        $Script:PSLog['Instances']     
    }
    End
    {
    }
}

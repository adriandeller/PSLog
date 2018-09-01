function Set-FunctionNameMaxLength
{
    [CmdletBinding()]
    param (
        
    )
    
    begin
    {
        $Command = (Get-PSCallStack)[0].Command
    }
    
    process
    {
        # (Get-PSCallStack)[0].Command = Set-FunctionNameMaxLength
        # (Get-PSCallStack)[1].Command = Start-FileLog
        # (Get-PSCallStack)[2].Command = function/script
        $PSCallStackCommand = (Get-PSCallStack)[2].Command

        if ($Module = (Get-Command -Name $PSCallStackCommand -ErrorAction SilentlyContinue).Source )
        {
            # Function was invoked by a function/Cmdlet of an imported module
            # Therefore we use the module's exported functions
            Write-Verbose "[$Command] Function: $PSCallStackCommand"
            Write-Verbose "[$Command] Module:   $Module"

            #Region Find the function of the module with the longest name
            $Script:FunctionNameMaxLength = Get-Command -Module $Module | 
                Select-Object Name, @{N = 'Length'; E = {($PSItem.Name).ToString().Length }} | 
                Sort-Object -Property Length | 
                Select-Object -Last 1 -ExpandProperty Length
            #EndRegion
        }
        else
        {
            # Function was invoked by a script
            # Therefore we use the 'Function' drive
            Write-Verbose "[$Command] Script: $PSCallStackCommand"
            
            #Region Find the function with the longest name availbale in 'Function' drive
            $Script:FunctionNameMaxLength = Get-ChildItem Function: | 
                Select-Object Name, @{N = 'Length'; E = {($PSItem.Name).ToString().Length }} | 
                Sort-Object -Property Length | 
                Select-Object -Last 1 -ExpandProperty Length
            #EndRegion
        }
    }    
    end
    {
        Write-Verbose "[$Command] FunctionNameMaxLength = $($Script:FunctionNameMaxLength)"
    }
}

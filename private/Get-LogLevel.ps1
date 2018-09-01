<#
.SYNOPSIS
   Gets the integer representation of the specified entry type.
.DESCRIPTION
   Gets the integer representation of the specified entry type. Used for filtering log output.
.PARAMETER EntryType
   Specifies the entry type to evaluate.
.OUTPUTS
   Integer.
#>
Function Get-LogLevel
{
    [CmdletBinding()]
    [OutputType([int])]
    
    Param (
        [Parameter(Mandatory = $true)]
        [Severity]
        $EntryType
    )

    Process
    {
        switch ($EntryType)
        {
            "Information"
            {
                return 2
            }

            "Warning"
            {
                return 1
            }

            "Error"
            {
                return 0
            }
        }
    }
}

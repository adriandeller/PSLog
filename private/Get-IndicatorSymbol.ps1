<#
.SYNOPSIS
   Gets the string representation of the specified indicator.
.DESCRIPTION
   Gets the string representation of the specified indicator. Used as a bullet character in host messages.
.PARAMETER Indicator
   Specifies the indicator to evaluate.
.OUTPUTS
   
#>
Function Get-IndicatorSymbol
{
    [CmdletBinding()]
    [OutputType([string])]
    
    Param
    (
        [Parameter(Mandatory = $true)]
        [Indicator]
        $Indicator
    )

    Process
    {
        $Script:Settings['Host'].IndicatorSymbols[$Indicator.ToString()]
    }
}

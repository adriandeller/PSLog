<#
.SYNOPSIS
   Builds an HTML UnorderedList from the supplied input and returns its string.
.DESCRIPTION
   Builds an HTML UnorderedList from the supplied input and returns its string.
.PARAMETER FormatScript
   Specifies a script block to invoke for each object passed into the Cmdlet.
.PARAMETER InputObject
   Specifies one or more objects to write to the unordered list.
.OUTPUTS
   String.
#>
Function ConvertTo-HtmlUnorderedList
{
    [CmdletBinding()]
    
    [OutputType([string])]

    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $InputObject,

        [Parameter()]
        [scriptblock]
        $FormatScript = $null
    )

    Begin
    {
        $OutputText = "<ul>`n"
    }

    Process
    {
        @($InputObject) | ForEach-Object {
            $OutputText += "<li>"

            if ($FormatScript)
            {
                $OutputText += Invoke-Command -ScriptBlock $FormatScript -ArgumentList $_
            }
            else
            {
                $OutputText += $_
            }

            $OutputText += "</li>`n"
        }
    }

    End
    {
        $OutputText += "</ul>`n"
        $OutputText
    }
}
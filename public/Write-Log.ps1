<#
.SYNOPSIS
   Begins to log output to host/file.
.DESCRIPTION
   Begins to log output to host/file.
   Only entries with a severity at or above the specified level will be written.
.PARAMETER Messsage
   
.PARAMETER Severity
   
.PARAMETER Indicator
   
.PARAMETER Indent
   
.OUTPUTS
   None.
#>
function Write-Log
{
    [CmdletBinding(DefaultParameterSetName = 'Message')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ErrorRecord')]
        [string]
        $Message,

        [Parameter(Mandatory = $false)]
        [Severity]
        $Severity = [Severity]::Information,
        
        [Parameter(Mandatory = $false)]
        [Indicator]
        $Indicator = [Indicator]::Neutral,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3)]
        [int]
        $Indent = 0
    )

    DynamicParam
    {
        # Create an RuntimeDefinedParameterDictionary object
        $ParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($PSBoundParameters['Severity'] -eq [Severity]::Error)
        {
            # Set the dynamic parameters' name
            $ParameterName = 'ErrorRecord'

            # Set the dynamic parameters' type
            $ParameterType = [System.Management.Automation.ErrorRecord]
            
            # Create an Collection object
            $Collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Create a ParameterAttribute object and define properties
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.Position = 0
            $ParameterAttribute.ParameterSetName = 'ErrorRecord'
            $ParameterAttribute.HelpMessage = "Provide an error object like '$_' in a try/catch block"

            # Add the ParameterAttribute object to the Collection object
            $Collection.Add($ParameterAttribute)

            # Create a ValidateNotNullOrEmptyAttribute object
            $ValidateNotNullOrEmptyAttribute = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute

            # Add the ValidateNotNullOrEmptyAttribute object to the Collection object
            $Collection.Add($ValidateNotNullOrEmptyAttribute)

            # Create a RuntimeDefinedParameter object for the new dynamic paramater
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, $ParameterType, $Collection)

            # Add the RuntimeDefinedParameter object to the ParameterDictionary object
            $ParameterDictionary.Add($ParameterName, $RuntimeParameter)

            # Set specific default value for parameter Indicator, if not explicit set
            if (-not ($PSBoundParameters.ContainsKey('Indicator')))
            {
                $PSBoundParameters['Indicator'] = [Indicator]::Failure
            }
        }
        # return the ParameterDictionary object with the new dynamic paramaters
        return $ParameterDictionary
    }

    Begin
    {
        $Command = (Get-PSCallStack)[0].Command

        # Replace variable with value from PSBoundParameters, if explicit set
        #   this is important because of dynamic parameter and default value...
        if ($PSBoundParameters.ContainsKey('Severity'))
        {
            $Severity = $PSBoundParameters['Severity']
        }

        if ($PSBoundParameters.ContainsKey('Indicator'))
        {
            $Indicator = $PSBoundParameters['Indicator']
        }

        $LogLevel = Get-LogLevel -EntryType $Severity
        Write-Verbose "[$Command] Severity = $Severity"
        Write-Verbose "[$Command] Indicator = $Indicator"
        Write-Verbose "[$Command] LogLevel = $LogLevel"

        # Create variables for dynamic parameters:
        #   loop through bound parameters, filter out common parameters
        #   if no corresponding variable exists, create one
        $CommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
        $BoundKeys = $PSBoundParameters.keys | Where-Object { $CommonParameters -notcontains $_}
        foreach ($Param in $BoundKeys)
        {
            if (-not ( Get-Variable -name $param -Scope 0 -ErrorAction SilentlyContinue ) )
            {
                New-Variable -Name $Param -Value $PSBoundParameters.$Param
                Write-Debug "Adding variable for dynamic parameter '$Param' with value '$($PSBoundParameters.$Param)'"
            }
        }

        # Set custom value for ForegroundColor
        switch ($Severity)
        {
            Information
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::White}
            }
            Warning
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::Yellow}
            }
            Error
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::Red}
            }
        }

        switch ($Indicator)
        {
            Failure
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::Red}
            }
            Success
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::Green}
            }
            Neutral
            {
                $PSDefaultParameterValues = @{'Write-Host:ForegroundColor' = [System.ConsoleColor]::White}
            }
        }

        # Creating a new mutex object
        $Mutex = New-Object -TypeName 'Threading.Mutex' -ArgumentList $false, 'MyInterprocMutex'
    }
    Process
    {
        #Region Write message to Host
        if ($Script:Settings['Host'].Enabled -eq $true -and $LogLevel -le $Script:Settings['Host'].LogLevel)
        {
            $IndicatorSymbol = Get-IndicatorSymbol -Indicator $Indicator
            $Prefix = "[$IndicatorSymbol]"

            if ($Indent -gt 0)
            {
                $Whitespaces = ' '.PadRight(4 * $Indent)
            }

            $HostMessage = '{0}{1} {2}' -f $Whitespaces, $Prefix, $Message

            # Skip if message is empty
            if (-not ([string]::IsNullOrEmpty($Message)))
            {    
                Write-Host -Object $HostMessage
            }

            # Add new line for error record
            if ($ErrorRecord)
            {
                if (-not ([string]::IsNullOrEmpty($Message)))
                {        
                    $Whitespaces = ' '.PadRight(4 * ($Indent + 1))
                }
                $ErrorRecord = $PSBoundParameters.ErrorRecord
                $HostMessage = '{0}{1} {2}' -f $Whitespaces, $Prefix, $ErrorRecord.Exception.Message
                Write-Host -Object $HostMessage
            }
        }
        #EndRegion


        #Region Write message to log file
        if ($Script:Settings['File'].Enabled -eq $true -and $LogLevel -le $Script:Settings['File'].LogLevel)
        {
            Write-Verbose "FunctionNameMaxLength = $($Script:FunctionNameMaxLength)"

            if ($Script:FunctionNameMaxLength)
            {
                $FunctionNameMaxLength = $Script:FunctionNameMaxLength
            }

            $LogFilePath = $Script:Settings['File'].Path
            $DateTime = Get-Date
            $DateString = Get-Date $DateTime -Format s
            $Command = (Get-PSCallStack)[1].Command # FunctionName
            $CommandString = "[$Command]".PadRight($FunctionNameMaxLength + 2)
            $SeverityString = "[$Severity]".PadRight(11 + 2) # 'Information' = 11 characters = longest string
            $LogMessage = "{0} {1} {2} {3}" -f $DateString, $CommandString, $SeverityString, $Message

            # Skip if message is empty
            if (-not ([string]::IsNullOrEmpty($Message)))
            {
                $null = $Mutex.WaitOne()
                $LogFilePath = $Script:Settings['File'].Path
                Add-Content -Path $LogFilePath -Value $LogMessage
                $null = $Mutex.ReleaseMutex()
            }
            
            # Add new line for error record
            if ($ErrorRecord)
            {
                $LogMessage = "{0} {1} {2} {3} ({4}: {5}:{6} char:{7})" -f $DateString, $CommandString, $SeverityString,
                $ErrorRecord.Exception.Message,
                $ErrorRecord.FullyQualifiedErrorId,
                $ErrorRecord.InvocationInfo.ScriptName,
                $ErrorRecord.InvocationInfo.ScriptLineNumber,
                $ErrorRecord.InvocationInfo.OffsetInLine

                $null = $Mutex.WaitOne()
                Add-Content -Path $LogFilePath -Value $LogMessage
                $null = $Mutex.ReleaseMutex()
            }
        }
        #EndRegion

        #Region Record entry for e-mailing later
        if ($Script:Settings['Email'].Enabled -eq $true)
        {
            $Entry = New-Object -TypeName psobject -Property @{
                Timestamp = $DateTime
                EntryType = $Severity
                LogLevel  = $LogLevel
                Message   = $Message
                Exception = $null
                EventId   = $null
            }
            $Script:LogEntries += $Entry
        }
        #EndRegion
    }
    End
    {
        $PSDefaultParameterValues.Remove('Write-Host:ForegroundColor')
    }
}

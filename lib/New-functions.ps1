function New-Folder
{
<#
    .SYNOPSIS
        Function:New-Folder

    .DESCRIPTION
        Deze funtie maakt op een goede manier een folder aan

    .PARAMETER Onlyifmissing
        Controleerd of de folder al bestaat en maakt deze (indien niet bestaat)

    .PARAMETER Override
        Verwijderd de hele map (als deze bestaat) en maakt deze dan opnieuw aan.

    .EXAMPLE
        Do-Createfolder -Path H:\Asdf -Onlyifmissing
#>
param(  [parameter(Mandatory=$true,Position=0)][ValidateNotNullOrEmpty()][System.String]$Path,
        [parameter(Mandatory=$false,ParameterSetName='WhatToDoExtra')][Switch]$Onlyifmissing,
        [parameter(Mandatory=$false,ParameterSetName='WhatToDoExtra')][Alias("Force")][Switch]$Override)
    if ($Onlyifmissing)
    {
        if (!(Test-Path -Path $Path))
        {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }
    }
    if ($Override)
    {
        if (Test-Path -Path $Path)
        {
            Remove-Item -Path $Path -Force -Recurse
        }
        New-Item -Path $Path -ItemType Directory | Out-Null
    }
    if (($Onlyifmissing -eq $false) -and ($Override -eq $false))
    {
        New-Item -Path $Path -ItemType Directory | Out-Null
    }
}

Function New-IniFile {
    <#
    .Synopsis
        Write hash content to INI file
    .Description
        Write hash content to INI file
    .Notes
        Author      : Oliver Lipkau <oliver@lipkau.net>
        Blog        : http://oliver.lipkau.net/blog/
        Source      : https://github.com/lipkau/PsIni
                      http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
        Version     : 1.0.0 - 2010/03/12 - OL - Initial release
                      1.0.1 - 2012/04/19 - OL - Bugfix/Added example to help (Thx Ingmar Verheij)
                      1.0.2 - 2014/12/11 - OL - Improved handling for missing output file (Thx SLDR)
                      1.0.3 - 2014/01/06 - CB - removed extra \r\n at end of file
                      1.0.4 - 2015/06/06 - OL - Typo (Thx Dominik)
                      1.0.5 - 2015/06/18 - OL - Migrate to semantic versioning (GitHub issue#4)
                      1.0.6 - 2015/06/18 - OL - Remove check for .ini extension (GitHub Issue#6)
                      1.1.0 - 2015/07/14 - CB - Improve round-tripping and be a bit more liberal (GitHub Pull #7)
                                           OL - Small Improvments and cleanup
                      1.1.2 - 2015/10/14 - OL - Fixed parameters in nested function
                      1.1.3 - 2016/08/18 - SS - Moved the get/create code for $FilePath to the Process block since it
                                                overwrites files piped in by other functions when it's in the Begin block,
                                                added additional debug output.
                      1.1.4 - 2016/12/29 - SS - Support output of a blank ini, e.g. if all sections got removed. This
                                                required removing [ValidateNotNullOrEmpty()] from InputObject
        #Requires -Version 2.0
    .Inputs
        System.String
        System.Collections.IDictionary
    .Outputs
        System.IO.FileSystemInfo
    .Parameter Append
        Adds the output to the end of an existing file, instead of replacing the file contents.
    .Parameter InputObject
        Specifies the Hashtable to be written to the file. Enter a variable that contains the objects or type a command or expression that gets the objects.
    .Parameter FilePath
        Specifies the path to the output file.
     .Parameter Encoding
        Specifies the file encoding. The default is UTF8.
    Valid values are:
    -- ASCII:  Uses the encoding for the ASCII (7-bit) character set.
    -- BigEndianUnicode:  Encodes in UTF-16 format using the big-endian byte order.
    -- Byte:   Encodes a set of characters into a sequence of bytes.
    -- String:  Uses the encoding type for a string.
    -- Unicode:  Encodes in UTF-16 format using the little-endian byte order.
    -- UTF7:   Encodes in UTF-7 format.
    -- UTF8:  Encodes in UTF-8 format.
     .Parameter Force
        Allows the cmdlet to overwrite an existing read-only file. Even using the Force parameter, the cmdlet cannot override security restrictions.
     .Parameter PassThru
        Passes an object representing the location to the pipeline. By default, this cmdlet does not generate any output.
     .Parameter Loose
        Adds spaces around the equal sign when writing the key = value
    .Example
        Out-IniFile $IniVar "C:\myinifile.ini"
        -----------
        Description
        Saves the content of the $IniVar Hashtable to the INI File c:\myinifile.ini
    .Example
        $IniVar | Out-IniFile "C:\myinifile.ini" -Force
        -----------
        Description
        Saves the content of the $IniVar Hashtable to the INI File c:\myinifile.ini and overwrites the file if it is already present
    .Example
        $file = Out-IniFile $IniVar "C:\myinifile.ini" -PassThru
        -----------
        Description
        Saves the content of the $IniVar Hashtable to the INI File c:\myinifile.ini and saves the file into $file
    .Example
        $Category1 = @{“Key1”=”Value1”;”Key2”=”Value2”}
        $Category2 = @{“Key1”=”Value1”;”Key2”=”Value2”}
        $NewINIContent = @{“Category1”=$Category1;”Category2”=$Category2}
        Out-IniFile -InputObject $NewINIContent -FilePath "C:\MyNewFile.ini"
        -----------
        Description
        Creating a custom Hashtable and saving it to C:\MyNewFile.ini
    .Link
        Get-IniContent
    #>

    [CmdletBinding()]
    [OutputType(
        [System.IO.FileSystemInfo]
    )]
    Param(
        [switch]$Append,

        [ValidateSet("Unicode","UTF7","UTF8","ASCII","BigEndianUnicode","Byte","String")]
        [Parameter()]
        [string]$Encoding = "UTF8",

        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -IsValid})]
        [Parameter(Mandatory=$True,
                   Position=0)]
        [string]$FilePath,

        [switch]$Force,

        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]
        [System.Collections.IDictionary]$InputObject,

        [switch]$Passthru,

        [switch]$Loose
    )

    Begin
    {
        Write-Debug "PsBoundParameters:"
        $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Debug $_ }
        if ($PSBoundParameters['Debug']) { $DebugPreference = 'Continue' }
        Write-Debug "DebugPreference: $DebugPreference"

        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"

        function Out-Keys
        {
            param(
                [ValidateNotNullOrEmpty()]
                [Parameter(ValueFromPipeline=$True,Mandatory=$True)]
                [System.Collections.IDictionary]$InputObject,

                [ValidateSet("Unicode","UTF7","UTF8","ASCII","BigEndianUnicode","Byte","String")]
                [Parameter(Mandatory=$True)]
                [string]$Encoding = "UTF8",

                [ValidateNotNullOrEmpty()]
                [ValidateScript({Test-Path $_ -IsValid})]
                [Parameter(Mandatory=$True,
                           ValueFromPipelineByPropertyName=$true)]
                [string]$Path,

                [Parameter(Mandatory=$True)]
                $delimiter,

                [Parameter(Mandatory=$True)]
                $MyInvocation
            )

            Process
            {
                if (!($InputObject.get_keys()))
                {
                    Write-Warning ("No data found in '{0}'." -f $FilePath)
                }
                Foreach ($key in $InputObject.get_keys())
                {
                    if ($key -match "^Comment\d+") {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing comment: $key"
                        Add-Content -Value "$($InputObject[$key])" -Encoding $Encoding -Path $Path
                    } else {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing key: $key"
                        Add-Content -Value "$key$delimiter$($InputObject[$key])" -Encoding $Encoding -Path $Path
                    }
                }
            }
        }

        $delimiter = '='
        if ($Loose)
            { $delimiter = ' = ' }

        #Splatting Parameters
        $parameters = @{
            Encoding     = $Encoding;
            Path         = $FilePath
        }

    }

    Process
    {
        if ($append)
        {
            Write-Debug ("Appending to '{0}'." -f $FilePath)
            $outfile = Get-Item $FilePath
        } else {
            Write-Debug ("Creating new file '{0}'." -f $FilePath)
            $outFile = New-Item -ItemType file -Path $Filepath -Force:$Force
        }

        if (!(Test-Path $outFile.FullName)) {Throw "Could not create File"}

        Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing to file: $Filepath"
        foreach ($i in $InputObject.get_keys())
        {
            if (!($InputObject[$i].GetType().GetInterface('IDictionary')))
            {
                #Key value pair
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing key: $i"
                Add-Content -Value "$i$delimiter$($InputObject[$i])" @parameters

            } elseif ($i -eq $script:NoSection) {
                #Key value pair of NoSection
                Out-Keys $InputObject[$i] `
                         @parameters `
                         -delimiter $delimiter `
                         -MyInvocation $MyInvocation
            } else {
                #Sections
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing Section: [$i]"

                # Only write section, if it is not a dummy ($script:NoSection)
                if ($i -ne $script:NoSection) { Add-Content -Value "`n[$i]" @parameters }

                if ( $InputObject[$i].Count) {
                    Out-Keys $InputObject[$i] `
                         @parameters `
                         -delimiter $delimiter `
                         -MyInvocation $MyInvocation
                }

            }
        }
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Writing to file: $FilePath"
    }

    End
    {
        if ($PassThru)
        {
            Write-Debug ("Returning file due to PassThru argument.")
            Return (Get-Item $outFile)
        }
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"
    }
}


function New-Messagebox 
{
<#
    .SYNOPSIS
        Function:New-messagebox

    .DESCRIPTION
        Deze funtie laat een bericht zien aan de gebruiker

    .PARAMETER sMessage
        - Alias = Message, body
        De daadwerkelijke inhoud van het bericht.. denk Main body text
        
    .PARAMETER sTitle
        - Alias = Title, Header
        De tekst van het venster zelf... denk Header text

    .PARAMETER sButtons
        - Alias = Buttons
        - ValidateSet = "OK", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel"
        De knoppen die gebruikt mogen worden

    .PARAMETER sIconButton
        - Alias = IconButton
        - ValidateSet = "None", "Hand", "Error", "Stop", "Question", "Exclamation", "Warning", "Asterisk", "Information"
        Welk icoontje moet getoont worden links van de sMessage?

    .PARAMETER sSelectedButton
        - Optioneel
        - Alias = SelectedButton
        Welke van de knoppen moet standaard geselecteerd zijn. Hier kan je nummers gebruiken of tekst.

#>
param(  [parameter(Mandatory=$true)][Alias("Message", "body")][System.String]$sMessage,
        [parameter(Mandatory=$true)][Alias("Title", "Header")][System.String]$sTitle,
        [parameter(Mandatory=$true)][ValidateSet("OK", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")][Alias("Buttons")][System.String]$sButtons,
        [parameter(Mandatory=$true)][ValidateSet("None", "Hand", "Error", "Stop", "Question", "Exclamation", "Warning", "Asterisk", "Information")][Alias("IconButton")][System.String]$sIconButton,
        [parameter(Mandatory=$false)][Alias("SelectedButton")][System.Windows.Forms.MessageBoxDefaultButton]$sSelectedButton)
    if ($sSelectedButton -eq "") {
        [System.Windows.Forms.MessageBox]::Show($sMessage,$sTitle,$sButtons,$sIconButton)
    } else {
        [System.Windows.Forms.MessageBox]::Show($sMessage,$sTitle,$sButtons,$sIconButton,$sSelectedButton)
    }
}

Function New-WriteLine_Debug
{
<#
    .SYNOPSIS
        Function:New-WriteLine_Debug

    .DESCRIPTION
        Deze funtie schijft een debug regel weg.

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param(
    [parameter(Mandatory=$true,  Position=0)][System.String]$Info,
    [parameter(Mandatory=$false, Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
    [parameter(Mandatory=$false, Position=2)][System.String]$File,
    [parameter(Mandatory=$false, Position=3)][System.String]$User = "Unknown",
    [parameter(Mandatory=$false, Position=4)][System.String]$Scriptname = "Unknown",
    [parameter(Mandatory=$false, Position=5)][Switch]$ToConsole)
    [System.Boolean]$bOktodo = $false
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $bOktodo = $true
    }
    else
    {
        $bOktodo = $(Get-Loglevelchallenge -SourceSeverity "Debug" -DestinationSeverity $ActualLogLevel)
    }
    if ($bOktodo)
    {
        $Info.Split("`n") | ForEach {
            if (!([System.string]::IsNullOrEmpty($File)))
            {
                New-WriteLine_ToFile -sInfo "Debug,$(get-date -Format "yyyy-MM-dd HH:mm:ss"),$User,$Scriptname,$_" -sFile $File
            }
            if ($ToConsole)
            {
                Write-Host $_ -ForegroundColor Gray
            }
        }
    }
}

Function New-WriteLine_Error
{
<#
    .SYNOPSIS
        Function:New-WriteLine_Error

    .DESCRIPTION
        Deze funtie schijft een error regel weg.

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param(
    [parameter(Mandatory=$true,  Position=0)][System.String]$Info,
    [parameter(Mandatory=$false, Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
    [parameter(Mandatory=$false, Position=2)][System.String]$File,
    [parameter(Mandatory=$false, Position=3)][System.String]$User = "Unknown",
    [parameter(Mandatory=$false, Position=4)][System.String]$Scriptname = "Unknown",
    [parameter(Mandatory=$false, Position=5)][Switch]$ToConsole)
    [System.Boolean]$bOktodo = $false
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $bOktodo = $true
    }
    else
    {
        $bOktodo = $(Get-Loglevelchallenge -SourceSeverity "Error" -DestinationSeverity $ActualLogLevel)
    }
    if ($bOktodo)
    {
        $Info.Split("`n") | ForEach {
            if (!([System.string]::IsNullOrEmpty($File)))
            {
                New-WriteLine_ToFile -sInfo "Error,$(get-date -Format "yyyy-MM-dd HH:mm:ss"),$User,$Scriptname,$_" -sFile $File
            }
            if ($ToConsole)
            {
                Write-Host $_ -ForegroundColor Red
            }
        }
    }
}

Function New-WriteLine_Information
{
<#
    .SYNOPSIS
        Function:New-WriteLine_Information

    .DESCRIPTION
        Deze funtie schijft een info regel weg.

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param(
    [parameter(Mandatory=$true,  Position=0)][System.String]$Info,
    [parameter(Mandatory=$false, Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
    [parameter(Mandatory=$false, Position=2)][System.String]$File,
    [parameter(Mandatory=$false, Position=3)][System.String]$User = "Unknown",
    [parameter(Mandatory=$false, Position=4)][System.String]$Scriptname = "Unknown",
    [parameter(Mandatory=$false, Position=5)][Switch]$ToConsole)
    [System.Boolean]$bOktodo = $false
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $bOktodo = $true
    }
    else
    {
        $bOktodo = $(Get-Loglevelchallenge -SourceSeverity "Information" -DestinationSeverity $ActualLogLevel)
    }
    if ($bOktodo)
    {
        $Info.Split("`n") | ForEach {
            if (!([System.string]::IsNullOrEmpty($File)))
            {
                New-WriteLine_ToFile -sInfo "Information,$(get-date -Format "yyyy-MM-dd HH:mm:ss"),$User,$Scriptname,$_" -sFile $File
            }
            if ($ToConsole)
            {
                Write-Host $_ -ForegroundColor White
            }
        }
    }
}

Function New-WriteLine_Verbose
{
<#
    .SYNOPSIS
        Function:New-WriteLine_Verbose

    .DESCRIPTION
        Deze funtie schijft een verbose regel weg.

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param(
    [parameter(Mandatory=$true,  Position=0)][System.String]$Info,
    [parameter(Mandatory=$false, Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
    [parameter(Mandatory=$false, Position=2)][System.String]$File,
    [parameter(Mandatory=$false, Position=3)][System.String]$User = "Unknown",
    [parameter(Mandatory=$false, Position=4)][System.String]$Scriptname = "Unknown",
    [parameter(Mandatory=$false, Position=5)][Switch]$ToConsole)
    [System.Boolean]$bOktodo = $false
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $bOktodo = $true
    }
    else
    {
        $bOktodo = $(Get-Loglevelchallenge -SourceSeverity "Verbose" -DestinationSeverity $ActualLogLevel)
    }
    if ($bOktodo)
    {
        $Info.Split("`n") | ForEach {
            if (!([System.string]::IsNullOrEmpty($File)))
            {
                New-WriteLine_ToFile -sInfo "Verbose,$(get-date -Format "yyyy-MM-dd HH:mm:ss"),$User,$Scriptname,$_" -sFile $File
            }
            if ($ToConsole)
            {
                Write-Host $_ -ForegroundColor DarkGray
            }
        }
    }
}

Function New-WriteLine_Warning
{
<#
    .SYNOPSIS
        Function:New-WriteLine_Warning

    .DESCRIPTION
        Deze funtie schijft een Warning regel weg.

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param(
    [parameter(Mandatory=$true,  Position=0)][System.String]$Info,
    [parameter(Mandatory=$false, Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
    [parameter(Mandatory=$false, Position=2)][System.String]$File,
    [parameter(Mandatory=$false, Position=3)][System.String]$User = "Unknown",
    [parameter(Mandatory=$false, Position=4)][System.String]$Scriptname = "Unknown",
    [parameter(Mandatory=$false, Position=5)][Switch]$ToConsole)
    [System.Boolean]$bOktodo = $false
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $bOktodo = $true
    }
    else
    {
        $bOktodo = $(Get-Loglevelchallenge -SourceSeverity "Warning" -DestinationSeverity $ActualLogLevel)
    }
    if ($bOktodo)
    {
        $Info.Split("`n") | ForEach {
            if (!([System.string]::IsNullOrEmpty($File)))
            {
                New-WriteLine_ToFile -sInfo "Warning,$(get-date -Format "yyyy-MM-dd HH:mm:ss"),$User,$Scriptname,$_" -sFile $File
            }
            if ($ToConsole)
            {
                Write-Host $_ -ForegroundColor DarkYellow
            }
        }
    }
}

Function New-WriteLine
{
<#
    .SYNOPSIS
        Function:New-WriteLine

    .DESCRIPTION
        Deze funtie schijft een regel weg.
        
    .PARAMETER Severity
        Geeft aan met welk logniveau dit weggeschreven moet worden

    .PARAMETER Info
        Hetgeen wat geschreven moet worden

    .PARAMETER ActualLogLevel
        - Optioneel
        - ValidateSet = "Debug", "Error", "Information", "Verbose", "Warning"
        Als er gebruik wordt gemaakt van een algemeen logniveau moet deze met deze parameter worden meegegeven. Er wordt getoetst of het log wel geschreven mag worden

    .PARAMETER File
        - Optioneel
        Heeft aan naar welke file er weggeschreven moet worden.

    .PARAMETER ToConsole
        - Optioneel
        - Switch
        Heeft aan of de regel naar de console geschreven moet worden.
        
    .PARAMETER User
        - Optioneel
        - Default = "Unknown"
        Heeft de gebruiker aan
        
    .PARAMETER Scriptname
        - Optioneel
        - Default = "Unknown"
        Schijft weg om welk script dit gaat.
#>
Param( [parameter(Mandatory=$true,  Position=0)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$Severity,
       [parameter(Mandatory=$true,  Position=1)][System.String]$Info,
       [parameter(Mandatory=$true,  Position=2)][System.String]$File,
       [parameter(Mandatory=$false, Position=3)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$ActualLogLevel,
       [parameter(Mandatory=$false, Position=4)][System.String]$User = "Unknown",
       [parameter(Mandatory=$false, Position=5)][System.String]$Scriptname = "Unknown",
       [parameter(Mandatory=$false, Position=6)][Switch]$ToConsole)
    if ([System.String]::IsNullOrEmpty($ActualLogLevel))
    {
        $ActualLogLevel = $Severity
    }
    if ($ToConsole)
    {
        Switch($Severity)
        {
            "Debug"       { Do-WriteDebug       -Info $Info -File $File -User $User -Scriptname $Scriptname -ToConsole }
            "Error"       { Do-WriteError       -Info $Info -File $File -User $User -Scriptname $Scriptname -ToConsole }
            "Information" { Do-WriteInformation -Info $Info -File $File -User $User -Scriptname $Scriptname -ToConsole }
            "Verbose"     { Do-WriteVerbose     -Info $Info -File $File -User $User -Scriptname $Scriptname -ToConsole }
            "Warning"     { Do-WriteWarning     -Info $Info -File $File -User $User -Scriptname $Scriptname -ToConsole }
        }
    }
    else
    {
        Switch($Severity)
        {
            "Debug"       { Do-WriteDebug       -Info $Info -File $File -User $User -Scriptname $Scriptname }
            "Error"       { Do-WriteError       -Info $Info -File $File -User $User -Scriptname $Scriptname }
            "Information" { Do-WriteInformation -Info $Info -File $File -User $User -Scriptname $Scriptname }
            "Verbose"     { Do-WriteVerbose     -Info $Info -File $File -User $User -Scriptname $Scriptname }
            "Warning"     { Do-WriteWarning     -Info $Info -File $File -User $User -Scriptname $Scriptname }
        }
    }
}

Function New-WriteLine_ToFile #Private function
{
<#
    .SYNOPSIS
        Function:New-WriteLine_ToFile

    .DESCRIPTION
        Deze funtie schijft een regel weg naar een bestand.

    .PARAMETER sInfo
        Hetgeen wat geschreven moet worden

    .PARAMETER File
        Heeft aan naar welke file er weggeschreven moet worden.

#>
Param(  [parameter(Mandatory=$true,  Position=0)][System.String]$sInfo,
        [parameter(Mandatory=$true,  Position=1)][System.String]$sFile)
    [System.Boolean]$bDone = $false
    [System.DateTime]$dtStart = (Get-Date)
    do
    {
        New-Variable -Name alErrorBin
        [System.Collections.ArrayList]$alErrorBin
        Add-Content -Path $sFile -Value $sInfo -ErrorAction SilentlyContinue -ErrorVariable alErrorBin
        if ($alErrorBin.count -eq 0)
        {
            $bDone = $true
        }
        else
        {
            $bDone = $false
            Start-Sleep -Milliseconds 250
        }
        Remove-Variable -Name alErrorBin
    }
    Until (((New-TimeSpan -Start $dtStart -End (Get-Date)).seconds -ge 2) -or ($bDone))
}



Function Get-Loglevelchallenge
{
Param(  [parameter(Mandatory=$true,  Position=0)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$SourceSeverity,
        [parameter(Mandatory=$true,  Position=1)][ValidateSet("Debug", "Error", "Information", "Verbose", "Warning")][System.String]$DestinationSeverity)
    Begin
    {
    }
    Process  
    {  
        [System.boolean]$bOk = $false
        Switch($DestinationSeverity)
        {
            "Debug"
            { 
                if (($SourceSeverity -eq "Debug") -or ($SourceSeverity -eq "Error") -or ($SourceSeverity -eq "Information") -or ($SourceSeverity -eq "Warning"))
                {
                    $bOk =  $true
                }
            }
            "Error" 
            { 
                if ($SourceSeverity -eq "Error")
                {
                    $bOk =  $true
                }
            }
            "Information"
            { 
                if (($SourceSeverity -eq "Error") -or ($SourceSeverity -eq "Information") -or ($SourceSeverity -eq "Warning"))
                {
                    $bOk =  $true
                }
            }
            "Verbose"
            { 
                if (($SourceSeverity -eq "Verbose") -or ($SourceSeverity -eq "Debug") -or ($SourceSeverity -eq "Error") -or ($SourceSeverity -eq "Information") -or ($SourceSeverity -eq "Warning"))
                {
                    $bOk =  $true
                }
            }
            "Warning"
            { 
                if (($SourceSeverity -eq "Error") -or ($SourceSeverity -eq "Warning"))
                {
                    $bOk =  $true
                }
            }
        }
        return $bOk
    }
    End
    {
    }
}

Function Get-IniContent 
{  
<#
    .SYNOPSIS
        Function:Get-IniContent

    .DESCRIPTION
        Read the content of an INI file and put it in a Hashtable

        Return = [Hashtable]

    .PARAMETER FilePath
        - Mandatory
        - *.ini validation
        The string where the .ini file is located
#>
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Position=0,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    Begin  
        { }  
          
    Process  
    {    
        $ini = @{}  
        switch -regex -file $FilePath  
        {  
            "^\[(.+)\]$" # Section  
            {  
                $section = $matches[1]  
                $ini[$section] = @{}  
                $CommentCount = 0  
            }  
            "^(;.*)$" # Comment  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $value = $matches[1]  
                $CommentCount = $CommentCount + 1  
                $name = "Comment" + $CommentCount  
                $ini[$section][$name] = $value  
            }   
            "(.+?)\s*=\s*(.*)" # Key  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $name,$value = $matches[1..2]  
                $ini[$section][$name] = $value  
            }  
        } 
        Return $ini  
    }  

    End
    {
    }
} 

function Get-PhunQuote
{
<#
    .SYNOPSIS
        Function:Get-PhunQuote

    .DESCRIPTION
        Just something to brighten your day

        Return = [String]
#>
    [System.String]$sReturn = "xxx"
    Switch ([Math]::Round((Get-Date).Second / 2 ))
    {
        1  { $sReturn = "Chuck Norris has already been to Mars; that's why there are no signs of life." }
        2  { $sReturn = "Chuck Norris died 20 years ago, Death just hasn't built up the courage to tell him yet." }
        3  { $sReturn = "There used to be a street named after Chuck Norris, but it was changed because nobody crosses Chuck Norris and lives." }
        4  { $sReturn = "Some can walk on water, Chuck Norris can swim through land." }
        5  { $sReturn = "Chuck Norris counted to infinity - twice." }
        6  { $sReturn = "Chuck Norris is the reason why Waldo is hiding." }
        7  { $sReturn = "When the Boogeyman goes to sleep every night, he checks his closet for Chuck Norris." }
        8  { $sReturn = "Chuck Norris once urinated in a semi truck's gas tank as a joke....that truck is now known as Optimus Prime." }
        9  { $sReturn = "Chuck Norris can do a wheelie on a unicycle" }
        10 { $sReturn = "When I get sad, I stop being sad and be awesome instead." }
        11 { $sReturn = "When Chuck Norris was born he drove his mom home from the hospital" }
        12 { $sReturn = "Chuck Norris does not sleep. He waits." }
        13 { $sReturn = "They once made a Chuck Norris toilet paper, but there was a problem: It wouldn't take shit from anybody." }
        14 { $sReturn = "Chuck Norris donates blood to NASA for rocket fuel." }
        15 { $sReturn = "Chuck Norris got set on fire. The fire had to stop, drop, and roll." }
        16 { $sReturn = "Some people wear Superman pajamas. Superman wears Chuck Norris pajamas." }
        17 { $sReturn = "Chuck Norris lit a match and ended the Cold War." }
        18 { $sReturn = "Chuck Norris doesn't read books. He stares them down until he gets the information he wants." }
        19 { $sReturn = "Chuck Norris can light a fire by rubbing two ice-cubes together." }
        20 { $sReturn = "Chuck Norris doesn�t wear a watch. HE decides what time it is." }
        21 { $sReturn = "When Chuck Norris does a pushup, he isn't lifting himself up, he's pushing the Earth down." }
        22 { $sReturn = "Chuck Norris will never have a heart attack. His heart isn't nearly foolish enough to attack him." }
        23 { $sReturn = "Chuck Norris doesn't flush the toilet, he scares the sh*t out of it" }
        24 { $sReturn = "Chuck Norris' hand is the only hand that can beat a Royal Flush." }
        25 { $sReturn = "Chuck Norris can speak braille." }
        26 { $sReturn = "Do not take life too seriously. You will never get out of it alive." }
        27 { $sReturn = "A woman's mind is cleaner than a man's: She changes it more often." }
        28 { $sReturn = "Suit up!" }
        29 { $sReturn = "A lie is just a really great story that someone ruined with the truth." }
        30 { $sReturn = "Chuck Norris knows the letter after Z." }
    }
    Return $sReturn
}

function Get-UserInput
{
<#
    .SYNOPSIS
        Function:Get-UserInput

    .DESCRIPTION
        The oldschool VBS way of asking input

        Return = [String]

    .PARAMETER sMessage
        - Alias = Message, body
        The actual question itself. Think of this as the main-body of the window
        
    .PARAMETER sTitle
        - Alias = Title, Header
        The Title/Header text in the topleft corner of the window
#>
Param(  [parameter(Mandatory=$true)][Alias("Message", "body")][System.String]$sMessage,
        [parameter(Mandatory=$true)][Alias("Title", "Header")][System.String]$sTitle
)
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    Return [Microsoft.VisualBasic.Interaction]::InputBox($sMessage, $sTitle) 

}

Function Get-SaveFileLocation {
    <#
        .SYNOPSIS
            Function:Get-SaveFileLocation
    
        .DESCRIPTION
            Get a file location from the user
    
        .PARAMETER initialDirectory
            - Alias = cd, Dir, Directory
            [Optional]
            The directory where to start the Users seach for that one magical place.
            
        .PARAMETER filter
            [Optional]
            The filter the user can use to save the file. for example: "Text files (*.txt)|*.txt|All files (*.*)|*.*""
    #>
    Param(  [parameter(Mandatory=$false)][Alias("cd", "Dir", "Directory")][System.String]$initialDirectory,
            [parameter(Mandatory=$false)][System.String]$filter
    )
        $SaveChooser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        if ($initialDirectory) {
            $SaveChooser.initialDirectory = $initialDirectory
        }
        if ($filter) {
            $SaveChooser.filter = $filter
        }
        $SaveChooser.ShowDialog() | Out-Null
        return $SaveChooser.Filename
    }


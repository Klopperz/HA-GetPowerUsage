[System.String]$sScript_Version         = "0.1"
[System.String]$sScript_Name            = "HA-GetPowerUsage"
[System.String]$sUser                   = $env:username
[System.String]$sFolder_Root            = (Get-Item $PSScriptRoot).parent.FullName
[System.String]$sFolder_Bin             = "$sFolder_Root\bin"
[System.String]$sFolder_Etc             = "$sFolder_Root\etc"
[System.String]$sFolder_Home            = "$sFolder_Root\home"
[System.String]$sFolder_Lib             = "$sFolder_Root\lib"
[System.String]$sFolder_Log             = "$sFolder_Root\log"
[System.String]$sFolder_Srv             = "$sFolder_Root\srv"
[System.String]$sFolder_User            = "$sFolder_Home\$sUser"
[System.String]$sScript_Config          = "$sFolder_Etc\$sScript_Name.ini"
[System.String]$sFile_Log               = "$sFolder_Log\$sScript_Name.log"
[System.String]$sLanguage_string        = "Strings-$(([System.Threading.Thread]::CurrentThread.CurrentUICulture).Name.split("-")[0].toUpper())"
if ("Strings-NL","Strings-EN" -notcontains $sLanguage_String )
{
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
. $sFolder_Lib\HAPowerUsage-functions.ps1
. $sFolder_Lib\HAPowerUsage-scriptblocks.ps1
. $sFolder_Lib\Form-functions.ps1
. $sFolder_Lib\Get-functions.ps1
. $sFolder_Lib\Set-functions.ps1
. $sFolder_Lib\New-functions.ps1

[Hashtable]$htScript_config             = Get-IniContent $sScript_Config
[System.String]$sFile_ico               = $($htScript_config["Files"]["ico"]).Replace("%SVR%",$sFolder_Srv)
[System.String]$sFile_usersettings      = $($htScript_config["Files"]["usersettings"]).Replace("%USERHOME%",$sFolder_User)

. $sFolder_Bin\Get-HAPowerUsage-main.ps1

if (-not(Test-Path $sFile_usersettings)) {
    Start-SettingsBox -userparamfile $sFile_usersettings
}
if (Test-Path $sFile_usersettings) {
    [Hashtable]$htUser_config = Get-IniContent $sFile_usersettings
    $authHA = Get-AuthenticationObject -Token $htUser_config.settings.hatoken
    $haHost = $htUser_config.settings.hahost
    $socketName = $htUser_config.settings.socketname

    #start
    $frmMain.ShowDialog()
}
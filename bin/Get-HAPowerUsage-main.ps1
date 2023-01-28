function Start-SettingsBox {
param (
    [Parameter(Mandatory=$true)][string]$userparamfile
)
    [System.Windows.Forms.Form]$frmSettings =      New-Form                     -width 275 -height 150 -header $("$sScript_Name - v$sScript_Version - Settings") -borderstyle FixedDialog -icon $sFile_ico -hide_controlbox 
                                                   New-Formlabel   -x 1   -y 1  -width 100 -height 20 -ParentObject $frmSettings -Text "Hostname/IP:" | Out-Null
    [System.Windows.Forms.TextBox]$txtHAHost =     New-Formtextbox -x 105 -y 1  -width 145 -height 20 -ParentObject $frmSettings -Text $contractcode
                                                   New-Formlabel   -x 1   -y 30 -width 100 -height 20 -ParentObject $frmSettings -Text "Token" | Out-Null
    [System.Windows.Forms.TextBox]$txtHAToken =    New-Formtextbox -x 105 -y 30 -width 145 -height 20 -ParentObject $frmSettings -Text $username
                                                   New-Formlabel   -x 1   -y 60 -width 100 -height 20 -ParentObject $frmSettings -Text "Socket Name" | Out-Null
    [System.Windows.Forms.TextBox]$txtSocketName = New-Formtextbox -x 105 -y 60 -width 145 -height 20 -ParentObject $frmSettings -Text $emailonerror
                                                   New-Formbutton  -x 105 -y 90 -width 145 -height 20 -ParentObject $frmSettings -Text "Go" -Script { 
        Write-Host $userparamfile
        $Authenticationparams = @{
            "hahost" = $txtHAHost.Text 
            "hatoken" = $txtHAToken.Text
            "socketname" = $txtSocketName.Text 
        }
        $NewIniFile = @{"settings" = $Authenticationparams}
        New-IniFile -InputObject $NewIniFile -FilePath $userparamfile -Force
        $frmSettings.Close()
    } | Out-Null
    $frmSettings.ShowDialog()
}
 
[System.Windows.Forms.Form]  $frmMain =           New-Form                      -Width 790 -height 800 -header $("$sScript_Name - v$sScript_Version") -borderstyle FixedDialog -icon $sFile_ico -hide_maximizebox

                                                  New-Formlabel -x 1   -y 28 -width 300 -height 20 -ParentObject $frmMain -Text $htScript_config.$sLanguage_String.Label_PerDay   | Out-null
                                                  New-Formlabel -x 385 -y 28 -width 300 -height 20 -ParentObject $frmMain -Text $htScript_config.$sLanguage_String.Label_PerMonth | Out-null

[System.Windows.Forms.ListView]$lvUsagePerDay =   New-Formlistview -x 1   -y 50 -Width 380 -height 729 -ParentObject $frmMain -view "Details"
[System.Windows.Forms.ListView]$lvUsagePerMonth = New-Formlistview -x 385 -y 50 -Width 380 -height 729 -ParentObject $frmMain -view "Details"
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_date         -Width 100 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_starttime    -Width 50  -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_stoptime     -Width 50  -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerMonth -Text $htScript_config.$sLanguage_String.ListviewColumn_date         -Width 150 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_powerUsage   -Width 100 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerMonth -Text $htScript_config.$sLanguage_String.ListviewColumn_powerUsage   -Width 100 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_powerUnit    -Width 100 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerMonth -Text $htScript_config.$sLanguage_String.ListviewColumn_powerUnit    -Width 100 -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_powerCost    -Width 50  -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerMonth -Text $htScript_config.$sLanguage_String.ListviewColumn_powerCost    -Width 50  -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerDay   -Text $htScript_config.$sLanguage_String.ListviewColumn_amount_total -Width 50  -Silence
                                                  Add-ListviewColumn -oListView $lvUsagePerMonth -Text $htScript_config.$sLanguage_String.ListviewColumn_amount_total -Width 50  -Silence

New-Formbutton  -x 1   -y 1 -width 190  -height 20  -ParentObject $frmMain -Script $addNewDay -Text $htScript_config.$sLanguage_String.Button_NewDay | Out-null
New-Formbutton  -x 195 -y 1 -width 190  -height 20  -ParentObject $frmMain -Script $setTariff -Text $htScript_config.$sLanguage_String.Button_SetRate | Out-null

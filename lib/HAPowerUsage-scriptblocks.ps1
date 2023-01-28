[scriptblock]$addNewDay = {
    [datetime[]]$dtDates = @()
    Foreach ($alreadyKnownDate in $lvUsagePerDay.Items){
        $dtDates += [datetime]::ParseExact($alreadyKnownDate.SubItems[0].Text, "yyyy-MM-dd", $null)
    }

    $frmAddDay =       New-Form                     -width 210 -height 250 -header "Add day" -borderstyle FixedSingle -icon $sFile_ico -hide_maximizebox -hide_minimizebox
    $calDaySelection = New-Formcalendar -x 1 -y 1   -width 150 -height 150 -ParentObject $frmAddDay -ShowTodayCircle -MaxSelectionCount 5 -bolteddates $dtDates
                       New-Formbutton   -x 1 -y 180 -width 190 -height 25 -ParentObject $frmAddDay -Text "Submit" -Script {
        $startDate = $calDaySelection.SelectionStart
        $endDate = $calDaySelection.SelectionEnd
        while($startDate -le $endDate) {
            $date = $startDate.ToString("yyyy-MM-dd")
            Get-DailyPowerUsage `
                -authHA $authHA `
                -haHost $haHost `
                -socketName $socketName `
                -Path $sFolder_User `
                -startDateTime "$date`T8:00:00%2B01:00" `
                -stopDateTime "$date`T18:00:00%2B01:00"

            $startDate = $startDate.AddDays(1)
        }
        $frmAddDay.Close()
    } | Out-Null

    $frmAddDay.ShowDialog()
}


[scriptblock]$setTariff = {
    Write-host "2faegdsadsaffa"
}
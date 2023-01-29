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

    Invoke-Command -ScriptBlock $refreshDays
}

[scriptblock]$refreshDays = {
    [System.Windows.Forms.ListView]$lvUsagePerDay.items.Clear()
    [System.Windows.Forms.ListView]$lvUsagePerMonth.Clear()
    
    $powerConsumptionDaily=@()
    $powerConsumptionMonthly=@()
    foreach ($powerCunsumptionFile in (Get-ChildItem -Path $sFolder_User "*-PowerConsumption.csv")){
        $powerConsumptionDaily += Import-Csv -Path $powerCunsumptionFile
    }
    foreach ($powerConsumptionDay in $powerConsumptionDaily){
        [double]$powerConsumptionDaySum = [convert]::ToDouble($powerConsumptionDay.Sum)
        $lviPowerDay = New-Object System.Windows.Forms.ListViewItem($powerConsumptionDay.Day)
        $lviPowerDay.SubItems.Add([Convert]::toString($powerConsumptionDay.Start)) | Out-Null
        $lviPowerDay.SubItems.Add([Convert]::toString($powerConsumptionDay.End))   | Out-Null
        $lviPowerDay.SubItems.Add([Convert]::toString($powerConsumptionDaySum))    | Out-Null
        $lviPowerDay.SubItems.Add([Convert]::toString($powerConsumptionDay.Unit))  | Out-Null
        $lvUsagePerDay.Items.Add($lviPowerDay)                                     | Out-Null

        $month = ([datetime]::parseexact($powerConsumptionDay.Day, 'yyyy-MM-dd', $null)).Month
        $monthAlreadyExists = $false
        for ($i=0 ; $i -lt $powerConsumptionMonthly.Count ; $i++) {
            if ($powerConsumptionMonthly[$i]['Month'] -like $month){
                $powerConsumptionMonthly[$i]['Sum'] += $powerConsumptionDaySum
                $monthAlreadyExists = $true
            }
        }
        if (!$monthAlreadyExists){
            $powerConsumptionMonthly += @{
                Month = $month
                Sum = $powerConsumptionDaySum
                Unit = $powerConsumptionDay.Unit
            }
        }
    }

    foreach ($powerConsumptionMonth in $powerConsumptionMonthly){
        $lviPowerMonth = New-Object System.Windows.Forms.ListViewItem($powerConsumptionMonth.Month)
        $lviPowerMonth.SubItems.Add([Convert]::toString($powerConsumptionMonth.Sum))   | Out-Null
        $lviPowerMonth.SubItems.Add([Convert]::toString($powerConsumptionMonth.Unit))  | Out-Null
        $lvUsagePerMonth.Items.Add($lviPowerMonth)                                     
    }
}

[scriptblock]$setTariff = {
    Write-host "2faegdsadsaffa"
}
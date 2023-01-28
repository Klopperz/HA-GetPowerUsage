

Function Get-AuthenticationObject {
param (
    [Parameter(Mandatory=$true)][string]$Token
)
    return @{
        Authorization= "Bearer $Token"
        'content-type'= "application/json"
    }
}

Function Get-DailyPowerUsage {
    param (
        [Parameter(Mandatory=$true)]$authHA,
        [Parameter(Mandatory=$true)][string]$haHost,
        [Parameter(Mandatory=$true)][string]$socketName,
        [Parameter(Mandatory=$true)][string]$startDateTime,
        [Parameter(Mandatory=$true)][string]$stopDateTime,
        [Parameter(Mandatory=$true)][string]$path
    )
    $date = $startDateTime.Split("T")[0]
    $dateMonth  = $startDateTime.Split("-")[1]
    $historyUri = "http://$haHost`:20810/api/history/period/$startDateTime`?end_time=$stopDateTime&filter_entity_id=sensor.$socketName`_total_power_import_t1"
    $history    = (Invoke-RestMethod -Method Get -Headers $authHA -Uri $historyUri)[0]
    $units = $history[0].attributes.unit_of_measurement
    $type = $history[0].attributes.device_class
    [double]$start = $history[0].state
    [double]$end = $history[-1].state
    [double]$sum = $end-$start
    $Header = 'Day','Start','End','Sum','Unit'
    if (test-path "$path\$dateMonth-PowerConsumption.csv") {
        $csvFile = Import-Csv -Path "$path\$dateMonth-PowerConsumption.csv" -Header $Header
    } else {
        $csvFile = @()
    }
    Write-host "On $date we started with $start $units and ended with $end $units of $type. This means there was $sum $units of $type consumed."
    $csvFile += @{
        Day = $date
        Start = $startDateTime.Split('T')[1]
        End = $stopDateTime.Split('T')[1]
        Sum = $sum
        Unit = $units
    }
    $csvFile | Export-Csv -Path "$path\$dateMonth-PowerConsumption.csv" -

    return $null
}
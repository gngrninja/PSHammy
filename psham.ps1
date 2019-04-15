[cmdletbinding()]
param()
#import functions
$Public  = @( Get-ChildItem -Path "$PSScriptRoot\functions\public\*.ps1" )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\functions\private\*.ps1" )


@($Public + $Private) | ForEach-Object {

    Try {

        Write-Verbose "Importing -> [$($_.FullName)]!"
        . $_.FullName

    } Catch {

        Write-Error -Message "Failed to import function $($_.FullName): $_"
        
    }

}

$config = Import-Config -Path "$PSScriptRoot/config.json"
$data = Get-AzureMapsInfo -RequestData "97209" -RequestType "Search"
write-host $data
$myCallSign = 'KF7IGN'
$myGrid     = 'CN85'

function Import-WsjtxLog {
    [cmdletbinding()]
    param(
        $LogPath = '.\wsjtx.log'
    )

    [array]$logHeaders = (
        'WorkedDate',
        'WorkedTime',
        'WorkedDateAgain',
        'WorkedTimeAgain',
        'WorkedCallSign',
        'GridSquare',
        'Frequency',
        'Mode',
        'ReportedSignalRec',
        'ReportedSignalSent',
        'empty1',
        'empty2',
        'empty3'
    )
    
    Write-Host ($logHeaders | Out-String)
    Write-Verbose "Log file [$($pathToLogFile)] accessible..."

    $importedLog = Import-Csv -Path $LogPath -Header $logHeaders

    return $importedLog

}


$logData = Import-WsjtxLog

if ($logData) {

    $processed = Get-Content ".\processed.json" | ConvertFrom-Json

    $fromToday = $logData | Where-Object {$_.WorkedDate -eq (Get-Date).ToString("yyyy-MM-dd")}

    $fromToday

    $myCallInfo = Invoke-CallSignLookup -CallSign $myCallSign

    foreach ($contact in $fromToday) {


    }
 }

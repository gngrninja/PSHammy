
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

function Invoke-CallSignLookup {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $CallSign
    )

    begin {

        $url = "https://callook.info/$($CallSign)/json"

    }
    process {

        try {

            $result = Invoke-RestMethod -Uri $Url  

        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error $errorMessage

        }

    }
    end {

        return $result

    }
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

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
    
    Write-Verbose ($logHeaders | Out-String)
    Write-Verbose "Log file [$($LogPath)] accessible..."

    $importedLog = Import-Csv -Path $LogPath -Header $logHeaders

    return $importedLog

}

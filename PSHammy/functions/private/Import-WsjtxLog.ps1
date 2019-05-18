function Import-WsjtxLog {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [string]
        $LogPath
    )

    begin {
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

        Write-Verbose "Log file headers for WSJTX.log..."        
        Write-Verbose ($logHeaders | Out-String)
    }

    
    process {

        Write-Verbose "Log file [$($LogPath)] accessible... attempting to import"

        try {

            $importedLog = Import-Csv -Path $LogPath -Header $logHeaders
            
        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error "Error importing log file from [$LogPath] -> [$errorMessage]!"
            break

        }        
    }

    end {

        return $importedLog

    }
}

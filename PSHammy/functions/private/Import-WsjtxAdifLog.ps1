function Import-WsjtxAdifLog {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [string]
        $LogPath
    )

    begin {

        $script:rawAdifLog = $null

    }

    process {

        $rawAdifLog = Get-Content -Path $LogPath 

        $logEntries = ConvertFrom-Adif -Text $rawAdifLog

    }

    end {

        return $logEntries
        
    }

}
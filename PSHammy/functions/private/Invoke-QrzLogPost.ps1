function Invoke-QrzLogPost {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $Adif
    )

    begin {
        
        #$findMe      = $null
        #$rawLogMatch = $null
        $body        = $null
        
        #$findMe = ".+$($Adif.call).+$($Adif.time_on).+"
        
        #$rawLogMatch = Get-Content -Path $wsjtxAdifLogPath | Where-Object {$_ -match $findMe}                    
        $body = @{

            ACTION = 'INSERT'
            KEY    = $config.QRZLogApiKey
            ADIF   = $Adif.RawAdif

        }        

        [string]$baseUrl = 'https://logbook.qrz.com/api'

        
    }

    process {

        $result = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $body

    }

    end {

        return $result

    }
}
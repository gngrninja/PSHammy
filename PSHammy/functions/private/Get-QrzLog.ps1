function Get-QrzLog {
    [cmdletbinding()]
    param(

    )

    begin {

        [string]$baseUrl = 'https://logbook.qrz.com/api'

    }

    process {
        
        $body = @{

            KEY    = "$($config.QRZLogApiKey)"
            ACTION = 'Fetch'

        }

        $result = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $body

        $convertedResult = $result -replace '&lt','<' -replace '&gt','>' -replace ';','' -replace '&','' -replace 'COUNT=[0-9+]','' -replace 'ADIF=','' -replace 'RESULT=.+',''

        $logList = ConvertFrom-Adif $convertedResult

    }

    end {

        return $logList

    }
}
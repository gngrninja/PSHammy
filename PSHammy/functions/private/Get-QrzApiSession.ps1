function Get-QrzApiSession {
    [cmdletbinding()]
    param(
        [Parameter(

        )]
        [string]
        $Url = 'https://xmldata.qrz.com/xml/current',

        [Parameter(

        )]
        $Credential 
    )

    begin {

        if ($config.QRZApiKey) {

            $sessionCheckUrl = "https://xmldata.qrz.com/xml/current/?s=$($config.QRZApiKey);callsign=kf7ign"
            $sessionCheck    = Invoke-RestMethod -Uri $sessionCheckUrl

        }
        
        $fullUrl = "$($Url)/?username=$($Credential.UserName);password=$($Credential.GetNetworkCredential().Password);agent=q5.0"
        
    }

    process {

        if ($sessionCheck.QRZDatabase.Session.Error -or !$config.QRZApiKey) {

            Write-Verbose "Error in QRZ session check (or no API key yet)... attempting to get a fresh key"

            $result = Invoke-RestMethod -Uri $fullUrl -Method Get

        } else {

            Write-Verbose "Key works fine!"

            return "keep"

        }
    }

    end {

        if ($result.QRZDatabase.Session.Key) {

            $getConfig = Get-Content -Path $hammyConfigPath | ConvertFrom-Json

            $getConfig.QRZApiKey = $result.QRZDatabase.Session.Key

            $getConfig | ConvertTo-Json | Out-File -FilePath $hammyConfigPath

            Write-Verbose "New QRZ API key exported in config [$($hammyConfig)]!"

            $script:config = Get-Content -Path $hammyConfigPath | ConvertFrom-Json

            return "change"

        }         
    }
}
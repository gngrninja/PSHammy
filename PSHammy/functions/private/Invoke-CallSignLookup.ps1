function Invoke-CallSignLookup {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $CallSign,
        [Parameter(

        )]
        [ValidateSet('HamDb','callook','Qrz')]
        $Api = 'Qrz'
    )

    begin {

        switch ($Api) {

            'HamDb' {

                $url = "http://api.hamdb.org/v1/$($CallSign)/json/hambot"

            }

            'calllook' {

                $url = "https://callook.info/$($CallSign)/json"

            }

            'Qrz' {

                $url = "https://xmldata.qrz.com/xml/current/?s=$($config.QRZApiKey);callsign=$($CallSign)"
                
            }

        }
        
        $callSignData = [PSCustomObject]@{

            CallSign     = ''
            Class        = ''
            Expires      = ''
            Status       = ''
            FirstName    = ''
            Grid         = ''
            Lat          = ''
            Long         = ''
            Country      = '' 
            Addy         = ''
            AddyTwo      = '' 
            State        = ''
            Zip          = ''
            Views        = ''
            ProfileImage = ''

        }

    }
    process {

        try {

            $result = Invoke-RestMethod -Uri $Url  
            
            switch ($Api) {

                'HamDb' {

                    #Get the data we need in a shorter variable path
                    $resultData = $result.hamdb.callsign

                    Write-Verbose ($resultData | Out-String)

                    #Assign data to object we return
                    $callSignData.CallSign  = $resultData.call
                    $callSignData.Class     = $resultData.class
                    $callSignData.Expires   = $resultData.expires
                    $callSignData.Status    = $resultData.status
                    $callSignData.Grid      = $resultData.grid
                    $callSignData.Lat       = $resultData.lat
                    $callSignData.Long      = $resultData.lon
                    $callSignData.State     = $resultData.state
                    $callSignData.Country   = $resultData.country
                    $callSignData.FirstName = $resultData.fname 
                    $callSignData.Addy      = $resultData.addr1
                    $callSignData.AddyTwo   = $resultData.addr2
                    $callSignData.Zip       = $resultData.zip
                }

                'calllook' {

                }

                'Qrz' {

                    $resultData = $result.QRZDatabase.Callsign

                    Write-Verbose ($resultData | Out-String)

                    $callSignData.CallSign     = $resultData.call
                    $callSignData.Class        = $resultData.class
                    $callSignData.Expires      = $resultData.expdate
                    $callSignData.Status       = $resultData.status
                    $callSignData.Grid         = $resultData.grid
                    $callSignData.Lat          = [Math]::Round($resultData.lat, 2)
                    $callSignData.Long         = [Math]::Round($resultData.lon, 2)
                    $callSignData.State        = $resultData.state
                    $callSignData.Country      = $resultData.country
                    $callSignData.FirstName    = $resultData.fname 
                    $callSignData.Addy         = $resultData.addr1
                    $callSignData.AddyTwo      = $resultData.addr2
                    $callSignData.Zip          = $resultData.zip
                    $callSignData.Views        = $resultData.'u_views'
                    $callSignData.ProfileImage = $resultData.image

                }
            }

        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error $errorMessage

        }

    }
    end {

        return $callSignData

    }
}
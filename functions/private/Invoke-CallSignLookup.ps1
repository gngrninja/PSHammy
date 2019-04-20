function Invoke-CallSignLookup {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $CallSign,
        [Parameter(

        )]
        [ValidateSet('HamDb','callook')]
        $Api = 'HamDb'
    )

    begin {

        switch ($Api) {

            'HamDb' {

                $url = "http://api.hamdb.org/v1/$($CallSign)/json/hambot"

            }

            'calllook' {

                $url = "https://callook.info/$($CallSign)/json"

            }

        }
        
        $callSignData = [PSCustomObject]@{

            CallSign  = ''
            Class     = ''
            Expires   = ''
            Status    = ''
            FirstName = ''
            Grid      = ''
            Lat       = ''
            Long      = ''
            Country   = ''   
            State     = ''

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
                    
                }

                'calllook' {

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
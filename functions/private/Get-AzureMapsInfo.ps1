function Get-AzureMapsInfo {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateSet('Search','MapPin','SearchAndPin')]
        $RequestType,
        
        [Parameter(

        )]
        $RequestData,

        [Parameter(

        )]
        $DefaultZoom = '5'
    )

    begin {

        $Prefix = 'https://atlas.microsoft.com'

        $headers = @{
            'x-ms-client-id' = $config.AzureMapsApiKey
        }
         
        switch ($RequestType) {
            'Search' {
                
            }
            'MapPin' {
                
            }
        }
    }

    process {

        switch ($RequestType){
            'MapPin' {

                $baseUrl = "$($Prefix)/map/static/png?api-version=1.0&center=$($RequestData)&pins=default%7C%7C-122%2045&zoom=$($DefaultZoom)"
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile ".\image.png"

            }

            'Search' {

                $baseUrl = "$($Prefix)/search/fuzzy/json?api-version=1.0&query=$($RequestData)"  
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers
                
            }

            'SearchAndPin' {

                $baseUrl = "$($Prefix)/search/fuzzy/json?api-version=1.0&query=$($RequestData)" 
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers

                $firstResult = $response.results[0].position

                $lat = $firstResult.lat
                $lon = $firstResult.lon

                $response = $null
                $baseUrl  = $null

                $baseUrl  = "$($Prefix)/map/static/png?api-version=1.0&center=$($lon),$($lat)&pins=default%7C%7C$($lon) $($lat)&zoom=$($DefaultZoom)"
                Write-Verbose "$baseUrl"
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile ".\image.png"

            }
        }
    }

    end {

        return $response

    }
}
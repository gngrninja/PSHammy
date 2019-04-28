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
        $DefaultZoom = '5',

        [Parameter(

        )]
        [switch]
        $DefaultCenter,

        [Parameter(

        )]
        $PinData
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

        switch ($RequestType) {

            'MapPin' {

                if ($DefaultCenter) {
                    $center = "-98.57,39.82"
                    $DefaultZoom = "2"
                }
                $baseUrl = "$($Prefix)/map/static/png?api-version=1.0&center=$($center)&pins=default%7CcoFF1493%7C%7C'$($PinData.MyCall)'$($PinData.MyLong)%20$($PinData.MyLat)%7C'$($PinData.TheirCall)'$($PinData.TheirLong)%20$($PinData.TheirLat)&zoom=$($DefaultZoom)&layer=basic"
                Write-Verbose $baseUrl
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile ".\output\$($PinData.TheirCall).png"

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
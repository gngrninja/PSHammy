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

        $prefix = 'https://atlas.microsoft.com'

        $headers = @{

            'x-ms-client-id' = $config.AzureMapsApiKey

        }         
    }

    process {

        switch ($RequestType) {

            'MapPin' {

                if ($DefaultCenter) {
                    
                    $center = "-98.57,39.82"
                    $DefaultZoom = '2'

                    if ($PinData) {

                        $getCenter = Get-CenterCoord $PinData
                        $center    = "$($getCenter.CentralLong),$($getCenter.CentralLat)"  

                        $centerDif = $getCenter.CentralLong - $PinData.MyLong

                        Write-Verbose "Center Difference -> [$centerDif]"

                        switch ($centerDif) {

                            {$centerDif -lt 1} {

                                $DefaultZoom = '9'

                            }

                            {($centerDif) -gt 1 -and ($centerDif -lt 2)} {

                                $DefaultZoom = '5'

                            }

                            {($centerDif) -gt 2 -and ($centerDif -lt 10)} {

                                $DefaultZoom = '4'

                            }

                            {($centerDif -gt 10) -and ($centerDif -lt 20)} {

                                $DefaultZoom = '3'  
                            }

                            {$centerDif -gt 20} {

                                $DefaultZoom = '2'
                            }

                            default {
                                
                                $DefaultZoom = '3'                                    

                            }
                        }                                                                                                
                    }
                }
                                
                $baseUrl = "$($prefix)/map/static/png?api-version=1.0&center=$($center)&pins=default%7CcoFF1493%7C%7C'$($PinData.MyCall)'$($PinData.MyLong)%20$($PinData.MyLat)%7C'$($PinData.TheirCall)'$($PinData.TheirLong)%20$($PinData.TheirLat)&zoom=$($DefaultZoom)&layer=basic"
                
                Write-Verbose "Request URL -> [$baseUrl]"
                
                Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile ".\output\$($PinData.TheirCall)$($PinData.DateTimeWorked).png"

                $response = (Get-ChildItem -Path ".\output\$($PinData.TheirCall)$($PinData.DateTimeWorked).png" | Select-Object -ExpandProperty FullName)                

            }

            'Search' {

                $baseUrl = "$($prefix)/search/fuzzy/json?api-version=1.0&query=$($RequestData)"  
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers
                
            }

            'SearchAndPin' {

                $baseUrl = "$($prefix)/search/fuzzy/json?api-version=1.0&query=$($RequestData)"
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers

                $firstResult = $response.results[0].position

                $lat = $firstResult.lat
                $lon = $firstResult.lon

                $response = $null
                $baseUrl  = $null

                $baseUrl  = "$($prefix)/map/static/png?api-version=1.0&center=$($lon),$($lat)&pins=default%7C%7C$($lon)%20$($lat)&zoom=$($DefaultZoom)"

                Write-Verbose "Request URL -> [$baseUrl]"
                $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile ".\image.png"                

            }
        }
    }

    end {

        return $response

    }
}
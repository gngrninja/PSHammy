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
        [switch]
        $FindCenter,

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

                if ($FindCenter) {
                    
                    if ($PinData) {

                        $centerDir = $null
                        
                        $getCenter = Get-CenterCoord -Coords $PinData
                        $center    = "$($getCenter.CentralLong),$($getCenter.CentralLat)"  

                        $centerLongDif = $getCenter.CentralLong - $PinData.MyLong
                        $centerLatDif  = $PinData.MyLat - $getCenter.CentralLat

                        if ($centerLongDif -gt $centerLatDif) {

                            $centerDif = $centerLongDif

                        } else {

                            $centerDif = $centerLatDif

                        }
                        
                        Write-Verbose "Center Difference -> [$centerDif]"

                        switch ($centerDif) {

                            {$_ -lt 1 -and $_ -gt 0} {

                                $DefaultZoom = '9'

                            }

                            {($_) -gt 1 -and ($_ -lt 2)} {

                                $DefaultZoom = '5'

                            }

                            {($_) -gt 2 -and ($_ -lt 10)} {

                                $DefaultZoom = '4'

                            }

                            {($_ -gt 10) -and ($_ -lt 20)} {

                                $DefaultZoom = '3' 

                            }

                            {$_ -gt 20 -and $_ -lt 30} {

                                $DefaultZoom = '2'

                            }

                            {$_ -gt 30} {

                                $DefaultZoom = '0'  
                                $center      = '0,0'     

                            }

                            default {
                                
                                $DefaultZoom = '0'  
                                $center      = '0,0'                                  

                            }
                        }                                                                                                
                    }
                }
                                
                $baseUrl = "$($prefix)/map/static/png?api-version=1.0&center=$($center)&pins=default%7CcoFF1493%7C%7C'$($PinData.MyCall)'$($PinData.MyLong)%20$($PinData.MyLat)%7C'$($PinData.TheirCall)'$($PinData.TheirLong)%20$($PinData.TheirLat)&zoom=$($DefaultZoom)&layer=basic"
                
                Write-Verbose "Request URL -> [$baseUrl]"
                
                Invoke-RestMethod -Uri $baseUrl -Headers $headers -OutFile "$($outputPath)$($separator)$($PinData.TheirCall)$($PinData.DateTimeWorked).png"

                $response = (Get-ChildItem -Path "$($outputPath)$($separator)$($PinData.TheirCall)$($PinData.DateTimeWorked).png" | Select-Object -ExpandProperty FullName)                

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
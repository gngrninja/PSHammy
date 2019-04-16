function Get-AzureMapsInfo {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateSet('Search')]
        $RequestType,
        
        [Parameter(

        )]
        $RequestData
    )

    begin {

        $headers = @{
            'x-ms-client-id' = $config.AzureMapsApiKey
        }
        $baseUrl = "https://atlas.microsoft.com/search/fuzzy/json?api-version=1.0&query=$RequestData"
         
        switch ($RequestType) {
            '' {
                
            }
            'MapPin' {
                $baseUrl = "https://atlas.microsoft.com/map/static/png?api-version=1.0&center=-122%2C45&pins=default%7C%7C-122%2045&zoom=6"
            }
        }
    }

    process {

        $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers
        
    }

    end {
        return $response
    }
}
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

        $baseUrl = "https://atlas.microsoft.com/search/fuzzy/json?subscription-key=$($config.AzureMapsKey)?api-version=1.0&query=$RequestData"
        write-host $baseurl
        switch ($RequestType) {
            '' {
                
            }
        }
    }

    process {
        $response = invoke-restmethod $baseUrl
        return $response
    }

    end {

    }
}
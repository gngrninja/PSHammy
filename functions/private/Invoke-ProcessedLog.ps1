function Invoke-ProcessedLog {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateSet(
            'Add',
            'Check',
            'Get'
        )]
        $Action,

        [Parameter(
            Mandatory
        )]
        [string]
        $FilePath
    )

    begin {
        
        

    }

    process {

        $processedLog = Get-Content -Path $FilePath | ConvertFrom-Json
        
    }

    end {

        return $processedLog
        
    }
}
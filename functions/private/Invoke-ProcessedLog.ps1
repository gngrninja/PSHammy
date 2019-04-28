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
        $Action
    )

    begin {

        $processedLog = Get-Content -Path ".\processed.json" | ConvertFrom-Json

    }

    process {
        
    }

    end {

        return $processedLog
        
    }
}
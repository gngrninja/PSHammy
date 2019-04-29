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
        $FilePath,

        [Parameter(

        )]
        [string]
        $Guid
    )

    begin {
        
        

    }

    process {

        switch ($Action) {

            'Get' {

                $processedLog = Get-Content -Path $FilePath | ConvertFrom-Json

            }
            'Add' {
                
                $processedLog = Get-Content -Path $FilePath | ConvertFrom-Json

                $processedLog += $Guid

                $processedLog | ConvertTo-Json | Out-File -Path $FilePath

                $processedLog = Get-Content -Path $FilePath | ConvertFrom-Json

            }
        }
        
    }

    end {

        return $processedLog
        
    }
}
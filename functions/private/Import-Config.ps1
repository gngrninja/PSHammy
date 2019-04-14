function Import-Config {
    [cmdletbinding()]
    param(
        $Path = "$PSScriptRoot\config.json"
    )

    process {

        try {

            Write-Verbose "Attempting to import config from -> [$($Path)]"
            $importedConfig = Get-Content -Path $Path | ConvertFrom-Json 


        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error "Error importing config -> [$errorMessage]!"

        }
        
    }

    end {

        if ($importedConfig) {

            return $importedConfig

        }

    }
}
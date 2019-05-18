function Write-HostForScript {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $Message
    )

    begin {

        $defaultForeground = $config.DefaultForeground
        $defaultBackground = $config.DefaultBackground

        if (!$defaultForeground) {

            $defaultForeground = 'Green'

        }

        if (!$defaultBackground) {

            $defaultBackground = 'Black'

        }
        
    }
    
    process {

        Write-Host `n$Message`n -BackgroundColor $defaultBackground -ForegroundColor $defaultForeground

    }    
}
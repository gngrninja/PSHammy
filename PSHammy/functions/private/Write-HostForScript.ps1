function Write-HostForScript {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $Message
    )

    begin {

        $defaultForeground = 'Green'
        $defaultBackground = 'Black'
        
    }
    
    process {

        Write-Host `n$Message`n -BackgroundColor $defaultBackground -ForegroundColor $defaultForeground

    }    
}
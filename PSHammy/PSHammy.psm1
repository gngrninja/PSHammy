#get OS specific information
$script:separator        = [IO.Path]::DirectorySeparatorChar

#null out vars used later
[string]$script:userDir           = $null
[string]$script:wsjtxLogPath      = $null
[string]$script:wsjtxConfigPath   = $null
[string]$script:wsjtxAdifLogPath  = $null
[string]$script:defaultPSHammyDir = $null

#import functions
$Public  = @( Get-ChildItem -Path "$PSScriptRoot$($separator)functions$($separator)public$($separator)*.ps1" )
$Private = @( Get-ChildItem -Path "$PSScriptRoot$($separator)functions$($separator)private$($separator)*.ps1" )

@($Public + $Private) | ForEach-Object {

    Try {

        Write-Verbose "Importing -> [$($_.FullName)]!"
        . $_.FullName

    } Catch {

        Write-Error -Message "Failed to import function $($_.FullName): $_"
        
    }

}

#set base user directory
switch ($PSVersionTable.PSEdition) {
    
    'Desktop' {

        $userDir = $env:USERPROFILE

        $wsjtxLogPath     = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx.log"
        $wsjtxAdifLogPath = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx_log.adi"
        $wsjtxConfigPath  = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)WSJT-X.ini"

    }

    'Core' {

        switch ($PSVersionTable.Platform) {

            'Win32NT' {
        
                $userDir = $env:USERPROFILE

                $wsjtxLogPath     = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx.log"
                $wsjtxAdifLogPath = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx_log.adi"
                $wsjtxConfigPath  = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)WSJT-X.ini"
        
            }
        
            'Unix' {
        
                $userDir = $env:HOME

                if ($PSVersionTable.OS -match 'Darwin.+') {

                    $wsjtxLogPath     = "$($userDir)$($separator)Library$($separator)Application Support$($separator)WSJT-X$($separator)wsjtx.log"
                    $wsjtxAdifLogPath = "$($userDir)$($separator)Library$($separator)Application Support$($separator)WSJT-X$($separator)wsjtx_log.adi"
                    $wsjtxConfigPath  = "$($userDir)$($separator)Library$($separator)Preferences$($separator)WSJT-X.ini"
                    
                } else {

                    $wsjtxLogPath     = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)wsjtx.log"
                    $wsjtxAdifLogPath = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)wsjtx_log.adi"
                    $wsjtxConfigPath  = "$($userDir)$($separator).config$($separator)WSJT-X.ini"

                }
            }
        }
    }
}

#setup folders/paths
$script:defaultPSHammyDir = (Join-Path -Path $userDir -ChildPath '.psHammy')

$script:inputPath         = "$defaultPSHammyDir$($separator)input"
$script:outputPath        = "$defaultPSHammyDir$($separator)output"

$script:processedPath     = "$inputPath$($separator)processed.json" 
$script:hammyConfigPath   = "$inputPath$($separator)config.json"
$script:qrzCredPath       = "$inputPath$($separator)qrzCred.xml"
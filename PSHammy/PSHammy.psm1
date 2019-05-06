#get OS specific information
$script:separator        = [IO.Path]::DirectorySeparatorChar
$script:inputPath        = "$PSScriptRoot$($separator)input"
$script:outputPath       = "$PSScriptRoot$($separator)output"
$script:processedPath    = "$inputPath$($separator)processed.json" 
$script:hammyConfigPath  = "$inputPath$($separator)config.json"
$script:qrzCredPath      = "$inputPath$($separator)qrzCred.xml"
[string]$script:userDir  = $null
[string]$wsjtxLogPath    = $null
[string]$wsjtxConfigPath = $null

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

        $wsjtxLogPath    = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx.log"
        $wsjtxConfigPath = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)WSJT-X.ini"

    }

    'Core' {

        switch ($PSVersionTable.Platform) {

            'Win32NT' {
        
                $userDir = $env:USERPROFILE

                $wsjtxLogPath    = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx.log"
                $wsjtxConfigPath = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)WSJT-X.ini"
        
            }
        
            'Unix' {
        
                $userDir = $env:HOME

                if ($PSVersionTable.OS -match 'Darwin.+') {

                    $wsjtxLogPath    = "$($userDir)$($separator)Library$($separator)Application Support$($separator)WSJT-X$($separator)wsjtx.log"
                    $wsjtxConfigPath = "$($userDir)$($separator)Library$($separator)Preferences$($separator)WSJT-X.ini"
                    
                } else {

                    $wsjtxLogPath    = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)wsjtx.log"
                    $wsjtxConfigPath = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)WSJT-X.ini"

                }
            }
        }
    }
}
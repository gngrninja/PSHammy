[cmdletbinding()]
param(
    [Parameter(

    )]
    [switch]
    $DoNotAutoDeleteImages
)

[char]$script:seperator  = $null
[string]$userDir         = $null
[string]$wsjtxLogPath    = $null
[string]$inputPath       = $null
[string]$hammyConfigPath = $null
[string]$processedPath   = $null
[array]$processed        = $null
[string]$wsjtxConfigPath = $null
[string]$outputPath      = $null

#Get OS specific information
$script:separator = [IO.Path]::DirectorySeparatorChar
$inputPath        = "$PSScriptRoot$($separator)input"
$outputPath       = "$PSScriptRoot$($separator)output"
$processedPath    = "$inputPath$($separator)processed.json" 
$hammyConfigPath  = "$inputPath$($separator)config.json"

#Set base user directory
switch ($PSVersionTable.PSEdition) {

    'Desktop' {

        $userDir = $env:USERPROFILE

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

                $wsjtxLogPath    = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)wsjtx.log"
                $wsjtxConfigPath = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)WSJT-X.ini"
        
            }
        }
    }
}

if (!(Test-Path -Path $wsjtxLogPath -ErrorAction SilentlyContinue)) {

    throw "Unable to access -> [$wsjtxLogPath], cannot continue!"

}

if (!(Test-Path -Path "$PSScriptRoot\functions\public" -ErrorAction SilentlyContinue)) {

    New-Item -Path "$PSScriptRoot\functions\public\" -ItemType Directory | Out-Null

}

#import functions
$Public  = @( Get-ChildItem -Path "$PSScriptRoot\functions\public\*.ps1" )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\functions\private\*.ps1" )

@($Public + $Private) | ForEach-Object {

    Try {

        Write-Verbose "Importing -> [$($_.FullName)]!"
        . $_.FullName

    } Catch {

        Write-Error -Message "Failed to import function $($_.FullName): $_"
        
    }

}

#Folder/file creation for input (config and processed list)
if (!(Test-Path -Path $inputPath -ErrorAction SilentlyContinue)) {

    Write-HostForScript -Message "Path [$inputPath] does not exist... creating!"

    New-Item -Path $inputPath -ItemType Directory | Out-Null

}

if (!(Test-Path -Path $outputPath -ErrorAction SilentlyContinue)) {

    Write-HostForScript -Message "Path [$outputPath] does not exist... creating!"

    New-Item -Path $outputPath -ItemType Directory | Out-Null

}

if (!(Test-Path -Path $processedPath -ErrorAction SilentlyContinue)) {

    Write-HostForScript -Message "Path [$processedPath] does not exist... creating!"
    New-Item -Path $processedPath -ItemType File | Out-Null

    @('ZZ0ZZ-01-01-01-01-01-01','ZZ0ZZ-01-01-01-01-01-01') | ConvertTo-Json | Out-File -FilePath $processedPath

}

if (!(Test-Path -Path $hammyConfigPath -ErrorAction SilentlyContinue)) {

    Write-HostForScript -Message "Creating [$hammyConfigPath]"
    New-Item -Path $hammyConfigPath -ItemType File | Out-Null

    @{'AzureMapsApiKey'=''} | ConvertTo-Json | Out-File -FilePath $hammyConfigPath

    Write-HostForScript "Configuration file created at -> [$hammyConfigPath]... please input your Azure Maps API key..."

    break

}

$config      = Import-Config -Path $hammyConfigPath
$wsjtxConfig = Get-IniContent -FilePath $wsjtxConfigPath

#Get call sign from wsjtx config
if ($wsjtxConfig) {

    $DefaultCall = $wsjtxConfig.Configuration.MyCall

}

Write-HostForScript -Message "Imported call sign [$DefaultCall] from WSJT-X.ini..."

Write-HostForScript -Message "Attempting to import log data from [$wsjtxLogPath]..."

$logData = Import-WsjtxLog -LogPath $wsjtxLogPath

if ($logData) {
    
    $lookupAddy = $null

    Write-HostForScript -Message "Attempting to import processed data from [$processedPath]..."
    Write-HostForScript -Message "Looking up call sign information for [$($DefaultCall)]..."

    $processed  = Invoke-ProcessedLog -Action Get -FilePath $processedPath     
    $myCallData = Invoke-CallSignLookup -CallSign $DefaultCall    

    $lookupAddy = "$($myCallData.Addy) $($myCallData.AddyTwo) $($myCallData.State) $($myCallData.Zip)"
    
    $myLocation = Get-AzureMapsInfo -RequestType 'Search' -RequestData $lookupAddy

    #As job
    while ($true) {

        $fromToday = $logData | Where-Object {

            [DateTime]$_.WorkedDate -ge [DateTime]::Now.ToString("yyyy-MM-dd")
    
        }
        
        Write-HostForScript -Message "Found [$($fromToday.Count)] log entries..."

        foreach ($contact in $fromToday) {
    
            $theirCallInfo  = $null
            $pinData        = $null
            $theirLocation  = $null
            $guid           = $null
            $dateTimeWorked = $null
            $lookupAddy     = $null

            $dateTimeWorked = "$($contact.WorkedDate)$($contact.WorkedTime.Replace(':','-'))"
            $guid           = "$($contact.WorkedCallSign)-$($dateTimeWorked)"
            
            Write-Verbose "Working with GUID -> [$($guid)]..."
            Write-Verbose "Processed:"
            Write-Verbose  ($processed| out-string)

            if ($guid -notin $processed) {
                
                Write-HostForScript -Message "Looking up call sign information for [$($contact.WorkedCallSign)]..."
    
                $theirCallInfo = Invoke-CallSignLookup -CallSign $contact.WorkedCallSign

                $lookupAddy = "$($theirCallInfo.Addy) $($theirCallInfo.AddyTwo) $($theirCallInfo.State) $($theirCallInfo.Zip)"

                $theirLocation = Get-AzureMapsInfo -RequestData $lookupAddy -RequestType 'Search'
                
                $pinData = [PSCustomObject]@{
        
                    MyCall         = $myCallData.CallSign
                    MyLat          = $myLocation.results[0].position.lat
                    MyLong         = $myLocation.results[0].position.lon
                    TheirCall      = $theirCallInfo.CallSign 
                    TheirLat       = $theirLocation.results[0].position.lat
                    TheirLong      = $theirLocation.results[0].position.lon
                    Frequency      = $contact.Frequency
                    DateTimeWorked = $dateTimeWorked
                    TheirState     = $theirCallInfo.State
                    MyState        = $myCallData.State
                    MyRig          = $wsjtxConfig.Configuration.Rig
                    MyGrid         = $wsjtxConfig.Configuration.MyGrid
                    TheirGrid      = $contact.GridSquare
                    
                }
        
                Write-Verbose "Pin data:"
                Write-Verbose ($PinData | Out-String)
        
                try {                            
                    
                    Write-HostForScript -Message "Getting map image for contact..."
    
                    $result = Get-AzureMapsInfo -RequestType MapPin -PinData $pinData -FindCenter  
        
                    Write-HostForScript -Message "Attempting to send data to Discord..."
        
                    Invoke-WebHookSend -PinData $pinData -ContactData $contact -ImagePath $result
                        
                }
                catch {
        
                    $errorMessage = $_.Exception.Message
                    Write-Error "Error -> [$errorMessage]!"
        
                }
                finally {
        
                    $processed = Invoke-ProcessedLog -Action Add -FilePath $processedPath -Guid $guid                    
                    $logData   = Import-WsjtxLog -LogPath $wsjtxLogPath

                    Start-Sleep -Second 7
        
                }                                        
            } else {

                $processed  = Invoke-ProcessedLog -Action Get -FilePath $processedPath                  
                $logData    = Import-WsjtxLog -LogPath $wsjtxLogPath

                Start-Sleep -Second 2

            }
        }
    }    
 }

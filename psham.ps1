[cmdletbinding()]
param(
    [Parameter(
        
    )]
    $DefaultCall 
)

[char]$script:seperator  = $null
[string]$userDir         = $null
[string]$wsjtxLogPath    = $null
[string]$inputPath       = $null
[string]$hammyConfigPath = $null
[string]$processedPath   = $null

#Get OS specific information
$script:separator = [IO.Path]::DirectorySeparatorChar

$inputPath       = "$PSScriptRoot$($separator)input"
$processedPath   = "$inputPath$($separator)processed.json" 
$hammyConfigPath = "$inputPath$($separator)config.json"

#Set base user directory
switch ($PSVersionTable.PSEdition) {

    'Desktop' {

        $userDir = $env:USERPROFILE

    }

    'Core' {

        switch ($PSVersionTable.Platform) {

            'Win32NT' {
        
                $userDir = $env:USERPROFILE

                $wsjtxLogPath = "$($userDir)$($separator)AppData$($separator)Local$($separator)WSJT-X$($separator)wsjtx.log"
        
            }
        
            'Unix' {
        
                $userDir = $env:HOME

                $wsjtxLogPath = "$($userDir)$($separator).local$($separator)share$($separator)WSJT-X$($separator)wsjtx.log"
        
            }
        }

    }
}

if (!(Test-Path -Path $wsjtxLogPath -ErrorAction SilentlyContinue)) {

    throw "Unable to access -> [$wsjtxLogPath], cannot continue!"

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

$config = Import-Config -Path $hammyConfigPath

if ($config.DefaultCall) {

    $DefaultCall = $config.DefaultCall

}

Write-Host `n"Attempting to import log data from [$wsjtxLogPath]..."`n -ForegroundColor Green -BackgroundColor Black

$logData = Import-WsjtxLog -LogPath $wsjtxLogPath

#We will work with this later if we need to
$processed = Invoke-ProcessedLog -Action Get -FilePath $processedPath 

$processed
break

if ($logData) {

    Write-Host `n"Log information imported!"`n
    
    $myCallData    = Invoke-CallSignLookup -CallSign $DefaultCall
    
    $myLocation    = Get-AzureMapsInfo -RequestData "$($myCallData.Addy) $($myCallData.Zip)" -RequestType 'Search'

    $fromToday = $logData | Where-Object {

        [DateTime]$_.WorkedDate -ge [DateTime]::Now.AddDays(-30).ToString("yyyy-MM-dd")

    }
      
    foreach ($contact in $fromToday) {

        $theirCallInfo = $null
        $pinData       = $null
        $theirLocation = $null

        $theirCallInfo = Invoke-CallSignLookup -CallSign $contact.WorkedCallSign
        $theirLocation = Get-AzureMapsInfo -RequestData "$($theirCallInfo.Addy) $($theirCallInfo.Zip)" -RequestType 'Search'

        $pinData = [PSCustomObject]@{

            MyCall         = $myCallData.CallSign
            MyLat          = $myLocation.results[0].position.lat
            MyLong         = $myLocation.results[0].position.lon
            TheirCall      = $theirCallInfo.CallSign 
            TheirLat       = $theirLocation.results[0].position.lat
            TheirLong      = $theirLocation.results[0].position.lon
            DateTimeWorked = "$($contact.WorkedDate)$($contact.WorkedTime.Replace(':','-'))"
            TheirState     = $theirCallInfo.State
            MyState        = $myCallData.State
            
        }

        Write-Verbose ($PinData | Out-String)

        try {

            $result = Get-AzureMapsInfo -RequestType MapPin -PinData $pinData -DefaultCenter  

            Invoke-WebHookSend -PinData $pinData -ContactData $contact -ImagePath $result
                
        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error "Error -> [$errorMessage]!"

        }        
    }
 }

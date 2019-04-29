[cmdletbinding()]
param(
    [Parameter(
        Mandatory
    )]
    $DefaultCall = 'KF7IGN'
)

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

$config = Import-Config -Path "$PSScriptRoot/config.json"

$logData = Import-WsjtxLog
$processed = Invoke-ProcessedLog -Action Get

$processed
 

if ($logData) {

    $myCallData    = Invoke-CallSignLookup -CallSign $DefaultCall
    

    $myLocation    = Get-AzureMapsInfo -RequestData "$($myCallData.Addy) $($myCallData.Zip)" -RequestType 'Search'

    $fromToday = $logData | Where-Object {

        [DateTime]$_.WorkedDate -ge [DateTime]::Now.AddDays(-30).ToString("yyyy-MM-dd")

    }

    $fromToday    

    foreach ($contact in $fromToday) {

        $theirCallInfo = $null

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

        Get-AzureMapsInfo -RequestType MapPin -PinData $pinData -DefaultCenter
                

    }
 }

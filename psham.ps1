using module PSDsHook
[cmdletbinding()]
param(
    [Parameter(
        
    )]
    $DefaultCall 
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

if ($config.DefaultCall) {

    $DefaultCall = $config.DefaultCall

}

$logData = Import-WsjtxLog
$processed = Invoke-ProcessedLog -Action Get 

if ($logData) {

    $myCallData    = Invoke-CallSignLookup -CallSign $DefaultCall
    

    $myLocation    = Get-AzureMapsInfo -RequestData "$($myCallData.Addy) $($myCallData.Zip)" -RequestType 'Search'

    $fromToday = $logData | Where-Object {

        [DateTime]$_.WorkedDate -ge [DateTime]::Now.AddDays(-30).ToString("yyyy-MM-dd")

    }
      
    foreach ($contact in $fromToday) {

        $embedBuilder  = $null
        $theirCallInfo = $null
        $details       = $null
        $title         = $null

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

            $thumbUrl = 'https://static1.squarespace.com/static/5644323de4b07810c0b6db7b/t/5aa44874e4966bde3633b69c/1520715914043/webhook_resized.png'

            $title   = "New FT8 contact [$($pinData.MyCall)] <-> [$($pinData.TheirCall)]"
            $details = "New contact! Check out the map below!"

            $embedBuilder = [DiscordEmbed]::new(
                $title,
                $details                
            )

            
            $embedBuilder.WithColor(
                [DiscordColor]::New(
                    'purple'
                )
            )

            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Received Signal',
                    "$($contact.ReportedSignalRec)",
                    $true

                )
            )

            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Sent Signal',
                    "$($contact.ReportedSignalSent)",
                    $true
                )
            )  

            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Time Worked',
                    "[$($contact.WorkedDate)] [$($contact.WorkedTime)]"
                )
            )  
            $embedBuilder.AddFooter(
                [DiscordFooter]::New(
                    "Ham radio is fun! This report was brought to you by PSHammy",
                    $thumbUrl

                )
            )

            Invoke-PSDsHook -EmbedObject $embedBuilder

            Invoke-PSDsHook -FilePath $result            
        }
        catch {

            $errorMessage = $_.Exception.Message
            Write-Error "Error -> [$errorMessage]!"

        }        
    }
 }

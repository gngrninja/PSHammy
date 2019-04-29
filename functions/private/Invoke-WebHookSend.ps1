using module PSDsHook
function Invoke-WebHookSend {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory
        )]
        $PinData,

        [Parameter(
            Mandatory
        )]
        $contactData,

        [Parameter(
            Mandatory
        )]
        [string]
        $ImagePath
    )

    begin {

        $thumbUrl = 'https://static1.squarespace.com/static/5644323de4b07810c0b6db7b/t/5aa44874e4966bde3633b69c/1520715914043/webhook_resized.png'

        $title   = "New FT8 contact [$($PinData.MyCall)] <-> [$($PinData.TheirCall)]"
        $details = @"
New contact on frequency -> [**$([math]::Round($PinData.Frequency, 2))**]Mhz
See the map below!
"@  

    }

    process {
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
                "From [**$($PinData.TheirState)**] -> *$($contactData.ReportedSignalRec)*",
                $true
    
            )
        )
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Sent Signal',
                "To [**$($PinData.MyState)**] -> *$($contactData.ReportedSignalSent)*",
                $true
            )
        )  
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Time Worked',
                "[**$($contactData.WorkedDate)**] @ [**$($contactData.WorkedTime)**]"
            )
        )  

        $embedBuilder.AddThumbnail(
            [DiscordThumbnail]::New(                
                "http://clipartmag.com/images/radio-clipart-3.jpg"
            )
        )

        $embedBuilder.AddFooter(
            [DiscordFooter]::New(
                "Ham radio is fun! This report was brought to you by PSHammy",
                $thumbUrl
    
            )
        )
    
        Invoke-PSDsHook -EmbedObject $embedBuilder | Out-Null
        Start-Sleep -Second 1
        Invoke-PSDsHook -FilePath $ImagePath | Out-Null      
    }            
}

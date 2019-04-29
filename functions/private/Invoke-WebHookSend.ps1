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
        $details = "New contact! Check out the map below!"

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
                "$($contactData.ReportedSignalRec)",
                $true
    
            )
        )
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Sent Signal',
                "$($contactData.ReportedSignalSent)",
                $true
            )
        )  
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Time Worked',
                "[$($contactData.WorkedDate)] [$($contactData.WorkedTime)]"
            )
        )  
        $embedBuilder.AddFooter(
            [DiscordFooter]::New(
                "Ham radio is fun! This report was brought to you by PSHammy",
                $thumbUrl
    
            )
        )
    
        Invoke-PSDsHook -EmbedObject $embedBuilder | Out-Null
    
        Invoke-PSDsHook -FilePath $ImagePath | Out-Null      
    }            
}

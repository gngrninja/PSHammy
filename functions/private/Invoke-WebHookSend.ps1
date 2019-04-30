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
        $ContactData,

        [Parameter(
            Mandatory
        )]
        [string]
        $ImagePath
    )

    begin {

        $thumbUrl = 'https://static1.squarespace.com/static/5644323de4b07810c0b6db7b/t/5aa44874e4966bde3633b69c/1520715914043/webhook_resized.png'

        $title   = "New [$($ContactData.Mode)] contact [$($PinData.MyCall)] <-> [$($PinData.TheirCall)]"
        $details = @"
New contact.

See the map below!
"@  

    }

    process {

        $embedBuilder = [DiscordEmbed]::New(
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
                'Frequency',
                $([math]::Round($PinData.Frequency, 2))
            )
        )

        $embedBuilder.AddField(
            [DiscordField]::New(
                'Received Signal',
                "From [**$($PinData.TheirState)**] -> *$($ContactData.ReportedSignalRec)*",
                $true
    
            )
        )
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Sent Signal',
                "To [**$($PinData.MyState)**] -> *$($ContactData.ReportedSignalSent)*",
                $true
            )
        )  
    
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Time Worked',
                "[**$($ContactData.WorkedDate)**] @ [**$($ContactData.WorkedTime)**]",
                $true
            )
        )  

        $embedBuilder.AddField(
            [DiscordField]::New(
                'My Radio',
                $PinData.MyRig,
                $true
            )
        )  

        $embedBuilder.AddField(
                [DiscordField]::New(
                    'My Grid',
                    $PinData.MyGrid,
                    $true
                )
            )  
        if ($PinData.TheirGrid) {

            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Their Grid',
                    $PinData.TheirGrid,
                    $true
                )
            )  
        }

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

        if (!$DoNotAutoDeleteImages) {

            Write-HostForScript -Message "Removing [$($ImagePath)]..."
            Remove-Item -Path $ImagePath -Force   

        } else {

            Write-HostForScript -Message "Keeping [$($ImagePath)]..."

        }
    }            
}

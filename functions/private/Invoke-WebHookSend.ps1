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

        if ($PinData.TheirImage) {

            $thumbUrl = $PinData.TheirImage

        } else {

            $thumbUrl = "http://clipartmag.com/images/radio-clipart-3.jpg"

        }
        
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
    
        if ($PinData.MyImage) {
            $embedBuilder.AddAuthor(
                [DiscordAuthor]::New(
                    $PinData.MyCall,
                    $PinData.MyImage
                )
            )
        }

        if ($PinData.TheirImage) {

            $embedBuilder.AddImage(
                [DiscordImage]::New(
                    $PinData.TheirImage
                )
            )

        }
        $embedBuilder.AddField(
            [DiscordField]::New(
                'Frequency',
                "[$([math]::Round($PinData.Frequency, 2))]Mhz"
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
                $thumbUrl
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

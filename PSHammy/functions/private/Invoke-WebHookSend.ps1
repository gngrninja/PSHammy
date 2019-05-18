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

            $thumbUrl = $config.DefaultThumbUrl

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

        if ($PinData.Frequency) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Frequency',
                    "[$([math]::Round($PinData.Frequency, 2))]Mhz"
                )
            )    
        }

        $receivedFrom = $null            
        if ($PinData.TheirState) {

            $receivedFrom = $PinData.TheirState

        } else {

            $receivedFrom = $PinData.TheirCountry

        }
        if ($receivedFrom) {
            $embedBuilder.AddField(
           
                [DiscordField]::New(
                    'Received Signal',
                    "From [**$($receivedFrom)**] -> *$($ContactData.ReportedSignalRec)*",
                    $true
        
                )
            )
        }

    
        $sentTo = $null            
        if ($PinData.MyState) {

            $sentTo = $PinData.MyState

        } else {

            $sentTo = $PinData.MyCountry

        }
        
        if ($sentTo) {
            $embedBuilder.AddField(            
                [DiscordField]::New(
                    'Sent Signal',
                    "To [**$($sentTo)**] -> *$($ContactData.ReportedSignalSent)*",
                    $true
                )
            )  
        }
    
        if ($ContactData.WorkedDate -and $ContactData.WorkedTime) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Time Worked',
                    "[**$($ContactData.WorkedDate)**] @ [**$($ContactData.WorkedTime)**]",
                    $true
                )
            )  
        }

        if ($PinData.MyRig) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'My Radio',
                    $PinData.MyRig,
                    $true
                )
            ) 
        }
 
        if ($PinData.MyGrid) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'My Grid',
                    $PinData.MyGrid,
                    $true
                )
            )  
        }

        
        if ($PinData.TheirGrid) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Their Grid',
                    $PinData.TheirGrid,
                    $true
                )
            )  
        }
        
                
        if ($PinData.MyViews) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'My Profile Views',
                    $PinData.MyViews,
                    $true
                )
            )  
        }

        if ($PinData.TheirViews) {
            $embedBuilder.AddField(
                [DiscordField]::New(
                    'Their Profile Views',
                    $PinData.TheirViews,
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
                $config.FooterTxt,
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

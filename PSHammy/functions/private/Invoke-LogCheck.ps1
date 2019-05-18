function Invoke-LogCheck {
    [cmdletbinding()]
    param(

    )
    while ($true) {
    
        $fromToday = $logData | Where-Object {

            [DateTime]$_.WorkedDate -ge [DateTime]::Now.ToString("yyyy-MM-dd")
    
        }
        
        if ($fromToday.Count -le 0) {

            Write-HostForScript -Message "No log entries found -> [$($wsjtxLogPath)] <- aborting!"
            
            break

        }

        Write-HostForScript -Message "Found [$($fromToday.Count)] log entries..."

        [string]$myGrid = [string]::Empty        
        if ((!$myCallData.Grid) -or ($myCallData.Grid -eq 'Unknown')) {

            $myGrid = $wsjtxConfig.Configuration.MyGrid

        } else {

            $myGrid = $myCallData.Grid

        }

        foreach ($contact in $fromToday) {
    
            $theirCallInfo  = $null
            $pinData        = $null
            $theirLocation  = $null
            $guid           = $null
            $dateTimeWorked = $null
            $lookupAddy     = $null
            $theirLat       = $null
            $theirLong      = $null

            $dateTimeWorked = "$($contact.WorkedDate)$($contact.WorkedTime.Replace(':','-'))"
            $guid           = "$($contact.WorkedCallSign)-$($dateTimeWorked)"
            
            Write-Verbose "Working with GUID -> [$($guid)]..."
            Write-Verbose "Processed:"
            Write-Verbose  ($processed| out-string)

            if ($guid -notin $processed) {
                
                Write-HostForScript -Message "Looking up call sign information for [$($contact.WorkedCallSign)]..."
    
                $theirCallInfo = Invoke-CallSignLookup -CallSign $contact.WorkedCallSign

                if ($theirCallInfo.lat -and $theirCallInfo.long) {

                    $theirLat  = $theirCallInfo.lat
                    $theirLong = $theirCallInfo.long

                } else {

                    $lookupAddy = "$($theirCallInfo.Addy) $($theirCallInfo.AddyTwo) $($theirCallInfo.State) $($theirCallInfo.Zip)"
                    $theirLocation = Get-AzureMapsInfo -RequestData $lookupAddy -RequestType 'Search'

                    $theirLat  = $theirLocation.results[0].position.lat
                    $theirLong = $theirLocation.results[0].position.lon

                }
               
                $pinData = [PSCustomObject]@{
        
                    MyCall         = $myCallData.CallSign
                    MyLat          = $myLat
                    MyLong         = $myLong
                    TheirCall      = $theirCallInfo.CallSign 
                    TheirLat       = $theirLat
                    TheirLong      = $theirLong
                    Frequency      = $contact.Frequency
                    DateTimeWorked = $dateTimeWorked
                    TheirState     = $theirCallInfo.State
                    TheirCountry   = $theirCallInfo.Country
                    MyState        = $myCallData.State
                    MyCountry      = $myCallData.Country
                    MyRig          = $wsjtxConfig.Configuration.Rig
                    MyGrid         = $myGrid
                    TheirGrid      = $theirCallInfo.Grid
                    MyImage        = $myCallData.ProfileImage
                    TheirImage     = $theirCallInfo.ProfileImage
                    TheirViews     = $theircallInfo.'u_views'
                    MyViews        = $myCallData.'u_views'
                    
                }
        
                Write-Verbose "Pin data:"
                Write-Verbose ($PinData | Out-String)
        
                try {                            
                    
                    Write-HostForScript -Message "Getting map image for contact..."
    
                    $result = Get-AzureMapsInfo -RequestType MapPin -PinData $pinData -FindCenter  
        
                    Write-HostForScript -Message "Attempting to send data to Discord..."
                    Invoke-WebHookSend -PinData $pinData -ContactData $contact -ImagePath $result

                    Write-HostForScript -Message "Looking for ADIF match so we can try to post to QRZ..."
        
                    #Adif match                    
                    $timeWorkedForMatch = $contact.WorkedTime -replace ':',''                    
                    $dateWorkedForMatch = $contact.WorkedDate -replace '-',''

                    $adifMatch = $adifData | 
                        Where-Object {

                            $_.call -eq $theirCallInfo.CallSign -and
                            $_.time_on -eq $timeWorkedForMatch  -and
                            $_.qso_date -eq $dateWorkedForMatch

                        }
                                 
                    if ($adifMatch) {

                        if ($AutoLogQrz -or (Read-Host -Prompt 'Post to QRZ?') -like "*y*") {
                                
                            Write-HostForScript "Attempting to post log to QRZ..."

                            $result = Invoke-QrzLogPost -Adif $adifMatch
                            
                            Write-HostForScript -Message "Results from QRZ log post:"
                            Write-HostForScript -Message "$($result)"

                        }

                    }                                                                           
                        
                }
                catch {
        
                    $errorMessage = $_.Exception.Message
                    Write-Error "Error -> [$errorMessage]!"
        
                }
                finally {
        
                    $processed = Invoke-ProcessedLog -Action Add -FilePath $processedPath -Guid $guid                    
                    $logData   = Import-WsjtxLog -LogPath $wsjtxLogPath
                    $adifData  = Import-WsjtxAdifLog -LogPath $wsjtxAdifLogPath

                    Start-Sleep -Second 7
        
                }                                        
            } else {

                $processed  = Invoke-ProcessedLog -Action Get -FilePath $processedPath                  
                $logData    = Import-WsjtxLog -LogPath $wsjtxLogPath
                $adifData   = Import-WsjtxAdifLog -LogPath $wsjtxAdifLogPath

                Start-Sleep -Second 2

            }
        }
    } 
}
function Invoke-PSHammy {
    [cmdletbinding()]
    param(
        [Parameter(

        )]
        [switch]
        $DoNotAutoDeleteImages
    )
          
    if (!(Test-Path -Path $wsjtxLogPath -ErrorAction SilentlyContinue)) {
    
        throw "Unable to access -> [$wsjtxLogPath], cannot continue!"
    
    }
        
    #Folder/file creation for input (config and processed list)
    if (!(Test-Path -Path $inputPath -ErrorAction SilentlyContinue)) {
    
        Write-HostForScript -Message "Path [$inputPath] does not exist... creating!"
    
        New-Item -Path $inputPath -ItemType Directory | Out-Null
    
    }
    
    if (!(Test-Path -Path $qrzCredPath -ErrorAction SilentlyContinue)) {
    
        Write-HostForScript -Message "Path [$qrzCredPath] does not exist... creating!"
    
        do {
    
            Write-HostForScript -Message "QRZ API access is required for this script... your credentials will be used to get the API key"
            Write-HostForScript -Message "The file path is -> [$($qrzCredPath)]"
            Write-HostForScript -Message "The password is machine-encrypted"
    
            (Get-Credential -Message "Please enter your QRZ credentials" ) | Export-Clixml -Path $qrzCredPath -Force 
    
        } while (
    
            !(Test-Path -Path $qrzCredPath -ErrorAction SilentlyContinue)
    
        )
    
    }
    
    
    if (!(Test-Path -Path $outputPath -ErrorAction SilentlyContinue)) {
    
        Write-HostForScript -Message "Path [$outputPath] does not exist... creating!"
    
        New-Item -Path $outputPath -ItemType Directory | Out-Null
    
    }
    
    if (!(Test-Path -Path $processedPath -ErrorAction SilentlyContinue)) {
    
        Write-HostForScript -Message "Path [$processedPath] does not exist... creating!"
        New-Item -Path $processedPath -ItemType File | Out-Null
    
        #Info template for processed calls
        @('ZZ0ZZ-01-01-01-01-01-01','ZZ0ZZ-01-01-01-01-01-01') | ConvertTo-Json | Out-File -FilePath $processedPath
    
    }
    
    if (!(Test-Path -Path $hammyConfigPath -ErrorAction SilentlyContinue)) {
    
        Write-HostForScript -Message "Creating [$hammyConfigPath]"
        New-Item -Path $hammyConfigPath -ItemType File | Out-Null
    
        #Info template for config file
        @{
            'AzureMapsApiKey' = ''
            'QRZApiKey'       = ''        
        } | ConvertTo-Json | Out-File -FilePath $hammyConfigPath
    
        Write-HostForScript "Configuration file created at -> [$hammyConfigPath]... please input your Azure Maps API key..."
    
        break
    
    }
    
    $script:config = Import-Config -Path $hammyConfigPath
    $wsjtxConfig   = Get-IniContent -FilePath $wsjtxConfigPath
    $qrzCreds      = Import-Clixml -Path $qrzCredPath
    
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
    
        Write-HostForScript -Message "Checking QRZ session status..."
    
        $result = Get-QrzApiSession -Credential $qrzCreds
    
        if ($result -eq 'keep') {
    
            Write-HostForScript -Message "Keeping key for QRZ, as it still works!"
    
        } else {
    
            Write-HostForScript -Message "Refreshing QRZ API key, old key does not work!"
    
        }
    
        $processed  = Invoke-ProcessedLog -Action Get -FilePath $processedPath     
        $myCallData = Invoke-CallSignLookup -CallSign $DefaultCall    
    
        if ($myCallData.lat -and $myCallData.long) {
    
            $myLat  = $myCallData.lat
            $myLong = $myCallData.long
    
        } else {
    
            $lookupAddy = "$($myCallData.Addy) $($myCallData.AddyTwo) $($myCallData.State) $($myCallData.Zip)"
            $myLocation = Get-AzureMapsInfo -RequestData $lookupAddy -RequestType 'Search'
    
            $myLat  = $myLocation.results[0].position.lat
            $myLong = $myLocation.results[0].position.lon 
    
        }
    
        #As job
        while ($true) {
    
            $fromToday = $logData | Where-Object {
    
                [DateTime]$_.WorkedDate -ge [DateTime]::Now.ToString("yyyy-MM-dd")
        
            }
            
            if ($fromToday.Count -le 0) {
    
                Write-HostForScript -Message "No log entries found -> [$($wsjtxLogPath)] -< aborting!"
                
                break
            }
    
            Write-HostForScript -Message "Found [$($fromToday.Count)] log entries..."
    
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
                        MyState        = $myCallData.State
                        MyRig          = $wsjtxConfig.Configuration.Rig
                        MyGrid         = $myCallData.Grid
                        TheirGrid      = $theirCallInfo.Grid
                        MyImage        = $myCallData.ProfileImage
                        TheirImage     = $theirCallInfo.ProfileImage
                        
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
}
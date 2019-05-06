function Invoke-LogDataGather {
    [cmdletbinding()]
    param(
        
    )

    $script:config      = Import-Config -Path $hammyConfigPath
    $script:wsjtxConfig = Get-IniContent -FilePath $wsjtxConfigPath
    $script:qrzCreds    = Import-Clixml -Path $qrzCredPath

    #Get call sign from wsjtx config
    if ($wsjtxConfig) {

        $DefaultCall = $wsjtxConfig.Configuration.MyCall
    
    }
    
    Write-HostForScript -Message "Imported call sign [$DefaultCall] from WSJT-X.ini..."
    
    Write-HostForScript -Message "Attempting to import log data from [$wsjtxLogPath]..."
    
    $script:logData = Import-WsjtxLog -LogPath $wsjtxLogPath
    
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
    
        $script:processed  = Invoke-ProcessedLog -Action Get -FilePath $processedPath     
        $script:myCallData = Invoke-CallSignLookup -CallSign $DefaultCall    
    
        if ($myCallData.lat -and $myCallData.long) {
    
            $script:myLat  = $myCallData.lat
            $script:myLong = $myCallData.long
    
        } else {
    
            $lookupAddy = "$($myCallData.Addy) $($myCallData.AddyTwo) $($myCallData.State) $($myCallData.Zip)"
            $myLocation = Get-AzureMapsInfo -RequestData $lookupAddy -RequestType 'Search'
    
            $script:myLat  = $myLocation.results[0].position.lat
            $script:myLong = $myLocation.results[0].position.lon 
    
        }
    } else {

        throw "Unable to gather log data from [$wsjtxLogPath]..."

    }
}
function Invoke-PSHammy {
    [cmdletbinding()]
    param(
        
        [Parameter(

        )]
        [switch]
        $DoNotAutoDeleteImages,

        [Parameter(

        )]
        [switch]
        $AsJob,

        [Parameter(

        )]
        [switch]
        $CheckJob,

        [Parameter(

        )]
        [switch]
        $StopJob        

    )
    
    if ($CheckJob) {

        if ($jobInfo.State -eq 'Running') {

            Receive-Job -Name $jobInfo.Name

        } else {

            Write-HostForScript -Message "Job not running or found!"

        }
        
        break
    }

    if ($StopJob) {

        if ($jobInfo.State -eq 'Running') {

            Stop-Job -Name $jobInfo.Name
            Remove-Job -Name $jobInfo.Name

            Write-HostForScript -Message "Job stopped!"

        } else {

            Write-HostForScript -Message "Job not running or found!"
            
        }

        break
    }

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
            'QRZLogApiKey'    = ''
            'FooterTxt'       = ''
            'DefaultThumbUrl' = ''
            'CallApi'         = 'HamDb'
        } | ConvertTo-Json | Out-File -FilePath $hammyConfigPath
    
        Write-HostForScript "Configuration file created at -> [$hammyConfigPath]... please input your Azure Maps API key..."
    
        break
    
    }    

    if ($AsJob) {

        $script:jobInfo = Start-Job -InitializationScript {

            Import-Module "C:\users\thegn\repos\PSHammy\PSHammy"            

        } {
            
            Invoke-LogDataGather
            Invoke-LogCheck

        }

    } else {

        Invoke-LogDataGather
        Invoke-LogCheck

    }  
}    
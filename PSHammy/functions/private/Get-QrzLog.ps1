function Get-QrzLog {
    [cmdletbinding()]
    param(

    )

    begin {

        [string]$baseUrl = 'https://logbook.qrz.com/api'

    }

    process {
        
        $body = @{

            KEY    = "$($config.QRZLogApiKey)"
            ACTION = 'Fetch'

        }

        $result = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $body

        $convertedResult = $result -replace '&lt','<' -replace '&gt','>' -replace ';','' -replace '&','' -replace 'COUNT=[0-9+]','' -replace 'ADIF=','' -replace 'RESULT=.+',''

        $convertedResult = $convertedResult.Split('<eor>').Trim()

        [System.Collections.Generic.List[PSCustomObject]]$logList = @()

        $convertedResult | ForEach-Object {
              
            $curObject   = $null
            $values      = $null
            $headers     = $null
            $regexHeader = $null
            $regexValue  = $null
            $findHeader  = $null
            $findValue   = $null

            $regexHeader = [regex]::new('(?<=<).*?(?=>)')
            $regexValue  = [regex]::new('(?<=>).*?(?=<)|(?<=>).*')
                        
            $findHeader = $regexHeader.Matches($_)
            $findValue  = $regexValue.Matches($_)

            [array]$headers += $findHeader.Value            
            [array]$values  += $findValue.Value
    
            $curObject = [PSCustomObject]@{}

            if ($headers -and $values) {
                $i = 0
                $headers | ForEach-Object {
    
                    $curObject | Add-Member -MemberType NoteProperty -Name $headers[$i].Split(':')[0] -Value $values[$i]
    
                    $i++

                }

                $logList.Add($curObject)
                
            }                  
        }                     
    }

    end {

        return $logList

    }
}
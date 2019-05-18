function ConvertFrom-Adif {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        
        $Text
    )

    begin {

        [System.Collections.Generic.List[PSCustomObject]]$convertedText = @()
        $convertedResult    = $null
        

    }

    process {

        
        $convertedResult = $Text.Split('<eor>').Trim()
                
        $convertedResult | ForEach-Object {
        
            $rawConvertedResult = $null
            $curObject          = $null
            $values             = $null
            $headers            = $null
            $regexHeader        = $null
            $regexValue         = $null
            $findHeader         = $null
            $findValue          = $null

            $rawConvertedResult = "$($_) <eor>" 

            $regexHeader = [regex]::new('(?<=<).*?(?=>)')
            $regexValue  = [regex]::new('(?<=>).*?(?=<)|(?<=>).*')
                        
            $findHeader = $regexHeader.Matches($_)
            $findValue  = $regexValue.Matches($_)

            [array]$headers += $findHeader.Value          
            [array]$values  += $findValue.Value
    
            $curObject = [PSCustomObject]@{

                RawAdif = $rawConvertedResult

            }
            
            if ($headers -and $values) {

                $i = 0

                $headers | ForEach-Object {
    
                    $curObject | Add-Member -MemberType NoteProperty -Name ($headers[$i].Split(':')[0]).Trim() -Value $values[$i].Trim()
    
                    $i++

                }

                $convertedText.Add($curObject)
                
            }                  
        }          
    }

    end {

        return $convertedText
        
    }
}
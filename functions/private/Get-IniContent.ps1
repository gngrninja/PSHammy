Function Get-IniContent {        
    [cmdletbinding()]  
    param(  
        [ValidateNotNullOrEmpty()]          
        [Parameter(
            ValueFromPipeline,
            Mandatory
            )]  
        [string]$FilePath  
    )  
      
    begin {

        if (
            !(Test-Path -Path $FilePath -ErrorAction SilentlyContinue) -or 
            ((Get-Item -Path $FilePath | Select-Object -ExpandProperty Extension) -ne '.ini')
        ) {

            throw "Unable to access [$FilePath], or not an ini file!"

        }

    } 
          
    process  
    {                        
        $iniContents = [PSCustomObject]@{}

        switch -File $FilePath -Regex {  

            # section regex
            '^\[(.+)\]$' {  

                $section = $matches[1]  

                $iniContents | Add-Member -Name $section -MemberType NoteProperty -Value ([PSCustomObject]@{})
                #$ini[$section] = @{}  
                $CommentCount = 0  

            }  

            # comment regex
            '^(;.*)$' {  
                if (!($section))  
                {  
                    $section = "sectionless"
                    $iniContents | Add-Member -Name $section -MemberType NoteProperty -Value ([PSCustomObject]@{})
                    #$ini[$section] = @{}  
                }  
                $value = $matches[1]  
                $CommentCount = $CommentCount + 1  
                $name = "Comment" + $CommentCount  
                $iniContents.$section | Add-Member -Name $name -MemberType NoteProperty -Value $value
                #$iniContents.$section.$name = $value
                #$ini.$section | [$name] = $value  
            }  

            # key regex
            "(.+?)\s*=\s*(.*)" {
                
                if (!($section)) { 
                  
                    $section = "sectionless"  
                    $iniContents | Add-Member -Name $section -MemberType NoteProperty -Value ([PSCustomObject]@{})

                }  

                $name  = $matches[1]
                $value = $matches[2] 

                $iniContents.$section | Add-Member -Name $name -MemberType NoteProperty -Value $value
                $iniContents.$section.$name = $value
                #$ini[$section][$name] = $value  
            }  
        }                     
    }  
          
    end  {

        return $iniContents

    } 
} 
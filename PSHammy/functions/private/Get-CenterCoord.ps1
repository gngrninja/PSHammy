function Get-CenterCoord {
    [cmdletbinding()]
    param(
        $Coords
    )

    begin {

        [double]$x = 0.0
        [double]$y = 0.0
        [double]$z = 0.0

    }

    process {

        #For our callsign
        [double]$myLatitude  = $Coords.MyLat  * [Math]::PI / 180    
        [double]$myLongitude = $Coords.MyLong * [Math]::PI / 180

        $x += [Math]::Cos($myLatitude) * [Math]::Cos($myLongitude)
        $y += [Math]::Cos($myLatitude) * [Math]::Sin($myLongitude)
        $z += [Math]::Sin($myLatitude)

        #For their callsign
        [double]$theirLatitude  = $Coords.TheirLat  * [Math]::PI / 180    
        [double]$theirLongitude = $Coords.TheirLong * [Math]::PI / 180

        $x += [Math]::Cos($theirLatitude) * [Math]::Cos($theirLongitude)
        $y += [Math]::Cos($theirLatitude) * [Math]::Sin($theirLongitude)
        $z += [Math]::Sin($theirLatitude)

        $total = 2

        $x = $x / $total
        $y = $y / $total
        $z = $z / $total

        [double]$centralLon  = [Math]::Atan2($y, $x)
        [double]$centralSqrt = [Math]::Sqrt($x * $x + $y * $y) 
        [double]$centralLat  = [Math]::Atan2($z, $centralSqrt)

    }

    end {

        $returnObject = [PSCustomObject]@{

            CentralLat  = [Math]::Round($centralLat * 180 / [Math]::PI, 2)
            CentralLong = [Math]::Round($centralLon * 180 / [Math]::PI, 2)       

        }

        return $returnObject
        
    }    
}
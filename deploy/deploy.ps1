$separator = [System.IO.Path]::DirectorySeparatorChar
$psHammyModulePath = "$($env:PSModulePath -split ':' | Select-Object -First 1)$($separator)PSHammy$($separator)PSHammy"

$modulePublicPath  = "$($psHammyModulePath)$($separator)functions$($separator)public"
$modulePrivatePath = "$($psHammyModulePath)$($separator)functions$($separator)private"

if (Test-Path -Path $psHammyModulePath) {
    Write-Host "PSHammy module found..."
    Write-Host "Script location -> [$($PSScriptRoot)]"
    
    #import functions
    $public  = @(Get-ChildItem -Path "$($PSScriptRoot)$($separator)..$($separator)PSHammy$($separator)functions$($separator)public$($separator)*.ps1")
    $private = @(Get-ChildItem -Path "$($PSScriptRoot)$($separator)..$($separator)PSHammy$($separator)functions$($separator)private$($separator)*.ps1")
    
    $public | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $modulePublicPath
        Write-Host "Copying [$($_.FullName)] to [$($modulePublicPath)]"
    }
    $private | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $modulePrivatePath
        Write-Host "Copying [$($_.FullName)] to [$($modulePrivatePath)]"
    }
    Import-Module $psHammyModulePath -Force
}
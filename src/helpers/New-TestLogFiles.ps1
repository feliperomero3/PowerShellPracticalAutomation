$logsDirectory = Join-Path -Path "$Env:TEMP" -ChildPath 'Logs'
$pastDays = 30

if (-not(Test-Path -Path $logsDirectory)) {
    New-Item -Path $logsDirectory -ItemType Directory
}

function Set-RandomFileSize {
    <#
    .SYNOPSIS
    Adds random bytes to an existing file.

    .DESCRIPTION
    Adds random bytes to an existing file. The random size is generated by multiplying a random number by 1024^2.

    .PARAMETER FilePath
    The filepath of the file to add random bytes to.

    .EXAMPLE
    Set-RandomFileSize -FilePath "$Env:TEMP\Logs\log_20220520.log"

        Directory: C:\Users\username\AppData\Local\Temp\Logs

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a---          21/05/2022    22:45       48234496 log_20220520.log
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath
    )

    $size = Get-Random -Minimum 1 -Maximum 50
    $size = $size * 1024 * 1024
    $file = [System.IO.File]::Open($FilePath, 4)
    
    $file.SetLength($size)
    $file.Close()

    Get-Item -Path $file.Name
}

for ($i = 0; $i -lt $pastDays; $i++) {
    $date = (Get-Date).AddDays(-$i)
    $fileName = "u_ex$($date.ToString('yyyyMMdd')).log"
    $filePath = Join-Path -Path $logsDirectory -ChildPath $fileName
    $date | Out-File -FilePath $filePath
    Set-RandomFileSize -FilePath $filePath

    Get-Item -Path $FilePath | ForEach-Object {
        $_.CreationTime = $date
        $_.LastWriteTime = $date
        $_.LastAccessTime = $date 
    }
}

<#
.SYNOPSIS
    A simple script to clean up old log files.
.DESCRIPTION
    Finds the files to archive, adds the old files to an archive file, then removes the old files.
.NOTES
    Work in progress.
#>


function Set-ArchiveFilePath {
    <#
    .SYNOPSIS
        Creates a file path.
    .DESCRIPTION
        Creates a file path for an archive file with .zip extension.
        Takes a prefix for the archive file and appends it a timestamp e. g. NewArchive20220519.zip
    .PARAMETER ZipPath
        The path to store the archive.
    .PARAMETER ZipPrefix
        The prefix for the archive.
    .PARAMETER Date
        The date value to use for creating the timestamp.
    .EXAMPLE
        Set-ArchiveFilePath -ZipPath "$Env:TEMP\Archives" -ZipPrefix 'LogArchive-' -Date '2022-05-20' -Verbose
        VERBOSE: Created folder 'C:\Users\username\AppData\Local\Temp\Archives'.
        C:\Users\username\AppData\Local\Temp\Archives\LogArchive-20220520.zip
    .EXAMPLE
        Set-ArchiveFilePath -ZipPath "$Env:TEMP\Archives" -ZipPrefix 'LogArchive-' -Date '2022-05-20' -Verbose
        C:\Users\username\AppData\Local\Temp\Archives\LogArchive-20220520.zip
    .EXAMPLE
        Set-ArchiveFilePath -ZipPath "$Env:TEMP\Archives" -ZipPrefix 'LogArchive-' -Date '2022-05-20' -Verbose
        The file 'C:\Users\username\AppData\Local\Temp\Archives\LogArchive-20220520.zip' already exists.
    .OUTPUTS
        The archive file path.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ZipPath,
        
        [Parameter(Mandatory = $true)]
        [string]
        $ZipPrefix,

        [Parameter(Mandatory = $true)]
        [datetime]
        $Date
    )

    if (-not(Test-Path -Path $ZipPath)) {
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        Write-Verbose -Message "Created folder '$ZipPath'."
    }

    $timeString = $Date.ToString('yyyyMMdd')
    $zipName = "$($ZipPrefix)$($timeString).zip"
    $zipFile = Join-Path -Path $ZipPath -ChildPath $zipName

    if (Test-Path -Path $zipFile) {
        throw "The file '$zipFile' already exists."
    }

    $zipFile
}

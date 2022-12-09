#Requires -Modules FileCleanupTools

<#
.SYNOPSIS
    A simple script to clean up old log files.
.DESCRIPTION
    Finds the files to archive, adds the old files to an archive file, then removes the old files.
.INPUTS
    None.
.OUTPUTS
    None.
.EXAMPLE
    .\Backup-LogFiles.ps1 -LogPath "$Env:TEMP\Logs" -ZipPath "$Env:TEMP\Logs\Archives" -ZipPrefix 'Archives-' -NumberOfDays 30
#>
[CmdletBinding()]
[OutputType()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LogPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPrefix,

    [Parameter(Mandatory = $false)]
    [double]$NumberOfDays = 30
)

$Date = (Get-Date).AddDays(-$NumberOfDays)

$Files = Get-ChildItem -Path $LogPath -File | Where-Object { $_.LastWriteTime -gt $Date }

$ZipParameters = @{
    ZipPath   = $ZipPath
    ZipPrefix = $ZipPrefix
    Date      = $Date
}

$ZipFile = Set-ArchiveFilePath @ZipParameters

$Files | Compress-Archive -DestinationPath $ZipFile

$FilesParameters = @{
    ZipFile       = $ZipFile
    FilesToDelete = $Files
}

Remove-ArchivedFiles @FilesParameters

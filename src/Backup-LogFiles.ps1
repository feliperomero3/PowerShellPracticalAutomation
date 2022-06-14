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

        The function creates the file path.
    .EXAMPLE
        Set-ArchiveFilePath -ZipPath "$Env:TEMP\Archives" -ZipPrefix 'LogArchive-' -Date '2022-05-20' -Verbose
        C:\Users\username\AppData\Local\Temp\Archives\LogArchive-20220520.zip

        In this example the directory (the value provided to the ZipPath parameter) already exists,
        the function will not attempt to create the directory and only creates the the file path.
    .EXAMPLE
        Set-ArchiveFilePath -ZipPath "$Env:TEMP\Archives" -ZipPrefix 'LogArchive-' -Date '2022-05-20' -Verbose
        The file 'C:\Users\username\AppData\Local\Temp\Archives\LogArchive-20220520.zip' already exists.

        In this example the file path already exists, the function throws an exception with a message stating
        that the file already exists.
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
    process {
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
}

function Remove-ArchivedFiles {
    <#
    .SYNOPSIS
    Delete archived files.
    
    .DESCRIPTION
    Delete files that have a match in a specified archive.
    
    .EXAMPLE
    Remove-ArchivedFiles -ZipFile "$Env:TEMP\Logs\u_ex20220316.zip" -FilesToDelete (Get-ChildItem -Path "$Env:TEMP\Logs\u_ex20220316.log") 
    
    .EXAMPLE
    Remove-ArchivedFiles -ZipFile "$Env:TEMP\Logs\u_ex20220316.zip" -FilesToDelete (Get-ChildItem -Path "$Env:TEMP\Logs\u_ex20220316.log") -WhatIf
    What if: Performing the operation "Remove File" on target "C:\Users\username\AppData\Local\Temp\Logs\u_ex20220316.log".
    #>
    [CmdletBinding()]
    [OutputType()]
    param (
        # The zip file to analyze for files matches.
        [Parameter(Mandatory = $true)]
        [string]
        $ZipFile,

        # The files to be deleted.
        [Parameter(Mandatory = $true)]
        [object]
        $FilesToDelete,

        # Do a dry-run
        [Parameter(Mandatory = $false)]
        [switch]
        $WhatIf = $false
    )
    process {
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem' | Out-Null

        $openZip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
        $zipFileEntries = $openZip.Entries

        foreach ($file in $FilesToDelete) {
            $archivedFile = $zipFileEntries | Where-Object { $_.Name -eq $file.Name -and $_.Length -eq $file.Length }

            if ($null -ne $archivedFile) {
                $file | Remove-Item -Force -WhatIf:$WhatIf
            }
            else {
                Write-Error -Message "'$($file.Name)' was not found in '$($ZipFile)'."
            }
        }
    }
}

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

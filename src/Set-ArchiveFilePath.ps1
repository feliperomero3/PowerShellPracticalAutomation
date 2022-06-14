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

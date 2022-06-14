function Remove-ArchivedFiles {
    <#
    .SYNOPSIS
    Remove archive files.
    
    .DESCRIPTION
    Removes files that have a match in specified archive.
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
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

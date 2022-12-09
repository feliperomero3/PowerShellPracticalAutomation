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

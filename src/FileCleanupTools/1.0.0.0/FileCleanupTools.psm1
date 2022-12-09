$Path = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$Functions = Get-ChildItem -Path $Path -Filter '*.ps1'

foreach ($import in $Functions) {
    try {
        Write-Verbose -Message "dot-sourcing file '$($import.FullName)'"
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.Name)"
    }
}

function New-ModuleTemplate {
    <#
    .SYNOPSIS
    Create a new PowerShell module.
    
    .DESCRIPTION
    Create a new PowerShell module using the built-in New-ModuleManifest cmdlet.
    
    .PARAMETER ModuleName
    The name for the new module.
    
    .PARAMETER ModuleVersion
    The version for the new module.
    
    .PARAMETER Author
    The author for the new module.
    
    .PARAMETER PSVersion
    Required PowerShell version to execute the new module.
    
    .PARAMETER Functions
    The functions to include in the new module. 
    
    .EXAMPLE
    $Module = @{
        ModuleName    = 'FileCleanupTools'
        ModuleVersion = '1.0.0.0'
        Author        = 'Felipe Romero'
        PSVersion     = '7.0'
        Functions     = @('Remove-ArchivedFiles', 'Set-ArchiveFilePath')
    }
    New-ModuleTemplate @Module

    .INPUTS
    None.

    .OUTPUTS
    None.

    .NOTES
    This function creates all the auxiliary directories a typical Script Module uses.
    
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$ModuleVersion,
        [Parameter(Mandatory = $true)]
        [string]$Author,
        [Parameter(Mandatory = $true)]
        [string]$PSVersion,
        [Parameter(Mandatory = $false)]
        [string[]]$Functions
    )
    
    $ModulePath = Join-Path -Path '.\' -ChildPath "$($ModuleName)\$($ModuleVersion)"
    New-Item -Path $ModulePath -ItemType 'Directory'
    Set-Location -Path $ModulePath
    New-Item -Path '.\Public' -ItemType 'Directory'
 
    $ManifestParameters = @{
        ModuleVersion     = $ModuleVersion
        Author            = $Author
        Path              = ".\$($ModuleName).psd1"
        RootModule        = ".\$($ModuleName).psm1"
        PowerShellVersion = $PSVersion
    }    
    New-ModuleManifest @ManifestParameters
 
    $File = @{
        Path     = ".\$($ModuleName).psm1"
        Encoding = 'utf8'
    }
    Out-File @File
 
    $Functions | ForEach-Object {
        Out-File -Path ".\Public\$($_).ps1" -Encoding 'utf8'
    }
}

$Module = @{
    ModuleName    = 'FileCleanupTools'
    ModuleVersion = '1.0.0.0'
    Author        = 'Felipe Romero'
    PSVersion     = '7.0'
    Functions     = @('Remove-ArchivedFiles', 'Set-ArchiveFilePath')
}
New-ModuleTemplate @Module


function Get-CPathProvider
{
    <#
    .SYNOPSIS
    Returns a path's PowerShell provider.

    .DESCRIPTION
    When you want to do something with a path that depends on its provider, use this function.  The path doesn't have to
    exist.

    If you pass in a relative path, it is resolved relative to the current directory.  So make sure you're in the right
    place.

    .OUTPUTS
    System.Management.Automation.ProviderInfo.

    .EXAMPLE
    Get-CPathProvider -Path 'C:\Windows'

    Demonstrates how to get the path provider for an NTFS path.
    #>
    [CmdletBinding()]
    param(
        # The path whose provider to get.
        [Parameter(Mandatory)]
        [String] $Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # If the path exists, easy.
    if (Test-Path -Path $Path)
    {
        return (Get-Item -Path $Path).PSProvider
    }

    foreach ($drive in (Get-PSDrive))
    {
        $provider = $drive.Provider
        $driveRootPath = $drive.Name
        if (-not ($provider | Get-Member -Name 'VolumeSeparatedByColon') -or $provider.VolumeSeparatedByColon)
        {
            $driveRootPath = "${driveRootPath}:"
        }

        $driveRootPath = Join-Path -Path $driveRootPath -ChildPath ([IO.Path]::DirectorySeparatorChar)

        if ($Path.StartsWith($driveRootPath, [StringComparison]::CurrentCultureIgnoreCase))
        {
            return $provider
        }
    }

    $currentPath = (Get-Location).Path
    if (-not ($Path.StartsWith($currentPath, [StringComparison]::CurrentCultureIgnoreCase)))
    {
        $provider = Get-CPathProvider -Path (Join-Path -Path $currentPath -ChildPath $Path) -ErrorAction Ignore
        if ($provider)
        {
            return $provider
        }
    }

    $msg = "Unable to determine the provider for path ""${Path}""."
    Write-Error -Message $msg -ErrorAction $ErrorActionPreference
}

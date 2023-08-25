
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

    $driveName = $Path | Split-Path -Qualifier -ErrorAction Ignore
    if (-not $driveName)
    {
        $driveName = Get-Location | Split-Path -Qualifier -ErrorAction Ignore
        if (-not $driveName)
        {
            $driveName = (Get-Location).Path.Substring(0, 1)
        }
    }

    $driveName = $driveName.TrimEnd(':')

    $drive = Get-PSDrive -Name $driveName -ErrorAction Ignore
    if( -not $drive )
    {
        $drive = Get-PSDrive -PSProvider $driveName -ErrorAction Ignore
    }

    if (-not $drive)
    {
        $msg = "Failed to get provider for path ${Path} because there is no drive named ""${driveName}"" and no " +
               "that uses provider ""${driveName}""."
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
        return
    }

    $drive | Select-Object -First 1 | Select-Object -ExpandProperty 'Provider'
}

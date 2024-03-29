
function Resolve-CFullPath
{
    <#
    .SYNOPSIS
    Converts a relative path to an absolute path.

    .DESCRIPTION
    Unlike `Resolve-Path`, this function does not check whether the path exists. It just converts relative paths to
    absolute paths using .NET's `[IO.Path]::GetFullPath()` method.

    Unrooted paths (e.g. `..\..\See\I\Do\Not\Have\A\Root`) are first joined with the current directory (as returned by
    `Get-Location`).

    .EXAMPLE
    Resolve-CFullPath -Path 'C:\Projects\Carbon\Test\..\Carbon\FileSystem.ps1'

    Returns `C:\Projects\Carbon\Carbon\FileSystem.ps1`.

    .EXAMPLE
    Resolve-CFullPath -Path 'C:\Projects\Carbon\..\I\Do\Not\Exist'

    Returns `C:\Projects\I\Do\Not\Exist`.

    .EXAMPLE
    Resolve-CFullPath -Path ..\..\Foo\..\Bar

    Because the `Path` isn't rooted, joins `Path` with the current directory (as returned by `Get-Location`), and
    returns the full path.  If the current directory is `C:\Projects\Carbon`, returns `C:\Bar`.
    #>
    [CmdletBinding()]
    param(
        # The path to resolve.
        [Parameter(Mandatory)]
        [String] $Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not ([System.IO.Path]::IsPathRooted($Path)))
    {
        $Path = Join-Path -Path (Get-Location) -ChildPath $Path
    }
    return [IO.Path]::GetFullPath($Path)
}

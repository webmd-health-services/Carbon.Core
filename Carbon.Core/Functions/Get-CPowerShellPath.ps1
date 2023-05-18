
function Get-CPowerShellPath
{
    <#
    .SYNOPSIS
    Gets the path to powershell.exe.

    .DESCRIPTION
    The `Get-CPowerShellPath` function returns the path to the PowerShell binary for the current edition of PowerShell.

    On 64-bit versions of Windows PowerShell, it returns the path to the PowerShell binary that matches the architecture
    of the operating system, regardless of the architecture of Windows PowerShell. Use the `x86` switch to get the
    path to a 32-bit PowerShell.

    On non-Windows operating systems, if you request a 32-bit version of PowerShell with teh `x86` switch, the function
    writes an error because there are no known mixed x86/x64 platforms other than Windows so requesting an explicit
    32-bit version doesn't make sense.

    .EXAMPLE
    Get-CPowerShellPath

    Returns the path to the version of PowerShell that matches the computer's architecture (i.e. x86 or x64).

    .EXAMPLE
    Get-CPowerShellPath -x86

    Returns the path to the x86 version of PowerShell. Only valid on Windows.
    #>
    [CmdletBinding()]
    param(
        # The architecture of the PowerShell executable to run. The default is the architecture of the current
        # process.
        [switch] $x86
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    Write-Debug "[Carbon.Core\Get-CPowerShellPath]"

    $psHomePath = Get-Variable -Name 'PSHOME' -ValueOnly

    $cmdName = 'powershell'
    $edition = 'Desktop'
    if ((Test-CPowerShell -IsCore))
    {
        $edition = 'Core'
        $cmdName = 'pwsh'
    }

    $executableName = $cmdName
    if ((Test-COperatingSystem -IsWindows))
    {
        $executableName = "$($cmdName).exe"
    }

    Write-Debug -Message "  Edition            $($edition)"

    if (-not $IsWindows)
    {
        if ($x86)
        {
            $msg = "The $($PSVersionTable['Platform']) does not support simultaneous x86/x64."
            Write-Warning -Message $msg -ErrorAction $ErrorActionPreference
        }
        return Join-Path -Path $psHomePath -ChildPath $executableName -Resolve
    }

    if ($edition -eq 'Desktop')
    {
        $system = [Environment]::GetFolderPath('System') | Split-Path -Leaf
        $systemx86 = [Environment]::GetFolderPath('Systemx86') | Split-Path -Leaf
        $systemx64 = 'sysnative'

        $psHomeDirName = @{
            'x64' = $system;
            'x86' = $systemx86;
        }

        $resolvedPaths = @{
            'x64-x64-x64' = $system;
            'x64-x64-x86' = $systemx86
            'x64-x86-x64' = $systemx64;
            'x64-x86-x86' = $system;
            'x86-x64-x64' = $system;
            'x86-x64-x86' = $system;
            'x86-x86-x64' = $system;
            'x86-x86-x86' = $system;
        }
    }
    else
    {
        $programFilesx86 = [Environment]::GetFolderPath('ProgramFilesx86') | Split-Path -Leaf
        $programFilesx64 = $env:ProgramW6432
        if (-not $programFilesx86)
        {
            $programFilesx64 = [Environment]::GetFolderPath('ProgramFiles') -replace ' \(x86\)', ''
        }
        $programFilesx64 = $programFilesx64 | Split-Path -Leaf
        $programFiles = [Environment]::GetFolderPath('ProgramFiles') | Split-Path -Leaf

        Write-Debug "  PSHOME           ${psHomePath}"
        Write-Debug "  ProgramFiles     ${programFiles}"
        Write-Debug "  ProgramFilesx86  ${programFilesx86}"
        Write-Debug "  ProgramFilesx64  ${programFilesx64}"

        $psHomeDirName = @{
            'x64' = $programFilesx64;
            'x86' = $programFilesx86;
        }

        $resolvedPaths = @{
            'x64-x64-x64' = $programFilesx64;
            'x64-x64-x86' = $programFilesx86;
            'x64-x86-x64' = $programFilesx64;
            'x64-x86-x86' = $programFilesx86;
            'x86-x64-x64' = $programFilesx64;
            'x86-x64-x86' = $programFilesx64;
            'x86-x86-x64' = $programFilesx64;
            'x86-x86-x86' = $programFilesx64;
        }
    }

    Write-Debug "  PSHOME Architecture Map:"
    foreach ($key in ($psHomeDirName.Keys | Sort-Object))
    {
        Write-Debug "    ${key}              $($psHomeDirName[$key])"
    }

    Write-Debug "  Architecture Map:"
    foreach ($key in ($resolvedPaths.Keys | Sort-Object))
    {
        Write-Debug "    ${key}      $($resolvedPaths[$key])"
    }

    $osArch = 'x64'
    if (Test-COperatingSystem -Is32Bit)
    {
        $osArch = 'x86'
    }

    $psArch = 'x64'
    if (Test-CPowerShell -Is32Bit)
    {
        $psArch = 'x86'
    }

    $requestedPsArch = 'x64'
    if ($x86)
    {
        $requestedPsArch = 'x86'
    }

    $key = "${osArch}-${psArch}-${requestedPsArch}"
    Write-Debug "  Architecture:"
    Write-Debug "    ${key}"
    $regex = "(\\|/)$([regex]::Escape($psHomeDirName[$psArch]))(\\|/)"
    $resolvedPath = $resolvedPaths[$key]
    Write-Debug "  ""${psHomePath}"" -replace ""${regex}"", ""`$1${resolvedPath}`$2"""
    $dirPath = $psHomePath -replace $regex, "`$1${resolvedPath}`$2"
    Write-Debug "  ${dirPath}"
    $fullPath = Join-Path -Path $dirPath -ChildPath $executableName
    Write-Debug "  ${fullPath}"
    return $fullPath
}

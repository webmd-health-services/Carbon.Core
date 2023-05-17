
function Get-CPowerShellPath
{
    <#
    .SYNOPSIS
    Gets the path to powershell.exe.

    .DESCRIPTION
    The `Get-CPowerShellPath` function returns the path to the PowerShell binary for the current edition of PowerShell.

    On 64-bit versions of Windows PowerShell, it returns the path to the PowerShell binary that matches the architecture
    of the operating system, regardless of the architecture of Windows PowerShell. Use the `x86` switch to get back the
    path to a 32-bit operating system.

    Here are the possible combinations of operating system, PowerShell, and desired path architectures, and the path
    they map to.

        +-----+-----+------+--------------------------------------------------------------+
        | OS  | PS  | Path | Result                                                       |
        +-----+-----+------+--------------------------------------------------------------+
        | x64 | x64 | x64  | $env:windir\System32\Windows PowerShell\v1.0\powershell.exe  |
        | x64 | x64 | x86  | $env:windir\SysWOW64\Windows PowerShell\v1.0\powershell.exe  |
        | x64 | x86 | x64  | $env:windir\sysnative\Windows PowerShell\v1.0\powershell.exe |
        | x64 | x86 | x86  | $env:windir\SysWOW64\Windows PowerShell\v1.0\powershell.exe  |
        | x86 | x86 | x64  | $env:windir\System32\Windows PowerShell\v1.0\powershell.exe  |
        | x86 | x86 | x86  | $env:windir\System32\Windows PowerShell\v1.0\powershell.exe  |
        +-----+-----+------+--------------------------------------------------------------+

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

    $cmdName = 'powershell'
    $edition = 'Desktop'
    if( (Test-CPowerShell -IsCore) )
    {
        $edition = 'Core'
        $cmdName = 'pwsh'
    }

    $executableName = $cmdName
    if( (Test-COperatingSystem -IsWindows) )
    {
        $executableName = "$($cmdName).exe"
    }

    Write-Debug -Message "  Edition                        $($edition)"

    if (-not $IsWindows)
    {
        return Join-Path -Path $PSHOME -ChildPath $executableName -Resolve
    }

    # Map the system directory name from the current PowerShell architecture to the requested architecture.
    $sysDirNames = @{
        'powershell' = @{
            # If PowerShell is 64-bit
            'x64' = @{
                # These are paths to PowerShell matching requested architecture.
                'x64' = 'System32';
                'x86' = 'SysWOW64';
            };
            # If PowerShell is 32-bit.
            'x86' = @{
                # These are the paths to get to the appropriate architecture.
                'x64' = 'sysnative';
                'x86' = 'System32';
            }
        }
        'pwsh' = @{
            # If PowerShell is 64-bit
            'x64' = @{
                # These are paths to PowerShell matching requested architecture.
                'x64' = 'Program Files';
                'x86' = 'Program Files (x86)';
            };
            # If PowerShell is 32-bit.
            'x86' = @{
                # These are the paths to get to the appropriate architecture.
                'x64' = 'Program Files';
                'x86' = 'Program Files (x86)';
            }
        }
    }

    # PowerShell is always in the same place on x86 Windows.
    $osArchitecture = 'x64'
    if( (Test-COperatingSystem -Is32Bit) )
    {
        $osArchitecture = 'x32'
        return Join-Path -Path $PSHOME -ChildPath $executableName
    }
    Write-Debug -Message "  Operating System Architecture  $($osArchitecture)"

    $architecture = 'x64'
    if( $x86 )
    {
        $architecture = 'x86'
    }

    $psArchitecture = 'x64'
    if ((Test-CPowerShell -Is32Bit))
    {
        $psArchitecture = 'x86'
    }

    Write-Debug -Message "  PowerShell Architecture        $($psArchitecture)"
    Write-Debug -Message "  Requested Architecture         $($architecture)"
    $sysDirName = $sysDirNames[$cmdName][$psArchitecture][$architecture]
    Write-Debug -Message "  Architecture SysDirName        $($sysDirName)"

    $path = $PSHOME -replace '(Program Files( \(x86\))?)|(\bSystem32|SysWOW64\b)', $sysDirName
    return Join-Path -Path $path -ChildPath $executableName
}

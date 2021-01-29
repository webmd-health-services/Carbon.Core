
function Test-COperatingSystem
{
    <#
    .SYNOPSIS
    Tests attributes of the current operating system.
    
    .DESCRIPTION
    The `Test-COperatingSystem` function tests atrributes of the current operating system, returning `$true` if they
    are `$true` and `$false` otherwise. It supports the following switches (only one can be given at at time) that 
    return the following attributes:

    * `Is32Bit`: is the architecture 32-bit? Uses `[Environment]::Is64BitOperatingSystem`.
    * `Is64Bit`: is the architecture 64-bit? Uses `[Environment]::Is64BitOperatingSystem`.
    * `IsWindows`: is the operating system Windows? Uses the `$IsWindows` built-in variable, it it exists. If it doesn't,
      returns `$true` (only Windows operating systems don't have this variable).
    * `IsLinux`: is the operating system Linux? Uses the `$IsLinux` built-in variable, if it exists. If it doesn't,
      returns `$false` (all Linux systems have the `IsLinux` variable).
    * `IsMacOS`: is the operating system macOS? Uses the `$IsMacOS` built-in variable, if it exists. If it doesn't,
      returns `$false` (all macOS systems have the `IsMacOS` variable).


    .OUTPUTS
    System.Boolean.

    .LINK
    http://msdn.microsoft.com/en-us/library/system.environment.is64bitoperatingsystem.aspx
    
    .EXAMPLE
    Test-COperatingSystem -Is32Bit
    
    Demonstrates how to test if the current operating system is 32-bit/x86.

    .EXAMPLE
    Test-COperatingSystem -Is64Bit
    
    Demonstrates how to test if the current operating system is 64-bit/x64.

    .EXAMPLE
    Test-COperatingSystem -IsWindows
    
    Demonstrates how to test if the current operating system is Windows.

    .EXAMPLE
    Test-COperatingSystem -IsLinux
    
    Demonstrates how to test if the current operating system is Linux.

    .EXAMPLE
    Test-COperatingSystem -IsMacOS
    
    Demonstrates how to test if the current operating system is macOS.

    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory,ParameterSetName='Is32Bit')]
        [switch]$Is32Bit,

        [Parameter(Mandatory,ParameterSetName='Is64Bit')]
        [switch]$Is64Bit,

        [Parameter(Mandatory,ParameterSetName='IsWindows')]
        [Alias('IsWindows')]
        [switch]$Windows,

        [Parameter(Mandatory,ParameterSetName='IsLinux')]
        [Alias('IsLinux')]
        [switch]$Linux,

        [Parameter(Mandatory,ParameterSetName='IsMacOS')]
        [Alias('IsMacOS')]
        [switch]$MacOS
    )
    
    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    switch( $PSCmdlet.ParameterSetName )
    {
        'Is32Bit' { return -not [Environment]::Is64BitOperatingSystem }
        'Is64Bit' { return [Environment]::Is64BitOperatingSystem }
        'IsWindows' {
            if( (Test-Path -Path 'variable:IsWindows') )
            {
                return $IsWindows
            }
            return $true
        }
        'IsLinux' { return (Test-Path -Path 'variable:IsLinux') -and $IsLinux }
        'IsMacOS' { return (Test-Path -Path 'variable:IsMacOS') -and $IsMacOS }
    }
}


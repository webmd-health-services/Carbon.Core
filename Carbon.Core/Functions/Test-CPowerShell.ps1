
function Test-CPowerShell
{
    <#
    .SYNOPSIS
    Tests attributes of the current PowerShell process.

    .DESCRIPTION
    The `Test-CPowerShell` function tests attributes of the current PowerShell process (or process hosting the 
    current PowerShell runspace). It uses the following switches to test the following conditions:

    * `Is32Bit`: if the process architecture is 32-bit/x86 (uses `[Environment]::Is64BitProcess`).
    * `Is64Bit`: if the process architecture is 64-bit/x64 (uses `[Environment]::Is64BitProcess`).
    * `IsDesktop`: if the process is running on Windows PowerShell (uses `$PSVersionTable.Edition`; if this property 
       doesn't exist, always returns `$true`).
    * `IsCore`: if the process is running PowerShell Core (uses `$PSVersionTable.Edition`).

    .OUTPUTS
    System.Boolean.

    .EXAMPLE
    Test-CPowerShell -Is32Bit

    Demonstrates how to test if the current PowerShell process architecture is 32-bit/x86.

    .EXAMPLE
    Test-CPowerShell -Is64Bit

    Demonstrates how to test if the current PowerShell process architecture is 64-bit/x64.

    .EXAMPLE
    Test-CPowerShell -IsDesktop

    Demonstrates how to test if the current PowerShell process is Windows PowerShell.

    .EXAMPLE
    Test-CPowerShell -IsCore

    Demonstrates how to test if the current PowerShell process is Windows Core.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory,ParameterSetName='Is32Bit')]
        [switch]$Is32Bit,

        [Parameter(Mandatory,ParameterSetName='Is64Bit')]
        [switch]$Is64Bit,

        [Parameter(Mandatory,ParameterSetName='IsDesktop')]
        [switch]$IsDesktop,

        [Parameter(Mandatory,ParameterSetName='IsCore')]
        [switch]$IsCore
    )
    
    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    switch( $PSCmdlet.ParameterSetName )
    {
        'Is32Bit' { return -not [Environment]::Is64BitProcess }
        'Is64Bit' { return [Environment]::Is64BitProcess }
        'IsDesktop' { return -not $PSVersionTable['PSEdition'] -or $PSVersionTable['PSEdition'] -eq 'Desktop' }
        'IsCore' { return $PSVersionTable['PSEdition'] -eq 'Core' }
    }
}

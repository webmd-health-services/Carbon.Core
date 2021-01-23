
# Use approved PowerShell verbs for all functions/scripts: https://docs.microsoft.com/en-us/powershell/developer/cmdlet/approved-verbs-for-windows-powershell-commands
# Use singular nouns, not plural, e.g. `Get-Thing` *not* `Get-Things`.
# See https://whsconfluence.webmd.net/display/WHS/PowerShell+Coding+Standards for our PowerShell Coding Standards
function FUNCTION_NAME
{
    <#
    .SYNOPSIS
    ...

    .DESCRIPTION
    The `FUNCTION_NAME` function...

    .EXAMPLE

    This example demonstrates...
    #>
    [CmdletBinding()]
    param(

    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

}
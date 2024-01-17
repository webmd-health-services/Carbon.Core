
function Test-CType
{
    <#
    .SYNOPSIS
    Tests if a .NET type exists.

    .DESCRIPTION
    The `Test-CType` function tests if a .NET type exists. Pass the namespace-qualified type name to the `Name`
    parameter. For the quickest and most unambiguous type resolution, pass the [assembly-qualifed type
    name](https://learn.microsoft.com/en-us/dotnet/api/system.type.assemblyqualifiedname#system-type-assemblyqualifiedname)
    to the `Name` parameter. Otherwise, the function checks each loaded assembly for the type. If a type is found with
    the given, returns `$true`. Otherwise, returns `$false`. It stops searching as soon as it finds a type.

    By default, searches are case-insensitive. To perform a case-sensitive search, use the `CaseSenstive` switch.

    By default, returns `$true` if at least one type exists with the given name. Otherwise, returns `$false`. Use the
    `$PassThru` switch to get `[Type]` objects returned for all types whose names match.

    .EXAMPLE
    Test-CType -Name 'System.String'

    Demonstrates that you must call `Test-CType` with at least the namespace-qualified type name, not just the type's
    base name.

    .EXAMPLE
    Test-CType -Name 'Carbon.Core.ExampleType' -CaseSensitive

    Demonstrates how to perform a case-sensitive search.

    .EXAMPLE
    Test-CType -Name 'Carbon.Core.DuplicateType' -PassThru

    Demonstrates how to get `[Type]` object returned for all loaded types that match the passed in type name.
    #>
    [CmdletBinding()]
    param(
        # The namespace-qualified type name of the type whose existence to test. Assmbly-qualified type names are also
        # supported and result in the fastest and least ambiguous lookup and results.
        [Parameter(Mandatory, Position=0)]
        [String] $Name,

        # By default, searches are case insensitive. Use this switch to make the search case sensitive.
        [switch] $CaseSensitive,

        # By default, the function returns `$true` if at least one type exists whose name equals the name passed in. Use
        # this switch to instead get `[Type]` objects returns for all types whose name is equal to the value of the
        # `Name` parameter.
        [switch] $PassThru
    )

    Set-STrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $ignoreCase = -not $CaseSensitive
    $found = $false

    $type = [Type]::GetType($Name, $false, $ignoreCase)
    if ($type)
    {
        if ($PassThru)
        {
            $found = $true
            $type | Write-Output
        }
        else
        {
            return $true
        }
    }

    foreach ($assembly in [AppDomain]::CurrentDomain.GetAssemblies())
    {
        $type = $assembly.GetType($Name, $false, $ignoreCase)
        if (-not $type)
        {
            continue
        }

        if ($PassThru)
        {
            $found = $true
            $type | Write-Output
            continue
        }

        return $true
    }

    if ($PassThru)
    {
        return
    }

    return $false
}

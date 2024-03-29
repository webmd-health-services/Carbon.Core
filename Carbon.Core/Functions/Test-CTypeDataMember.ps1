
function Test-CTypeDataMember
{
    <#
    .SYNOPSIS
    Tests if a type has an extended type member defined.

    .DESCRIPTION
    `Test-CTypeDataMember` tests if a type has an extended type member defined. If the type isn't found, you'll get an
    error.

    Returns `$true` if the type is found and the member is defined. Otherwise, returns `$false`.

    .EXAMPLE
    Test-CTypeDataMember -TypeName 'Microsoft.Web.Administration.Site' -MemberName 'PhysicalPath'

    Tests if the `Microsoft.Web.Administration.Site` type has a `PhysicalPath` extended type member defined.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # The type name to check.
        [Parameter(Mandatory)]
        [String] $TypeName,

        # The name of the member to check.
        [Parameter(Mandatory)]
        [String] $MemberName
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $typeData = Get-TypeData -TypeName $TypeName
    if( -not $typeData )
    {
        # The type isn't defined or there is no extended type data on it.
        return $false
    }

    return $typeData.Members.ContainsKey( $MemberName )
}



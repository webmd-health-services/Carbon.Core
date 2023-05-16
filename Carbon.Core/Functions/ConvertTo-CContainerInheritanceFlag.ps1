
function ConvertTo-CContainerInheritanceFlag
{
    <#
    .SYNOPSIS
    Converts a combination of InheritanceFlags Propagation Flags into a CContainerInheritanceFlags
    enumeration value.

    .DESCRIPTION
    `Grant-CPermission`, `Test-CPermission`, and `Get-CPermission` all take an `ApplyTo` parameter, which is a
    `CContainerInheritanceFlags` enumeration value. This enumeration is then converted to the appropriate
    `System.InheritanceFlags` and `System.PropagationFlags` values for
    getting/granting/testing permissions. If you prefer to speak in terms of `InheritanceFlags` and `PropagationFlags`,
    use this function to convert them to a `CContainerInheritanceFlags` value.

    If your combination doesn't result in a valid combination, `$null` is returned.

    For detailed description of inheritance and propagation flags, see the help for `Grant-CPermission`.

    .OUTPUTS
    CContainerInheritanceFlags.

    .LINK
    Grant-CPermission

    .LINK
    Test-CPermission

    .EXAMPLE
    ConvertTo-CContainerInheritanceFlags -InheritanceFlags 'ContainerInherit' -PropagationFlags 'None'

    Demonstrates how to convert `InheritanceFlags` and `PropagationFlags` enumeration values into a
    `CContainerInheritanceFlags`. In this case, `[CContainerInheritanceFlags]::ContainerAndSubContainers`
    is returned.
    #>
    [CmdletBinding()]
    [OutputType([CContainerInheritanceFlags])]
    param(
        # The inheritance flags to convert.
        [Parameter(Mandatory, Position=0)]
        [InheritanceFlags] $InheritanceFlags,

        # The propagation flags to convert.
        [Parameter(Mandatory, Position=1)]
        [PropagationFlags] $PropagationFlags
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $propFlagsNone = $PropagationFlags -eq [PropagationFlags]::None
    $propFlagsInheritOnly = $PropagationFlags -eq [PropagationFlags]::InheritOnly
    $propFlagsInheritOnlyNoPropagate =
        $PropagationFlags -eq ([PropagationFlags]::InheritOnly -bor [PropagationFlags]::NoPropagateInherit)
    $propFlagsNoPropagate = $PropagationFlags -eq [PropagationFlags]::NoPropagateInherit

    if( $InheritanceFlags -eq [InheritanceFlags]::None )
    {
        return [CContainerInheritanceFlags]::Container
    }
    elseif( $InheritanceFlags -eq [InheritanceFlags]::ContainerInherit )
    {
        if( $propFlagsInheritOnly )
        {
            return [CContainerInheritanceFlags]::SubContainers
        }
        elseif( $propFlagsInheritOnlyNoPropagate )
        {
            return [CContainerInheritanceFlags]::ChildContainers
        }
        elseif( $propFlagsNone )
        {
            return [CContainerInheritanceFlags]::ContainerAndSubContainers
        }
        elseif( $propFlagsNoPropagate )
        {
            return [CContainerInheritanceFlags]::ContainerAndChildContainers
        }
    }
    elseif( $InheritanceFlags -eq [InheritanceFlags]::ObjectInherit )
    {
        if( $propFlagsInheritOnly )
        {
            return [CContainerInheritanceFlags]::Leaves
        }
        elseif( $propFlagsInheritOnlyNoPropagate )
        {
            return [CContainerInheritanceFlags]::ChildLeaves
        }
        elseif( $propFlagsNone )
        {
            return [CContainerInheritanceFlags]::ContainerAndLeaves
        }
        elseif( $propFlagsNoPropagate )
        {
            return [CContainerInheritanceFlags]::ContainerAndChildLeaves
        }
    }
    elseif( $InheritanceFlags -eq ([InheritanceFlags]::ContainerInherit -bor [InheritanceFlags]::ObjectInherit ) )
    {
        if( $propFlagsInheritOnly )
        {
            return [CContainerInheritanceFlags]::SubContainersAndLeaves
        }
        elseif( $propFlagsInheritOnlyNoPropagate )
        {
            return [CContainerInheritanceFlags]::ChildContainersAndChildLeaves
        }
        elseif( $propFlagsNone )
        {
            return [CContainerInheritanceFlags]::ContainerAndSubContainersAndLeaves
        }
        elseif( $propFlagsNoPropagate )
        {
            return [CContainerInheritanceFlags]::ContainerAndChildContainersAndChildLeaves
        }
    }
}

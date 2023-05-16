
function ConvertTo-CPropagationFlag
{
    <#
    .SYNOPSIS
    Converts a `CContainerInheritanceFlags` value to a `System.Security.AccessControl.PropagationFlags`
    value.

    .DESCRIPTION
    The `CContainerInheritanceFlags` enumeration encapsulates oth
    `System.Security.AccessControl.PropagationFlags` and `System.Security.AccessControl.InheritanceFlags`.  Make sure
    you also call `ConvertTo-InheritancewFlags` to get the inheritance value.

    .OUTPUTS
    System.Security.AccessControl.PropagationFlags.

    .LINK
    ConvertTo-CInheritanceFlag

    .EXAMPLE
    ConvertTo-CPropagationFlag -ContainerInheritanceFlag ContainerAndSubContainersAndLeaves

    Returns `PropagationFlags.None`.
    #>
    [CmdletBinding()]
    param(
        # The value to convert to a `[System.Security.AccessControl.PropagationFlags]` value.
        [Parameter(Mandatory)]
        [CContainerInheritanceFlags] $ContainerInheritanceFlag
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $Flags = [PropagationFlags]
    $map = @{
        'Container' =                                  $Flags::None;
        'SubContainers' =                              $Flags::InheritOnly;
        'Leaves' =                                     $Flags::InheritOnly;
        'ChildContainers' =                           ($Flags::InheritOnly -bor $Flags::NoPropagateInherit);
        'ChildLeaves' =                               ($Flags::InheritOnly -bor $Flags::NoPropagateInherit);
        'ContainerAndSubContainers' =                  $Flags::None;
        'ContainerAndLeaves' =                         $Flags::None;
        'SubContainersAndLeaves' =                     $Flags::InheritOnly;
        'ContainerAndChildContainers' =                $Flags::NoPropagateInherit;
        'ContainerAndChildLeaves' =                    $Flags::NoPropagateInherit;
        'ContainerAndChildContainersAndChildLeaves' =  $Flags::NoPropagateInherit;
        'ContainerAndSubContainersAndLeaves' =         $Flags::None;
        'ChildContainersAndChildLeaves' =             ($Flags::InheritOnly -bor $Flags::NoPropagateInherit);
    }
    $key = $ContainerInheritanceFlag.ToString()
    if ($map.ContainsKey($key))
    {
        return $map[$key]
    }

    $msg = "Failed to convert container inheritance flag value ""${ContainerInheritanceFlag}"" to " +
           '[System.Security.AccessControlPropagationFlags] because that value does not exist.'
    Write-Error $msg -ErrorAction $ErrorActionPreference
}

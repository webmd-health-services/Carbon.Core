

function ConvertTo-CInheritanceFlag
{
    <#
    .SYNOPSIS
    Converts a `CContainerInheritanceFlags` value to a `System.Security.AccessControl.InheritanceFlags`
    value.

    .DESCRIPTION
    The `CContainerInheritanceFlags` enumeration encapsulates both
    `System.Security.AccessControl.InheritanceFlags` and `System.Security.AccessControl.PropagationFlags`.  Make sure
    you also call `ConvertTo-CPropagationFlag` to get the propagation value.

    .OUTPUTS
    System.Security.AccessControl.InheritanceFlags.

    .LINK
    ConvertTo-CPropagationFlag

    .EXAMPLE
    ConvertTo-CInheritanceFlag -ContainerInheritanceFlag ContainerAndSubContainersAndLeaves

    Returns `InheritanceFlags.ContainerInherit|InheritanceFlags.ObjectInherit`.
    #>
    [CmdletBinding()]
    param(
        # The value to convert to an `InheritanceFlags` value.
        [Parameter(Mandatory)]
        [CContainerInheritanceFlags] $ContainerInheritanceFlag
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $Flags = [InheritanceFlags]
    $map = @{
        'Container' =                                  $Flags::None;
        'SubContainers' =                              $Flags::ContainerInherit;
        'Leaves' =                                     $Flags::ObjectInherit;
        'ChildContainers' =                            $Flags::ContainerInherit;
        'ChildLeaves' =                                $Flags::ObjectInherit;
        'ContainerAndSubContainers' =                  $Flags::ContainerInherit;
        'ContainerAndLeaves' =                         $Flags::ObjectInherit;
        'SubContainersAndLeaves' =                    ($Flags::ContainerInherit -bor $Flags::ObjectInherit);
        'ContainerAndChildContainers' =                $Flags::ContainerInherit;
        'ContainerAndChildLeaves' =                    $Flags::ObjectInherit;
        'ContainerAndChildContainersAndChildLeaves' = ($Flags::ContainerInherit -bor $Flags::ObjectInherit);
        'ContainerAndSubContainersAndLeaves' =        ($Flags::ContainerInherit -bor $Flags::ObjectInherit);
        'ChildContainersAndChildLeaves' =             ($Flags::ContainerInherit -bor $Flags::ObjectInherit);
    }
    $key = $ContainerInheritanceFlag.ToString()
    if ($map.ContainsKey( $key))
    {
        return $map[$key]
    }

    $msg = "Failed to convert container inheritance flags value ""${ContainerInheritanceFlag}}"" because it is an " +
           'unknown value.'
    Write-Error $msg -ErrorAction $ErrorActionPreference
}

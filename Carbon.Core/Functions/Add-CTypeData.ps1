function Add-CTypeData
{
    <#
    .SYNOPSIS
    Adds type data to a type only if the type data doesn't already exist.

    .DESCRIPTION
    The `Add-CTypeData` function uses PowerShell's `Update-TypeData` cmdlet to add type data to a type, but only if the
    given type data doesn't already exist. Pass the type to the `Type` parameter or the type name to the `TypeName`
    parameter, the new type data member type to the `MemberType` parameter (e.g. `AliasProperty`, `NoteProperty`, 
    `ScriptProperty`, or `ScriptMethod`), the member name to the `MemberName` parameter, and the member's
    value/implementation to the `Value` parameter.

    Note that the `Type` parameter should be the bare name of the type, e.g. `Diagnostics.Process`, *without* square
    brackets.

    If the type already has an equivalent member with the name given by the `MemberName` parameter, nothing happens, and
    the function returns.

    .EXAMPLE
    Add-CTypeData -Type Diagnostics.Process -MemberType ScriptProperty  -MemberName 'ParentID' -Value $scriptBlock

    Demonstrates how to create a script property on a type. In this example, the `System.Diagnostics.Process` type will
    be given a `ParentID` property that runs the code in the script block in the `$scriptBlock` variable.

    .EXAMPLE
    Add-CTypeData -Type Diagnostics.Process -MemberType ScriptMethod  -MemberName 'GetParentID()' -Value $scriptBlock

    Demonstrates how to create a script method on a type. In this example, the `System.Diagnostics.Process` type will
    be given a `GetParentID()` method that runs the code in the script block in the `$scriptBlock` variable.

    .EXAMPLE
    Add-CTypeData -Type Diagnostics.Process -MemberType AliasProperty  -MemberName 'ProcessId' -Value 'Id'

    Demonstrates how to create an alias script property on a type. In this example, the `System.Diagnostics.Process`
    type will be given a `ProcessId` property that is an alias to the 'Id' property.

    .EXAMPLE
    Add-CTypeData -Type Diagnostics.Process -MemberType NoteProperty  -MemberName 'ParentID' -Value $parentPid

    Demonstrates how to create a ntoe property on a type. In this example, the `System.Diagnostics.Process` type will
    be given a `ParentID` property that returns the value in the `$parentPid` variable.
    #>
    [CmdletBinding()]
    param(
        # The type on which to add the type data. This should be the bare type name, e.g. Diagnostics.Process, *not*
        # the type surrounded by square brackets, e.g. `[Diagnostics.Process]`.
        [Parameter(Mandatory, ParameterSetName='ByType')]
        [Type] $Type,

        # The name of the type on which to add the type data.
        [Parameter(Mandatory, ParameterSetName='ByTypeName')]
        [String] $TypeName,

        # The member type of the new type data. Only `AliasProperty`, `NoteProperty`, `ScriptProperty`, `ScriptMethod`
        # are supported.
        [Parameter(Mandatory)]
        [ValidateSet('AliasProperty', 'NoteProperty', 'ScriptProperty', 'ScriptMethod')]
        [Management.Automation.PSMemberTypes] $MemberType,

        # The type data's member name.
        [Parameter(Mandatory)]
        [String] $MemberName,

        # The value for the member. If `MemberName` is:
        #
        # * `AliasProperty`, this should be the name of the target property.
        # * `NoteProperty`, the literal value of the property.
        # * `ScriptProperty`, a script block that return's the property value.
        # * `ScriptMethod`, a script block that implements the method logic.
        [Parameter(Mandatory)]
        [Object] $Value
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $memberTypeMsg = '{0,-14}' -f $MemberType

    if( -not $TypeName )
    {
        $TypeName = $Type.FullName
    }

    if( $Type )
    {
        if( $MemberType -like '*Property' )
        {
            if( ($Type.GetProperties() | Where-Object Name -EQ $MemberName) )
            {
                Write-Debug ("Type        $($memberTypeMsg)  [$($TypeName)]  $($MemberName)")
                return
            }
        }
        elseif( $MemberType -like '*Method')
        {
            if( ($Type.GetMethods() | Where-Object Name -EQ $MemberName) )
            {
                Write-Debug ("Type        $($memberTypeMsg)  [$($TypeName)]  $($MemberName)")
                return
            }
        }
    }

    $typeData = Get-TypeData -TypeName $TypeName
    if( $typeData -and $typeData.Members.ContainsKey($MemberName) )
    {
        Write-Debug ("TypeData    $($memberTypeMsg)  [$($TypeName)]  $($MemberName)")
        return
    }

    Write-Debug ("TypeData  + $($memberTypeMsg)  [$($TypeName)]  $($MemberName)")
    Update-TypeData -TypeName $TypeName -MemberType $MemberType -MemberName $MemberName -Value $Value
}


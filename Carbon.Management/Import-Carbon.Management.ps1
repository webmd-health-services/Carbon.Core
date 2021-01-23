<#
.SYNOPSIS
Imports the Carbon.Management module into the current session.

.DESCRIPTION
The `Import-Carbon.Management function imports the Carbon.Management module into the current session. If the module is already loaded, it is removed, then reloaded.

.EXAMPLE
.\Import-Carbon.Management.ps1

Demonstrates how to use this script to import the Carbon.Management module  into the current PowerShell session.
#>
[CmdletBinding()]
param(
)

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

$originalVerbosePref = $Global:VerbosePreference
$originalWhatIfPref = $Global:WhatIfPreference

$Global:VerbosePreference = $VerbosePreference = 'SilentlyContinue'
$Global:WhatIfPreference = $WhatIfPreference = $false

try
{
    if( (Get-Module -Name 'Carbon.Management') )
    {
        Remove-Module -Name 'Carbon.Management' -Force
    }

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Carbon.Management.psd1' -Resolve)
}
finally
{
    $Global:VerbosePreference = $originalVerbosePref
    $Global:WhatIfPreference = $originalWhatIfPref
}

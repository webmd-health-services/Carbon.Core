# Copyright Aaron Jensen and WebMD Health Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

<#
.SYNOPSIS
OBSOLETE. Use `Import-Module` instead.

.DESCRIPTION
OBSOLETE. Use `Import-Module` instead.

.EXAMPLE
OBSOLETE. Use `Import-Module` instead.
#>
[CmdletBinding()]
param(
)

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

'This script is OBSOLETE and will be removed in the next major version of Carbon.Core. Use Import-Module instead.' |
    Write-Warning

$originalVerbosePref = $Global:VerbosePreference
$originalWhatIfPref = $Global:WhatIfPreference

$Global:VerbosePreference = $VerbosePreference = 'SilentlyContinue'
$Global:WhatIfPreference = $WhatIfPreference = $false

try
{
    if( (Get-Module -Name 'Carbon.Core') )
    {
        Remove-Module -Name 'Carbon.Core' -Force
    }

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Carbon.Core.psd1' -Resolve)
}
finally
{
    $Global:VerbosePreference = $originalVerbosePref
    $Global:WhatIfPreference = $originalWhatIfPref
}

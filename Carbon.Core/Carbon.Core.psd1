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

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'Carbon.Core.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '20DA9F42-23C4-4917-8597-DCFD7EE4AD00'

    # Author of this module
    Author = 'WebMD Health Services'

    # Company or vendor of this module
    CompanyName = 'WebMD Health Services'

    # If you want to support .NET Core, add 'Core' to this list.
    CompatiblePSEditions = @( 'Desktop', 'Core' )

    # Copyright statement for this module
    Copyright = '(c) 2021 Aaron Jensen and WebMD Health Services.'

    # Description of the functionality provided by this module
    Description = 'Functions that make doing things in PowerShell a little easier. We think these should be part of PowerShell itself. Core functions that are used by other Carbon modules.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @( )

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @( )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module. Only list public function here.
    FunctionsToExport = @(
        'ConvertTo-CBase64',
        'Get-CPowerShellPath',
        'Invoke-CPowerShell',
        'Start-CPowerShellProcess',
        'Test-COperatingSystem',
        'Test-CPowerShell'
    )

    # Cmdlets to export from this module. By default, you get a script module, so there are no cmdlets.
    # CmdletsToExport = @()

    # Variables to export from this module. Don't export variables except in RARE instances.
    VariablesToExport = @()

    # Aliases to export from this module. Don't create/export aliases. It can pollute your user's sessions.
    AliasesToExport = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                'Carbon', 'Desktop', 'Core', 'encoding', 'convert', 'convertto', 'text', 'base64', 'invoke', 'os',
                'operating-system', 'architecture', 'powershell', 'pwsh', 'runas', 'credential', 'x86', 'x64',
                'windows', 'linux', 'macos' )

            # A URL to the license for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # A URL to the main website for this project.
            ProjectUri = 'https://whsbitbucket.webmd.net/projects/POWERSHELL/repos/Carbon.Core/browse'

            # A URL to an icon representing this module.
            # IconUri = ''

            Prerelease = ''

            # ReleaseNotes of this module
            ReleaseNotes = @'
# Upgrade Instructions

We're breaking up Carbon into smaller and more targeted modules. Hopefully, this will help maintenance, and make it
easier to use Carbon across many versions and editions of PowerShell. This module will be the place where core functions
used by other Carbon modules will be put.

If you're upgrading from Carbon to this module, you should do the following:

* Replace usages of `Test-COSIs64Bit` with `Test-COperatingSystem -Is64Bit`.
* Replace usages of `Test-COSIs32Bit` with `Test-COperatingSystem -Is32Bit`.
* Replace usages of `Test-CPowerShellIs32Bit` with `Test-CPowerShell -Is32Bit`.
* Replace usages of `Test-CPowerShellIs64Bit` with `Test-CPowerShell -Is64Bit`.
* Rename usages of the `ConvertTo-CBase64` function's `Value` parameter to `InputObject`, or pipe the value to the 
function instead.

We made a lot of changes to the `Invoke-CPowerShell` function:

* The `Invoke-CPowerShell` function no longer allows you to pass script blocks. Instead, convert your script block to
a string, and pass that string to the `Command` parameter. This will base64 encode the command and pass it to 
PowerShell's -EncodedCommand property.
* The `Invoke-CPowerShell` function no longer has `FilePath`, `OutputFormat`, `ExecutionPolicy`, `NonInteractive`, 
or `Runtime` parameters. Instead, pass these as arguments to the `ArgumentList` parameter, e.g. 
`-ArgumentList @('-NonInteractive', '-ExecutionPolicy', 'Bypasss'). You are now responsible for passing all PowerShell
arguments via the `ArgumentList` parameter.
* The `Invoke-CPowerShell` function no longer supports running PowerShell 2 under .NET 4.
* Remove the `-Encode` switch. `Invoke-CPowerShell` now always base64 encodes the value of the `Command` parameter.
* The `Invoke-CPowerShell` function only accepts strings to the `-Command` parameter. Check all usages to ensure you're
passing a string.
* The `Invoke-CPowerShell` function now returns output when running PowerShell as a different user. You may see more
output in your scripts.


# Changes Since Carbon 2.9.4

* Migrated `Invoke-CPowerShell` and `ConvertTo-CBase64` from Carbon.
* `ConvertTo-CBase64` now converts chars, ints (signed and unsigned, 16, 32, and 64-bit sizes), floats, and doubles to 
base64. You can now also pipe an array of bytes or chars and it will collect each item in the array and encode them at
as one unit.
* Renamed the `ConvertTo-CBase64` function's `Value` parameter to `InputObject`.
* Created `Test-COperatingSystem` function that can test if the current OS is 32-bit, 62-bit, Windows, Linux, and/or 
macOS. This function was adapted from and replaces's Carbon's `Test-COSIs64Bit` and `Test-COSIs32Bit`.
* Created `Test-CPowerShell` function that can test if the current PowerShell instance is 32-bit, 64-bit, Core edition,
or Desktop edition. It treats  versions of PowerShell that don't specify a version as "Desktop". This function was 
adapted from and replaces Carbon's `Test-CPowerShellIs32Bit` and `Test-CPowerShellIs64Bit` functions.
* `Invoke-CPowerShell` now works on Linux and macOS. On Windows, it will start a new PowerShell process using the same
edition. If you want to use a custom version of PowerShell, pass the path to the PowerShell executable to use to the
new `Path` parameter.

# Known Issues
* There is a bug in PowerShell Core on Linux/macOS that fails when running `Start-Job` with a custom credential. The
`Invoke-CPowerShell` function will fail when run on Linux/MacOS using a custom credential. See 
https://github.com/PowerShell/PowerShell/issues/7172 for more information.
'@
        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

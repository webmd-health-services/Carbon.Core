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
    ModuleVersion = '1.1.0'

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
        'Add-CTypeData',
        'ConvertTo-CBase64',
        'Get-CPowerShellPath',
        'Invoke-CPowerShell',
        'Start-CPowerShellProcess',
        'Test-COperatingSystem',
        'Test-CPowerShell',
        'Test-CTypeDataMember'
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
                'operating', 'system', 'architecture', 'powershell', 'pwsh', 'runas', 'credential', 'x86', 'x64',
                'windows', 'linux', 'macos', 'type', 'data', 'update-typedata', 'member', 'add-member' )

            # A URL to the license for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # A URL to the main website for this project.
            ProjectUri = 'https://whsbitbucket.webmd.net/projects/POWERSHELL/repos/Carbon.Core/browse'

            # A URL to an icon representing this module.
            # IconUri = ''

            Prerelease = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/webmd-health-services/Carbon.Core/blob/main/CHANGELOG.md'
        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

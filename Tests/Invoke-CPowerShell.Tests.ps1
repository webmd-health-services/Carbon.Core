
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:testCredential = Get-TestUser -Name 'CIPowerShell'


    function Init
    {
        $Global:Error.Clear()
        $script:output = $null
    }

    function ThenOutputIs
    {
        param(
            [Object]$InputObject
        )

        $output | Should -Be $InputObject
    }

    function WhenRunningPowerShell
    {
        param(
            [String[]]$WithArgs,

            [String]$Command,

            [switch]$As32Bit,

            [pscredential]$As
        )

        # Make tests a little faster and reduce test code clutter.
        $WithArgs = & {
            '-NoProfile'
            '-NonInteractive'
            if( $WithArgs )
            {
                $WithArgs
            }
        }

        $conditionalParams = @{}
        if( $Command )
        {
            $conditionalParams['Command'] = $Command
        }

        if( $As32Bit )
        {
            $conditionalParams['x86'] = $true
        }

        if( $As )
        {
            $conditionalParams['Credential'] = $As
        }

        $script:output = Invoke-CPowerShell -ArgumentList $WithArgs @conditionalParams
    }

    function Assert-EnvVarCleanedUp
    {
        It 'should clean up environment' {
            ([Environment]::GetEnvironmentVariable('COMPLUS_ApplicationMigrationRuntimeActivationConfigPath')) | Should -BeNullOrEmpty
        }
    }
}

Describe 'Invoke-CPowerShell.when requesting a 32-bit PowerShell' {
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Core')
    if( (Test-COperatingSystem -IsWindows) -and (Test-CPowerShell -IsDesktop) )
    {
        Context 'On Windows' {
            It 'should run under x86' {
                Init
                WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"' -As32Bit
                ThenOutputIs $false.ToString()
            }
        }
    }
    else
    {
        Context 'On PowerShell Core' {
            It 'should run under same architecture as this test' {
                Init
                WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"' -As32Bit
                ThenOutputIs ([Environment]::Is64BitProcess)
            }
        }
    }
}

if( (Test-COperatingSystem -IsWindows) -and (Test-CPowerShell -IsDesktop) )
{
    Describe 'Invoke-CPowerShell.when running on Windows' {
        if( (Test-COperatingSystem -Is64Bit) )
        {
            Context 'x64' {
                Context 'from x86 PowerShell' {
                    It 'should run x64 PowerShell by default' {
                        Init
                        if( (Test-CPowerShell -Is32Bit) )
                        {
                            WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"'
                        }
                        else
                        {
                            $command = @"
Import-Module "$(Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Core' -Resolve)"
if( -not (Test-CPowerShell -Is32Bit) )
{
    throw 'Not in 32-bit PowerShell!'
}
Invoke-CPowerShell -ArgumentList '-NoProfile', '-NonInteractive', '[Environment]::Is64BitProcess'
"@
                            WhenRunningPowerShell -Command $command -As32Bit
                        }
                        ThenOutputIs $true
                    }
                }
                Context 'from x64 PowerShell' {
                    It 'should run x64 PowerShell' {
                        Init
                        if( (Test-CPowerShell -Is64Bit) )
                        {
                            WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"'
                        }
                        else
                        {
                            $command = @"
Import-Module "$(Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Core' -Resolve)"
if( -not (Test-CPowerShell -Is64Bit) )
{
    throw 'Not in 64-bit PowerShell!'
}
return [Environment]::Is64BitPowerShell
"@
                            WhenRunningPowerShell -Command $command
                        }
                        ThenOutputIs $true
                    }
                }
            }
        }
    }
}

# On macOS/Linux, there's a bug in Start-Job that prevents it from launching as another user.
# https://github.com/PowerShell/PowerShell/issues/7172
$skip = @{}
if( -not (Test-COperatingSystem -IsWindows) )
{
    $skip['Skip'] = $true
}

Describe 'Invoke-CPowerShell.when running a script as another user' {
    It 'should run PowerShell as that user' @skip {
        Init
        WhenRunningPowerShell -WithArgs '-Command', '[Environment]::UserName' -As $script:testCredential
        ThenOutputIs $script:testCredential.UserName
    }
}

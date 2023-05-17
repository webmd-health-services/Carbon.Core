
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $testCredential = Get-TestUser -Name 'CIPowerShell'

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
    BeforeEach {
        $Global:Error.Clear()
        $script:output = $null
    }

    if (-not (Test-Path -Path 'variable:IsWindows'))
    {
        Set-Variable -Name 'IsWindows' -Value $true -Scope Local
        Set-Variable -Name 'IsLinux' -Value $false -Scope Local
        Set-Variable -Name 'IsMacOS' -Value $false -Scope Local
    }

    $IsDesktop = $PSVersionTable['PSEdition'] -eq 'Desktop'
    $IsCore = -not $IsDesktop

    Context 'On PowerShell Core' -Skip:(-not $IsCore) {
        It 'should run under same architecture as this test' {
            WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"' -As32Bit
            ThenOutputIs ([Environment]::Is64BitProcess)
        }
    }

    Context 'On Windows' -Skip:(-not $IsWindows) {
        It 'runs under x86' {
            WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::Is64BitProcess"' -As32Bit
            ThenOutputIs $false.ToString()
        }
        Context 'x64' -Skip:(-not [Environment]::Is64BitOperatingSystem) {
            Context 'from x86 PowerShell' {
                It 'runs x64 PowerShell by default' {
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

    # On macOS/Linux, there's a bug in Start-Job that prevents it from launching as another user.
    # https://github.com/PowerShell/PowerShell/issues/7172
    It 'run PowerShell as another user' -Skip:(-not $IsWindows) {
        WhenRunningPowerShell -WithArgs '-Command', '"[Environment]::UserName"' -As $testCredential
        ThenOutputIs $testCredential.UserName
    }
}


#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $winDir = [Environment]::GetFolderPath('Windows')
    $script:system32Path = Join-Path -Path $windir -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $script:sysnativePath = Join-Path -Path $windir -ChildPath 'sysnative\WindowsPowerShell\v1.0\powershell.exe'
    $script:sysWowPath = Join-Path -Path $windir -ChildPath 'SysWOW64\WindowsPowerShell\v1.0\powershell.exe'

    function GivenOSIs32Bit
    {
        Mock -CommandName 'Test-COperatingSystem' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is32Bit } `
             -MockWith { $true }
        Mock -CommandName 'Test-COperatingSystem' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is64Bit } `
             -MockWith { $false }
    }

    function GivenOSIs64Bit
    {
        Mock -CommandName 'Test-COperatingSystem' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is64Bit } `
             -MockWith { $true }
        Mock -CommandName 'Test-COperatingSystem' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is32Bit } `
             -MockWith { $false }
    }

    function GivenPowerShellIs32Bit
    {
        Mock -CommandName 'Test-CPowerShell' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is32Bit } `
             -MockWith { $true }
        Mock -CommandName 'Test-CPowerShell' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is64Bit } `
             -MockWith { $false }
        Mock -CommandName 'Get-Variable' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Name -eq 'PSHOME' } `
             -MockWith { return ($script:sysWowPath | Split-Path -Parent) }
    }

    function GivenPowerShellIs64Bit
    {
        Mock -CommandName 'Test-CPowerShell' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is64Bit } `
             -MockWith { $true }
        Mock -CommandName 'Test-CPowerShell' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Is32Bit } `
             -MockWith { $false }
        Mock -CommandName 'Get-Variable' `
             -ModuleName 'Carbon.Core' `
             -ParameterFilter { $Name -eq 'PSHOME' } `
             -MockWith { return ($script:system32Path | Split-Path -Parent) }
    }
}

Describe 'Get-CPowerShellPath' {
    if (-not (Test-Path -Path 'variable:IsWindows'))
    {
        Set-Variable -Name 'IsWindows' -Value $true
        Set-Variable -Name 'IsLinux' -Value $false
        Set-Variable -Name 'IsMacOS' -Value $false
    }

    $isDesktop = $PSVersionTable['PSEdition'] -eq 'Desktop'
    $isCore = -not $isDesktop

    Context 'Windows' -Skip:($IsLinux -or $IsMacOS) {
        Context 'Desktop' -Skip:$isCore {
            Context 'OS x86' {
                It 'returns path in system32' {
                    GivenOSIs32Bit
                    Get-CPowerShellPath | Should -Be $system32Path
                }
            }

            Context 'OS x64' {
                Context 'PowerShell x64' {
                    Context 'requesting default PowerShell' {
                        It 'returns path in system32' {
                            GivenOSIs64Bit
                            GivenPowerShellIs64Bit
                            Get-CPowerShellPath | Should -Be $system32Path
                        }
                    }
                    Context 'requesting x86 PowerShell' {
                        It 'returns path in SysWOW64' {
                            GivenOSIs64Bit
                            GivenPowerShellIs64Bit
                            Get-CPowerShellPath -x86 | Should -Be $sysWowPath
                        }
                    }
                }

                Context 'PowerShell x86' {
                    Context 'requesting default PowerShell' {
                        It 'returns path in sysnative' {
                            GivenOSIs64Bit
                            GivenPowerShellIs32Bit
                            Get-CPowerShellPath | Should -Be $sysnativePath
                        }
                    }
                    Context 'requesting x86 PowerShell' {
                        It 'returns path in System32' {
                            GivenOSIs64Bit
                            GivenPowerShellIs32Bit
                            Get-CPowerShellPath -x86 | Should -Be $system32Path
                        }
                    }
                }
            }
        }

        $psIsx64 = [Environment]::Is64BitProcess
        $psIsx86 = -not $psIsx64

        Context 'Core' -Skip:$isDesktop {
            It 'should return pwsh.exe from PSHOME' -Skip:$psIsx86 {
                Get-CPowerShellPath | Should -Be (Join-Path -Path $PSHOME -ChildPath 'pwsh.exe')
            }
        }
    }

    Context 'Linux/macOS' -Skip:$IsWindows {
        It 'should return pwsh in PSHOME' {
            Get-CPowerShellPath | Should -Be (Join-Path -Path $PSHOME -ChildPath 'pwsh')
        }
    }
}
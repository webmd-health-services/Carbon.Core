
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function GivenOSIs32Bit
{
    Mock -CommandName 'Test-COperatingSystem' `
         -ModuleName 'Carbon.Core' `
         -ParameterFilter { $Is32Bit } `
         -MockWith { $true }
}

function GivenOSIs64Bit
{
    Mock -CommandName 'Test-COperatingSystem' `
         -ModuleName 'Carbon.Core' `
         -ParameterFilter { $Is64Bit } `
         -MockWith { $true }
}

function GivenPowerShellIs32Bit
{
    Mock -CommandName 'Test-CPowerShell' `
         -ModuleName 'Carbon.Core' `
         -ParameterFilter { $Is32Bit } `
         -MockWith { $true }
}

function GivenPowerShellIs64Bit
{
    Mock -CommandName 'Test-CPowerShell' `
         -ModuleName 'Carbon.Core' `
         -ParameterFilter { $Is64Bit } `
         -MockWith { $true }
}

Describe 'Get-CPowerShellPath' {
    if( (Test-COperatingSystem -IsWindows) )
    {
        Context 'Windows' {
            if( (Test-CPowerShell -IsDesktop) )
            {
                Context 'PowerShell Desktop' {
                    $system32Path = Join-Path -Path $env:windir -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe'
                    $sysnativePath = Join-Path -Path $env:windir -ChildPath 'sysnative\WindowsPowerShell\v1.0\powershell.exe'
                    $sysWowPath = Join-Path -Path $env:windir -ChildPath 'SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
                    Context 'OS x86' {
                        GivenOSIs32Bit
                        It 'should return path in System32' {
                            Get-CPowerShellPath | Should -Be $system32Path
                        }
                    }

                    Context 'OS x64' {
                        GivenOSIs64Bit
                        Context 'PowerShell x64' {
                            GivenPowerShellIs64Bit
                            Context 'requesting default PowerShell' {
                                It 'should return path in System32' {
                                    Get-CPowerShellPath | Should -Be $system32Path
                                }
                            }
                            Context 'requesting x86 PowerShell' {
                                It 'should return SysWOW64 path' {
                                    Get-CPowerShellPath -x86 | Should -Be $sysWowPath
                                }
                            }
                        }
                        Context 'PowerShell x86' {
                            GivenPowerShellIs32Bit
                            Context 'requesting default PowerShell' {
                                It 'should return path in sysnative' {
                                    Get-CPowerShellPath | Should -Be $sysnativePath
                                }
                            }
                            Context 'requesting x86 PowerShell' {
                                It 'should return System32 path' {
                                    Get-CPowerShellPath -x86 | Should -Be $system32Path
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                Context 'PowerShell Core' {
                    It 'should return pwsh.exe from PSHOME' {
                        Get-CPowerShellPath | Should -Be (Join-Path -Path $PSHOME -ChildPath 'pwsh.exe')
                    }
                }
            }
        }
    }
    else
    {
        Context 'Linux/macOS' {
            It 'should return pwsh in PSHOME' {
                Get-CPowerShellPath | Should -Be (Join-Path -Path $PSHOME -ChildPath 'pwsh')
            }
        }
    }
}
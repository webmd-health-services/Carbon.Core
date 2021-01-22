
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Test-CPowerShell' {
    if( [Environment]::Is64BitProcess )
    {
        Context 'x64' {
            Context 'when testing if PowerShell is x64' {
                It 'should return $true' {
                    Test-CPowerShell -Is64Bit | Should -BeTrue
                }
            }
            Context 'when testing if PowerShell is x86' {
                It 'should return $false' {
                    Test-CPowerShell -Is32Bit | Should -BeFalse
                }
            }
        }
    }
    else 
    {
        Context 'x86' {
            Context 'when testing if PowerShell is x64' {
                It 'should return $false' {
                    Test-CPowerShell -Is64Bit | Should -BeFalse
                }
            }
            Context 'when testing if PowerShell is x86' {
                It 'should return $true' {
                    Test-CPowerShell -Is32Bit | Should -BeTrue
                }
            }
        }
    }

    if( -not $PSVersionTable['PSEdition'] -or $PSVersionTable['PSEdition'] -eq 'Desktop' )
    {
        Context 'Desktop' {
            Context 'when testing if PowerShell is Desktop edition' {
                It 'should return $true' {
                    Test-CPowerShell -IsDesktop | Should -BeTrue
                }
            }
            Context 'when testing if PowerShell is Core edition' {
                It 'should return $false' {
                    Test-CPowerShell -IsCore | Should -BeFalse
                }
            }
        }
    }
    else
    {
        Context 'Core' {
            Context 'when testing if PowerShell is Desktop edition' {
                It 'should return $false' {
                    Test-CPowerShell -IsDesktop | Should -BeFalse
                }
            }
            Context 'when testing if PowerShell is Core edition' {
                It 'should return $true' {
                    Test-CPowerShell -IsCore | Should -BeTrue
                }
            }
        }

    }
}
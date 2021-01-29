
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$onWindows = $true
$onLinux = $false
$onMac = $false

if( (Test-Path -Path 'variable:IsWindows') )
{
    $onWindows = $IsWindows
    $onLinux = $IsLinux
    $onMac = $IsMacOS
}

Describe 'Test-COperatingSystem' {
    if( [Environment]::Is64BitOperatingSystem )
    {
        Context 'OS x64' {
            Context 'when testing if OS is x64' {
                It 'should return $true' {
                    Test-COperatingSystem -Is64Bit | Should -BeTrue
                }
            }
            Context 'when testing if OS is x86' {
                It 'should return $false' {
                    Test-COperatingSystem -Is32Bit | Should -BeFalse
                }
            }
        }
    }
    else
    {
        Context 'OS x86' {
            Context 'when testing if OS is x64' {
                It 'should return $false' {
                    Test-COperatingSystem -Is64Bit | Should -BeFalse
                }
            }
            Context 'when testing if OS is x86' {
                It 'should return $true' {
                    Test-COperatingSystem -Is32Bit | Should -BeTrue
                }
            }
        }
    }

    if( $onWindows )
    {
        Context 'Windows' {
            Context 'when testing if OS is Linux' {
                It 'should return $false' {
                    Test-COperatingSystem -IsLinux | Should -BeFalse
                }
            }
            Context 'when testing if OS is macOS' {
                It 'should return $false' {
                    Test-COperatingSystem -IsMacOS | Should -BeFalse
                }
            }
            Context 'when testing if OS is Windows' {
                It 'should return $true' {
                    Test-COperatingSystem -IsWindows | Should -BeTrue
                }
            }
        }
    }
    elseif( $onLinux )
    {
        Context 'Linux' {
            Context 'when testing if OS is Linux' {
                It 'should return $true' {
                    Test-COperatingSystem -IsLinux | Should -BeTrue
                }
            }
            Context 'when testing if OS is macOS' {
                It 'should return $false' {
                    Test-COperatingSystem -IsMacOS | Should -BeFalse
                }
            }
            Context 'when testing if OS is Windows' {
                It 'should return $False' {
                    Test-COperatingSystem -IsWindows | Should -BeFalse
                }
            }
        }
    }
    elseif( $onMac )
    {
        Context 'macOS' {
            Context 'when testing if OS is Linux' {
                It 'should return $false' {
                    Test-COperatingSystem -IsLinux | Should -BeFalse
                }
            }
            Context 'when testing if OS is macOS' {
                It 'should return $true' {
                    Test-COperatingSystem -IsMacOS | Should -BeTrue
                }
            }
            Context 'when testing if OS is Windows' {
                It 'should return $false' {
                    Test-COperatingSystem -IsWindows | Should -BeFalse
                }
            }
        }
    }
}
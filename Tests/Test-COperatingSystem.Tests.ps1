
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:wow64Path = [Environment]::GetFolderPath('Windows')
    if ($script:wow64Path)
    {
        $script:wow64Path = Join-Path -Path $script:wow64Path -ChildPath 'SysWOW64'
    }

    Write-Information "Has32Bit  $(Test-COperatingSystem -Has32Bit)" -InformationAction Continue
}

Describe 'Test-COperatingSystem' {
    $onWindows = $true
    $onLinux = $false
    $onMac = $false

    if( (Test-Path -Path 'variable:IsWindows') )
    {
        $onWindows = $IsWindows
        $onLinux = $IsLinux
        $onMac = $IsMacOS
    }

    Context 'OS x64' -Skip:(-not [Environment]::Is64BitOperatingSystem) {
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

    Context 'OS x86' -Skip:([Environment]::Is64BitOperatingSystem) {
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

    Context 'Windows' -Skip:(-not $onWindows) {
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
        It 'detects if Windows-on-Windows 64 is installed' {
            Test-COperatingSystem -Has32Bit | Should -Be (Test-Path -Path $script:wow64Path)
        }
    }

    Context 'Linux' -Skip:(-not $onLinux) {
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
        It 'detects if Windows-on-Windows 64 is installed' {
            Test-COperatingSystem -Has32Bit | Should -BeFalse
        }
    }
    Context 'macOS' -Skip:(-not $onMac) {
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
        It 'detects if Windows-on-Windows 64 is installed' {
            Test-COperatingSystem -Has32Bit | Should -BeFalse
        }
    }
}
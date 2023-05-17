
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

Describe 'Invoke-CPowerShell' {
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

    It 'runs under OS architecture by default' {
        WhenRunningPowerShell -WithArgs '-Command', '[Environment]::Is64BitProcess'
        ThenOutputIs ([Environment]::Is64BitOperatingSystem).ToString()
    }

    It 'runs x86 PowerShell' -Skip:(-not $IsWindows) {
        WhenRunningPowerShell -WithArgs '-Command', '[Environment]::Is64BitProcess' -As32Bit
        ThenOutputIs $false.ToString()
    }

    # On macOS/Linux, there's a bug in Start-Job that prevents it from launching as another user.
    # https://github.com/PowerShell/PowerShell/issues/7172
    It 'run PowerShell as another user' -Skip:(-not $IsWindows) {
        # Allow non-administrator users to run this test.
        $root = Resolve-Path -Path '\' | Select-Object -ExpandProperty 'Path'
        Push-Location -Path $root
        $originalCurDir = [Environment]::CurrentDirectory
        [Environment]::CurrentDirectory = $root
        try
        {
            WhenRunningPowerShell -WithArgs '-Command', '[Environment]::UserName' -As $testCredential
            ThenOutputIs $testCredential.UserName
        }
        finally
        {
            [Environment]::CurrentDirectory = $originalCurDir
            Pop-Location
        }
    }
}

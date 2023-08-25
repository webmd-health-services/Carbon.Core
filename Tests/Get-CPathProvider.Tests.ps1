
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootPath = Resolve-Path -Path '/'
}

Describe 'Get-CPathProvider' {
    It 'should get file system provider' {
        ((Get-CPathProvider -Path $PSScriptRoot).Name) | Should -Be 'FileSystem'
    }

    It 'should get relative path provider' {
        ((Get-CPathProvider -Path '..\').Name) | Should -Be 'FileSystem'
    }

    $registryAvailable = Test-Path -Path 'hklm:'
    It 'should get registry provider' -Skip:(-not $registryAvailable) {
        (Get-CPathProvider -Path 'hklm:\software').Name | Should -Be 'Registry'
    }

    It 'should get relative path provider' -Skip:(-not $registryAvailable) {
        Push-Location 'hklm:\SOFTWARE\Microsoft'
        try
        {
            ((Get-CPathProvider -Path '..\').Name) | Should -Be 'Registry'
        }
        finally
        {
            Pop-Location
        }
    }

    It 'should return Registry for registry path' -Skip:(-not $registryAvailable) {
        Get-CPathProvider -Path (Get-Item -Path 'hkcu:\software').PSPath |
            Select-Object -ExpandProperty 'Name' |
            Should -Be 'Registry'
    }

    It 'should get no provider for bad path' {
        ((Get-CPathProvider -Path (Join-Path -Path $script:rootPath -ChildPath 'I\Do\Not\Exist')).Name) |
            Should -Be 'FileSystem'
    }
}
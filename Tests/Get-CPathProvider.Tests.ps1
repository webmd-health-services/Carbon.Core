
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

}

Describe 'Get-CPathProvider' {
    It 'gets file system provider' {
        ((Get-CPathProvider -Path 'C:\Windows').Name) | Should -Be 'FileSystem'
    }

    It 'gets relative path provider' {
        ((Get-CPathProvider -Path '..\').Name) | Should -Be 'FileSystem'
    }

    It 'gets registry provider' {
        ((Get-CPathProvider -Path 'hklm:\software').Name) | Should -Be 'Registry'
    }

    It 'gets relative path provider' {
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

    It 'get no provider for bad path' {
        ((Get-CPathProvider -Path 'C:\I\Do\Not\Exist').Name) | Should -Be 'FileSystem'
    }

    It 'gets registry' {
        Get-CPathProvider -Path (Get-Item -Path 'hkcu:\software').PSPath |
            Select-Object -ExpandProperty 'Name' |
            Should -Be 'Registry'
    }
}

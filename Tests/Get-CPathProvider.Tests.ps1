
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    $script:rootPath = Resolve-Path -Path '\' | Select-Object -ExpandProperty 'Path'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Get-CPathProvider' {
    It 'gets file system provider' {
        ((Get-CPathProvider -Path $PSHOME).Name) | Should -Be 'FileSystem'
    }

    It 'gets relative path provider' {
        ((Get-CPathProvider -Path '..\').Name) | Should -Be 'FileSystem'
    }

    It 'get no provider for bad path' {
        (Get-CPathProvider -Path (Join-Path -Path $script:rootPath -ChildPath 'I\Do\Not\Exist')).Name |
            Should -Be 'FileSystem'
    }

    $noRegProvider = -not (Get-PSProvider -PSProvider 'Registry' -ErrorAction Ignore)

    It 'gets registry provider' -Skip:$noRegProvider {
        ((Get-CPathProvider -Path 'hklm:\software').Name) | Should -Be 'Registry'
    }

    It 'gets relative path provider' -Skip:$noRegProvider {
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

    It 'gets registry' -Skip:$noRegProvider {
        Get-CPathProvider -Path (Get-Item -Path 'hkcu:\software').PSPath |
            Select-Object -ExpandProperty 'Name' |
            Should -Be 'Registry'
    }
}

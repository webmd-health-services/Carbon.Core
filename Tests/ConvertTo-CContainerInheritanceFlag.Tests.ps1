
using module '..\Carbon.Core'

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:testDirPath = ''
    $script:testNum = 0
    $script:userCredential = Get-TestUser -Name 'CCntnrFlags'
}

Describe 'ConvertTo-CContainerInheritanceFlag' {
    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath $script:testNum
        New-Item -Path $script:testDirPath -ItemType 'Directory'
        $script:testRegPath = Join-Path -Path 'TestRegistry:' -ChildPath $script:testNum
        Install-CRegistryKey -Path $script:testRegPath
    }

    AfterEach {
        $script:testNum += 1
    }

    It 'converts to NTFS container inheritance flags' {
        foreach ($ciFlag in ([Enum]::GetValues([CContainerInheritanceFlags])))
        {
            Grant-CPermission -Path $script:testDirPath `
                              -Identity $script:userCredential.UserName `
                              -Permission FullControl `
                              -ApplyTo $ciFlag
            $perm = Get-CPermission -Path $script:testDirPath -Identity $script:userCredential.UserName
            $flags = ConvertTo-CContainerInheritanceFlag -InheritanceFlags $perm.InheritanceFlags `
                                                         -PropagationFlags $perm.PropagationFlags
            $flags | Should -Be $ciFlag
        }
    }

    It 'converts to registry container inheritance flags' {
        foreach ($ciFlag in ([Enum]::GetValues([CContainerInheritanceFlags])))
        {
            Grant-CPermission -Path $script:testRegPath `
                              -Identity $script:userCredential.UserName `
                              -Permission ReadKey `
                              -ApplyTo $ciFlag
            $perm = Get-CPermission -Path $script:testRegPath -Identity $script:userCredential.UserName
            $flags = ConvertTo-CContainerInheritanceFlag -InheritanceFlags $perm.InheritanceFlags `
                                                         -PropagationFlags $perm.PropagationFlags
            $flags | Should -Be $ciFlag
        }
    }
}

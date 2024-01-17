
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function ThenNoError
    {
        $Global:Error | Should -BeNullOrEmpty
    }
}

Describe 'Test-CType' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'finds built in types' {
        Test-CType 'System.String' | Should -BeTrue
        ThenNoError
    }

    It 'finds custom types' {
        Add-Type -TypeDefinition @'

namespace Carbon.Core
{
    public static class TestCType
    {

    }
}
'@
        Test-CType 'Carbon.Core.TestCType' | Should -BeTrue
        ThenNoError
    }

    It 'writes no errors for non-existent type' {
        Test-CType 'Carbon.Core.IDoNotExist' | Should -BeFalse
        ThenNoError
    }

    It 'returns all types that match the name' {
        Add-Type -TypeDefinition @'
namespace Carbon.Core
{
    public static class TestCType2
    {
    }
}
'@
        $types = Test-CType 'Carbon.Core.TestCType2' -PassThru
        ThenNoError
        $types | Should -HaveCount 1
        $types | Should -BeOfType ([Type])
    }

    It 'returns nothing when type is not found and using PassThru switch' {
        Test-CType 'IDoNotExist' -PassThru | Should -BeNullOrEmpty
        ThenNoError
    }

    It 'allows assembly-qualified names' {
        Test-CType ([string].AssemblyQualifiedName) | Should -BeTrue
        ThenNoError
    }

    It 'can search case-senstively' {
        Test-CType -Name 'SYSTEM.STRING' -CaseSensitive | Should -BeFalse
        ThenNoError
    }

    It 'searches case-insenstively' {
        Test-CType -Name 'SYSTEM.STRING' | Should -BeTrue
        ThenNoError
    }
}

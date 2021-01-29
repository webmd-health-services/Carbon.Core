
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'ConvertTo-CBase64.when piped strings' {
    It 'should base64 all the strings' {
        $one, $two, $three = 'one', 'two', 'three' | ConvertTo-CBase64
        $one | Should -Be 'bwBuAGUA'
        $two | Should -Be 'dAB3AG8A'
        $three | Should -Be 'dABoAHIAZQBlAA=='
    }
}

Describe 'ConvertTo-CBase64.when piped chars' {
    It 'should base64 encode all the chars together' {
        $result = 'four'.ToCharArray() | ConvertTo-CBase64
        $result | Should -Be 'ZgBvAHUAcgA='
    }
}

Describe 'ConvertTo-CBase64.when piped bytes' {
    It 'should base64 encode all the bytes together' {
        $result = [Text.Encoding]::Unicode.GetBytes('five') | ConvertTo-CBase64
        $result | Should -Be 'ZgBpAHYAZQA='
    }
}

Describe 'ConvertTo-CBase64.when passed array of objects' {
    It 'should convert all the objects' {
        $seven, $eight, $nine = ConvertTo-CBase64 'seven', ('eight'.ToCharArray()), ([Text.Encoding]::Unicode.GetBytes('nine'))
        $seven | Should -Be 'cwBlAHYAZQBuAA=='
        $eight | Should -Be 'ZQBpAGcAaAB0AA=='
        $nine | Should -Be 'bgBpAG4AZQA='
    }
}

Describe 'ConvertTo-CBase64.when passed array of strings' {
    It 'should convert each string' {
        $ten, $eleven, $twelve = ConvertTo-CBase64 ([String[]]@('ten', 'eleven', 'twelve'))
        $ten | Should -Be 'dABlAG4A'
        $eleven | Should -Be 'ZQBsAGUAdgBlAG4A'
        $twelve | Should -Be 'dAB3AGUAbAB2AGUA'
    }
}

Describe 'ConvertTo-CBase64.when passed array of chars' {
    It 'should convert the whole array' {
        $chars = 'thirteen'.ToCharArray()
        $chars -is [char[]] | Should -BeTrue
        $thirteen = ConvertTo-CBase64 $chars
        $thirteen | Should -Be 'dABoAGkAcgB0AGUAZQBuAA=='
    }
}

Describe 'ConvertTo-CBase64.when passed array of bytes' {
    It 'should convert the whole array' {
        $bytes = [Text.Encoding]::Unicode.GetBytes('fourteen')
        $bytes -is [byte[]] | Should -BeTrue
        $fourteen = ConvertTo-CBase64 $bytes
        $fourteen | Should -Be 'ZgBvAHUAcgB0AGUAZQBuAA=='
    }
}

Describe 'ConvertTo-CBase64.when passed $null' {
    It 'should do nothing' {
        $null | ConvertTo-CBase64 | Should -HaveCount 0
    }
}

Describe 'ConvertTo-CBase64.when piping chars mixed with non-chars' {
    It 'should encode each item' {
        $chars1 = 'fi'.ToCharArray()
        $bytes = [Text.Encoding]::Unicode.GetBytes('fte')
        $chars2 = 'en'.ToCharArray()
        $result = & {
            $chars1
            $bytes
            $chars2
        } | ConvertTo-CBase64
        $result | Should -HaveCount ($chars1.Length + $bytes.Length + $chars2.Length)
        $idx = 0
        $result[$idx++] | Should -Be 'ZgA='
        $result[$idx++] | Should -Be 'aQA='
        $result[$idx++] | Should -Be 'Zg=='
        $result[$idx++] | Should -Be 'AA=='
        $result[$idx++] | Should -Be 'dA=='
        $result[$idx++] | Should -Be 'AA=='
        $result[$idx++] | Should -Be 'ZQ=='
        $result[$idx++] | Should -Be 'AA=='
        $result[$idx++] | Should -Be 'ZQA='
        $result[$idx++] | Should -Be 'bgA='
    }
}

Describe 'ConvertTo-CBase64.when piping bytes mixed with non-bytes' {
    It 'should encode each item' {
        $bytes1 = [Text.Encoding]::Unicode.GetBytes('si')
        $chars = 'xte'.ToCharArray()
        $bytes2 = [Text.Encoding]::Unicode.GetBytes('en')
        & {
            $bytes1
            $chars
            $bytes2
        } | ConvertTo-CBase64 | Should -HaveCount ($bytes1.Length + $chars.Length + $bytes2.Length)
    }
}

Describe 'ConvertTo.CBase64.when piping types convertable to bytes' {
    It 'should convert each object' {
        $result = & {
            $true
            $false

            [char]'a'

            [Int16]::MinValue
            [Int16]0
            [Int16]::MaxValue

            [int]::MinValue
            [int]0
            [int]::MaxValue

            [Int64]::MinValue
            [Int64]0
            [Int64]::MaxValue

            [UInt16]::MinValue
            [UInt16]::MaxValue

            [UInt32]::MinValue
            [UInt32]::MaxValue

            [UInt64]::MinValue
            [UInt64]::MaxValue

            [float]::MinValue
            [float]::Epsilon
            [float]::MaxValue
            [float]::NaN
            [float]::NegativeInfinity
            [float]::PositiveInfinity

            [double]::MinValue
            [double]::Epsilon
            [double]::MaxValue
            [double]::NaN
            [double]::NegativeInfinity
            [double]::PositiveInfinity

        } | ConvertTo-CBase64

        $idx = 0
        
        # bool
        $result[$idx++] | Should -Be 'AQ=='
        $result[$idx++] | Should -Be 'AA=='

        # char
        $result[$idx++] | Should -Be 'YQA='

        # Int16/short
        $result[$idx++] | Should -Be 'AIA='
        $result[$idx++] | Should -Be 'AAA='
        $result[$idx++] | Should -Be '/38='

        # Int32/int
        $result[$idx++] | Should -Be 'AAAAgA=='
        $result[$idx++] | Should -Be 'AAAAAA=='
        $result[$idx++] | Should -Be '////fw=='

        # Int64/long
        $result[$idx++] | Should -Be 'AAAAAAAAAIA='
        $result[$idx++] | Should -Be 'AAAAAAAAAAA='
        $result[$idx++] | Should -Be '/////////38='

        # UInt16/ushort
        $result[$idx++] | Should -Be 'AAA='
        $result[$idx++] | Should -Be '//8='

        # UInt32/uint
        $result[$idx++] | Should -Be 'AAAAAA=='
        $result[$idx++] | Should -Be '/////w=='

        # UInt64/ulong
        $result[$idx++] | Should -Be 'AAAAAAAAAAA='
        $result[$idx++] | Should -Be '//////////8='

        # float
        $result[$idx++] | Should -Be '//9//w=='
        $result[$idx++] | Should -Be 'AQAAAA=='
        $result[$idx++] | Should -Be '//9/fw=='
        $result[$idx++] | Should -Be 'AADA/w=='
        $result[$idx++] | Should -Be 'AACA/w=='
        $result[$idx++] | Should -Be 'AACAfw=='

        # double
        $result[$idx++] | Should -Be '////////7/8='
        $result[$idx++] | Should -Be 'AQAAAAAAAAA='
        $result[$idx++] | Should -Be '////////738='
        $result[$idx++] | Should -Be 'AAAAAAAA+P8='
        $result[$idx++] | Should -Be 'AAAAAAAA8P8='
        $result[$idx++] | Should -Be 'AAAAAAAA8H8='

    }
}

Describe 'ConvertTo-CBase64.when piping an invalid object' {
    It 'should fail' {
        $Global:Error.Clear()
        $result = [pscustomobject]@{} | ConvertTo-CBase64 -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $result | Should -HaveCount 0
        $Global:Error | Should -HaveCount 1
        $Global:Error | Should -Match 'Failed to base64 encode "System.Management.Automation.PSCustomObject" object'
    }
}

Describe 'ConvertTo-CBase64.when using a custom encoding' {
    It 'should encode with bytes from that encoding' {
        $defaultResult = 'seventeen' | ConvertTo-CBase64
        $result = 'seventeen' | ConvertTo-CBase64 -Encoding ([Text.Encoding]::ASCII)
        $result | Should -Not -Be $defaultResult -Because 'ASCII and Unicode encoding results in different bytes'
        $result | Should -Be 'c2V2ZW50ZWVu'
    }
}
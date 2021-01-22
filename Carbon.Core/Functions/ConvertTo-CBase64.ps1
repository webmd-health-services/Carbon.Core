
function ConvertTo-CBase64
{
    <#
    .SYNOPSIS
    Base64 encodes things.
    
    .DESCRIPTION
    The `ConvertTo-CBase64` function base64 encodes things. Pipe what you want to encode to `ConvertTo-CBase64`. The
    function can encode:
    
    * [String]
    * [byte]
    * [char]
    * Signed integers: [int16], [int], [int64] (i.e. [long])
    * Unsigned integers: [uint16], [uint32], [uint64]
    * Floating point numbers: [float], [double]
    * [bool]

    For each item piped to `ConvertTo-CBase64`, the function returns that item base64 encoded.

    If you pipe all bytes or all chars to `ConvertTo-CBase64`, it will encode all the bytes and chars together. This
    allows you to do this:

        [IO.File]::ReadAllBytes('some file') | ConvertTo-CBase64

    and get back a single string for all the bytes/chars.

    By default, `ConvertTo-CBase64` uses Unicode/UTF-16 encoding when converting strings to base64 (this is the default
    encoding of strings by .NET and PowerShell). To use a different encoding, pass it to the `Encoding` parameter
    (`[Text.Encoding] | Get-Member -Static` will show all the default encodings).

    .EXAMPLE
    'Encode me, please!' | ConvertTo-CBase64
    
    Demonstrates how to encode a string in base64.
    
    .EXAMPLE
    'Encode me, please!' | ConvertTo-CBase64 -Encoding ([Text.Encoding]::ASCII)
    
    Demonstrates how to use a custom encoding when converting a string to base64. The parenthesis around the encoding
    is required by the PowerShell language.

    .EXAMPLE
    [IO.File]::ReadAllBytes('path to some file') | ConvertTo-CBase64

    Demonstrates that you can pipe an array of bytes to `ConvertTo-CBase64` and you'll get back a single string of all
    the bytes base64 encoded.

    .EXAMPLE
    [IO.File]::ReadAllText('path to some file').ToCharArray() | ConvertTo-CBase64

    Demonstrates that you can pipe an array of chars to `ConvertTo-CBase64` and you'll get back a single string of all
    the chars base64 encoded.

    .EXAMPLE
    @( $true, [int16]1, [int]2, [long]3, [uint16]4, [uint32]5, [uint64]6, [float]7.8, [double]9.0) | ConvertTo-CBase64

    Demonstrates that `ConvertTo-CBase64` can convert booleans, all sizes of signed and unsigned ints, floats, and 
    doubles to base64.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [AllowNull()]
        [AllowEmptyString()]
        # The value to base64 encode.
        [Object]$InputObject,
        
        # The encoding to use. Default is Unicode/UTF-16 (the default .NET encoding for strings). This parameter is only
        # used if encoding a string or char array.
        [Text.Encoding]$Encoding = ([Text.Encoding]::Unicode)
    )
    
    begin
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

        $collector = $null
        $collectingBytes = $false
        $collectingChars = $false
        $collecting = $false
        $stopProcessing = $false
        $inspectedFirstItem = $false
    }

    process
    {
        if( $stopProcessing )
        {
            return
        }

        if( $null -eq $InputObject )
        {
            return 
        }

        if( $InputObject -is [Collections.IEnumerable] -and $InputObject -isnot [String] )
        {
            Write-Debug "$($InputObject.GetType().FullName)"
            $InputObject | ConvertTo-CBase64 -Encoding $Encoding
            return
        }

        $isByte = $InputObject -is [byte]
        $isChar = $InputObject -is [char]

        if( $PSCmdlet.MyInvocation.ExpectingInput -and -not $inspectedFirstItem ) 
        {
            $inspectedFirstItem = $true

            if( $isByte )
            {
                $collecting = $true
                $collectingBytes = $true
                $collector = [Collections.Generic.List[byte]]::New()
                Write-Debug -Message ("Collecting bytes.")
            }
            elseif( $isChar )
            {
                $collecting = $true
                $collectingChars = $true
                $collector = [Collections.Generic.List[char]]::New()
                Write-Debug -Message ("Collecting chars.")
            }
        }

        if( $collecting )
        {
            # Looks like we didn't get passed an array of bytes or chars, but an array of mixed object types.
            if( (-not $isByte -and $collectingBytes) -or (-not $isChar -and $collectingChars) )
            {
                $collecting = $false

                # Since we are no longer collecting, we need to encode all the previous items we collected.
                foreach( $item in $collector )
                {
                    ConvertTo-CBase64 -InputObject $item -Encoding $Encoding
                }
                ConvertTo-CBase64 -InputObject $InputObject -Encoding $Encoding
                return
            }

            [void]$collector.Add($InputObject)
            return
        }

        if( $InputObject -is [String] )
        {
            return [Convert]::ToBase64String($Encoding.GetBytes($InputObject))
        }

        if( $isByte )
        {
            return [Convert]::ToBase64String([byte[]]$InputObject)
        }

        if( $InputObject -is [bool] -or $isChar -or $InputObject -is [int16] -or $InputObject -is [int] -or `
            $InputObject -is [long] -or $InputObject -is [uint16] -or $InputObject -is [uint32] -or `
            $InputObject -is [uint64] -or $InputObject -is [float] -or $InputObject -is [double] )
        {
            return [Convert]::ToBase64String([BitConverter]::GetBytes($InputObject))
        }

        $stopProcessing = $true
        $msg = "Failed to base64 encode ""$($InputObject.GetType().FullName)"" object. The " +
               'ConvertTo-CBase64 function can only convert strings, chars, bytes, bools, all signed and unsigned ' +
               'integers, floats, and doubles.'
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
    }

    end
    {
        if( $stopProcessing )
        {
            return
        }

        if( -not $collecting )
        {
            return
        }

        if( $collectingChars )
        {
            $bytes = $Encoding.GetBytes($collector.ToArray())
        }
        elseif( $collectingBytes )
        {
            $bytes = $collector.ToArray()
        }

        [Convert]::ToBase64String($bytes)
    }
}

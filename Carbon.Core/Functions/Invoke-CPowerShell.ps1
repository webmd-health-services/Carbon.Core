
function Invoke-CPowerShell
{
    <#
    .SYNOPSIS
    Invokes a new `powershell.exe` process.

    .DESCRIPTION
    The `Invoke-CPowerShell` scripts executes a new PowerShell process. Pass the parameters to pass to the executable
    to the ArgumentList parameter. The function uses the `&` operator to run PowerShell. By default, the PowerShell
    executable in `$PSHOME` is used. In Windows PowerShell (i.e. powershell.exe), the PowerShell executable in "$PSHOME"
    that matches the architecture of the operating system. Use the `x86` switch to use 32-bit `powershell.exe`. Because
    this function uses the `&` operator to execute PowerShell, all the PowerShell streams from the invoked command are
    returned (e.g. stdout, verbose, warning, error, stderr, etc.).

    To use a different PowerShell executable, like PowerShell Core (i.e. pwsh), pass the path to the PowerShell
    executable to the `Path` parameter. If the PowerShell executable is in your PATH, you can pass just the executable
    name.

    If you want to run an encoded command, pass it to the `Command` parameter. The value of the Command parameter will
    be base64 encoded and added to the end of the arguments in the ArgumentList parameter, along with the
    "-EncodedCommand" switch.

    You can run the PowerShell process as a different user by passing that user's credentials to the `Credential`
    parameter. `Invoke-CPowerShell` uses the Start-Job cmdlet to start a background job with those credentials.
    `Start-Job` runs PowerShell with the `&` operator.

    There is a known issue on Linux and macOS that prevents the `Start-Job` cmdlet (what `Invoke-CPowerShell` uses to
    run PowerShell as another user) from starting PowerShell as another user. See
    https://github.com/PowerShell/PowerShell/issues/7172 for more information.

    .EXAMPLE
    Invoke-CPowerShell -ArgumentList '-NoProfile','-NonInteractive','-Command','$PID'

    Demonstrates how to start a new PowerShell process.

    .EXAMPLE
    Invoke-CPowerShell -Command $aLargePSScript -ArgumentList '-NoProfile','-NonInteractive'

    Demonstrates how to run an encoded command. In this example, `Invoke-CPowerShell` encodes the command in the
    `Command` parameter, then runs PowerShell with `-NoProfile -NonInteractive -EncodedCommand $encodedCommand`
    parameters.

    .EXAMPLE
    Invoke-CPowerShell -Credential $cred -ArgumentList '-NoProfile','-NonInteractive','-Command','[Environment]::UserName'

    Demonstrates how to run PowerShell as a different user by passing that user's credentials to the `Credential`
    parameter. This credential is passed to the `Start-Job` cmdlet's `Credential` parameter, then PowerShell is
    executed using the `&` operator.

    .EXAMPLE
    Invoke-CPowerShell -x86 -ArgumentList '-Command','[Environment]::Is64BitProcess'

    Demonstrates how to run PowerShell in a 32-bit process. This switch only has an effect on 64-bit Windows operating
    systems. On other systems, use the `-Path` parameter to run PowerShell with a different architecture (which must
    be installed).

    .EXAMPLE
    Invoke-CPowerShell -Path 'pwsh' -ArgumentList '-Command','$PSVersionTable.Edition'

    Demonstrates how to use a custom PowerShell executable. In this case the first `pwsh` command found in your PATH
    environment variable is used.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        # Any arguments to pass to PowerShell. They are passed as-is, so you'll need to handle any necessary
        # escaping.
        #
        # If you need to run an encoded command, use the `Command` parameter to pass the command and this parameter to
        # pass other parameters. The encoded command will be added to the end of the arguments.
        [Object[]]$ArgumentList,

        # The command to run, as a string. The command will be base64 encoded first and passed to PowerShell's
        # `EncodedCommand` parameter.
        [String]$Command,

        # Run PowerShell as a specific user. Pass that user's credentials.
        #
        # There is a known issue on Linux and macOS that prevents the `Start-Job` cmdlet (what `Invoke-CPowerShell`
        # uses to run PowerShell as another user) from starting PowerShell as another user. See
        # https://github.com/PowerShell/PowerShell/issues/7172 for more information.
        [pscredential]$Credential,

        # Run the x86 (32-bit) version of PowerShell. If not provided, the version which matches the OS architecture
        # is used, *regardless of the architecture of the currently running process*. I.e. this command is run under
        # a 32-bit PowerShell on a 64-bit operating system, without this switch, `Invoke-CPowerShell` will start a
        # 64-bit "PowerShell".
        #
        # This switch is only used on Windows.
        [switch]$x86,

        # The path to the PowerShell executable to use. The default is to use the executable in "$PSHOME". On Windows,
        # the PowerShell executable in the "$PSHOME" that matches the operating system's architecture is used.
        #
        # If the PowerShell executable is in your `PATH`, you can pass the executable name instead.
        [String]$Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not $Path )
    {
        $params = @{ }
        if( $x86 )
        {
            $params.x86 = $true
        }

        $Path = Get-CPowerShellPath @params
    }

    $ArgumentList = & {
        if( $ArgumentList )
        {
            $ArgumentList | Write-Output
        }

        if( $Command )
        {
            '-EncodedCommand' | Write-Output
            $Command | ConvertTo-CBase64 | Write-Output
        }
    }

    Write-Verbose -Message $Path
    $ArgumentList | ForEach-Object { Write-Verbose -Message "    $($_)" }
    if( $Credential )
    {
        $location = Get-Location
        $currentDir = [Environment]::CurrentDirectory
        $newCurrentDir = [Environment]::GetFolderPath('System')
        if (-not $newCurrentDir)
        {
            $newCurrentDir = Resolve-Path -Path '\'
        }
        Push-Location -Path $newCurrentDir
        [Environment]::CurrentDirectory = $newCurrentDir
        try
        {
            $output = $null
            $WhatIfPreference = $false
            Start-Job -Credential $Credential -ScriptBlock {
                    Set-Location $using:location
                    [Environment]::CurrentDirectory = $using:currentDir
                    & $using:Path $using:ArgumentList
                    $LASTEXITCODE
                    exit $LASTEXITCODE
                } |
                Receive-Job -Wait -AutoRemoveJob |
                Tee-Object -Variable 'output' |
                Select-Object -SkipLast 1

            $LASTEXITCODE = $output | Select-Object -Last 1
        }
        finally
        {
            [Environment]::CurrentDirectory = $currentDir
            Pop-Location
        }
    }
    else
    {
        & $Path $ArgumentList
    }
    Write-Verbose -Message "  LASTEXITCODE  $($LASTEXITCODE)"
}


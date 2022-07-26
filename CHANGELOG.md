
# 1.1.0

Added `Test-CTypeDataMember` and `Add-CTypeData` functions for testing if a type has any defined custom type data and
adding custom type data, respectively. Defining type data with .ps1xml files can result in errors importing the same
module multiple times: PowerShell complains that the type data is already defined. Using `Add-CTypeData` prevents these
this error as it only adds members that don't already exist.


# 1.0.0

## Upgrade Instructions

We're breaking up Carbon into smaller and more targeted modules. Hopefully, this will help maintenance, and make it
easier to use Carbon across many versions and editions of PowerShell. This module will be the place where core functions
used by other Carbon modules will be put.

If you're upgrading from Carbon to this module, you should do the following:

* Replace usages of `Test-COSIs64Bit` with `Test-COperatingSystem -Is64Bit`.
* Replace usages of `Test-COSIs32Bit` with `Test-COperatingSystem -Is32Bit`.
* Replace usages of `Test-CPowerShellIs32Bit` with `Test-CPowerShell -Is32Bit`.
* Replace usages of `Test-CPowerShellIs64Bit` with `Test-CPowerShell -Is64Bit`.
* Rename usages of the `ConvertTo-CBase64` function's `Value` parameter to `InputObject`, or pipe the value to the 
function instead.

We made a lot of changes to the `Invoke-CPowerShell` function:

* The `Invoke-CPowerShell` function no longer allows you to pass script blocks. Instead, convert your script block to
a string, and pass that string to the `Command` parameter. This will base64 encode the command and pass it to 
PowerShell's -EncodedCommand property.
* The `Invoke-CPowerShell` function no longer has `FilePath`, `OutputFormat`, `ExecutionPolicy`, `NonInteractive`, 
or `Runtime` parameters. Instead, pass these as arguments to the `ArgumentList` parameter, e.g. 
`-ArgumentList @('-NonInteractive', '-ExecutionPolicy', 'Bypasss')`. You are now responsible for passing all PowerShell
arguments via the `ArgumentList` parameter.
* The `Invoke-CPowerShell` function no longer supports running PowerShell 2 under .NET 4.
* Remove the `-Encode` switch. `Invoke-CPowerShell` now always base64 encodes the value of the `Command` parameter.
* The `Invoke-CPowerShell` function only accepts strings to the `-Command` parameter. Check all usages to ensure you're
passing a string.
* The `Invoke-CPowerShell` function now returns output when running PowerShell as a different user. You may see more
output in your scripts.


## Changes Since Carbon 2.9.4

* Migrated `Invoke-CPowerShell` and `ConvertTo-CBase64` from Carbon.
* `ConvertTo-CBase64` now converts chars, ints (signed and unsigned, 16, 32, and 64-bit sizes), floats, and doubles to 
base64. You can now also pipe an array of bytes or chars and it will collect each item in the array and encode them at
as one unit.
* Renamed the `ConvertTo-CBase64` function's `Value` parameter to `InputObject`.
* Created `Test-COperatingSystem` function that can test if the current OS is 32-bit, 62-bit, Windows, Linux, and/or 
macOS. This function was adapted from and replaces's Carbon's `Test-COSIs64Bit` and `Test-COSIs32Bit`.
* Created `Test-CPowerShell` function that can test if the current PowerShell instance is 32-bit, 64-bit, Core edition,
or Desktop edition. It treats  versions of PowerShell that don't specify a version as "Desktop". This function was 
adapted from and replaces Carbon's `Test-CPowerShellIs32Bit` and `Test-CPowerShellIs64Bit` functions.
* `Invoke-CPowerShell` now works on Linux and macOS. On Windows, it will start a new PowerShell process using the same
edition. If you want to use a custom version of PowerShell, pass the path to the PowerShell executable to use to the
new `Path` parameter.

## Known Issues
* There is a bug in PowerShell Core on Linux/macOS that fails when running `Start-Job` with a custom credential. The
`Invoke-CPowerShell` function will fail when run on Linux/MacOS using a custom credential. See 
https://github.com/PowerShell/PowerShell/issues/7172 for more information.
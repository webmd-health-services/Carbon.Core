
# Overview

The `Carbon.Core` module contains general-purpose functions that make doing things in PowerShell much
easier. It is also the core dependency for other modules in the Carbon family.

This module exports the following functions:

* `ConvertTo-CBase64`: convert things to base64 encoded strings.
* `Invoke-CPowerShell`: a function for executing a PowerShell process, optionally a different edition/executable, 
different architecture, and/or as a different user.
* `Test-COperatingSystem`: check if the current operating system is 32-bit, 64-bit, Windows, Linux, or macOS.
* `Test-CPowerShell`: check if the current PowerShell instance is 32-bit, 64-bit, Core edition, or Desktop edition 
(older versions of PowerShell that don't specify their edition are assumed to be Desktop).


# System Requirements

* Windows PowerShell 5.1+ and .NET 4.6.1+
* PowerShell Core 6+

# Installing

To install globally:

```powershell
Install-Module -Name 'Carbon.Core'
Import-Module -Name 'Carbon.Core'
```

To install privately:

```powershell
Save-Module -Name 'Carbon.Core' -Path '.'
Import-Module -Name '.\Carbon.Core'
```

# The Carbon Family

* [Carbon](http://get-carbon.org): the original. This is where all the other Carbon modules started from. It is great and one of the most
  downloaded modules on the PowerShell Gallery. It also has *a lot* of functionality that you may or may not use.
  All this functionality makes it hard to maintain. Functions in here will slowly migrate to other modules as those functions need to be updated.
* **Carbon.Core** (this module): This module contains the core, general-purpose functions that are used by other
Carbon modules.
* [Carbon.Cryptography](https://github.com/WebMD-Health-Services/Carbon.Cryptography): functions for encrypting and decrypting strings and creating RSA public/private keys for encrypting/decrypting.

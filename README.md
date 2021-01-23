
# Overview

The `Carbon.Management` module contains general-purpose functions that make doing things in PowerShell much
easier. It is also the core dependency for other modules in the Carbon family.

* `Invoke-CPowerShell`: a function for executing a PowerShell process, optionally under different .NET runtimes and
  as a different user.

# System Requirements

* PowerShell 5.1+

# Installing

To install globally:

```powershell
Install-Module -Name 'Carbon.Management'
Import-Module -Name 'Carbon.Management'
```

To install to a custom, private location:

```powershell
Save-Module -Name 'Carbon.Management' -Path '.'
Import-Module -Name '.\Carbon.Management'
```

# The Carbon Family

* `Carbon`: the original. This is where all the other Carbon modules started from. It is great and one of the most
  downloaded modules on the PowerShell Gallery. It also has *a lot* of functionality that you may or may not use.
  All this functionality makes it hard to maintain. Functions in here will slowly migrate to other modules as those functions need to be updated.
* `Carbon.Management` (this module): This module contains the core, general-purpose functions. This module will
  frequently be a dependency of other Carbon modules.
* `Carbon.Cryptography`: functions for encrypting and decrypting strings and creating RSA public/private keys for 
  encrypting/decrypting.


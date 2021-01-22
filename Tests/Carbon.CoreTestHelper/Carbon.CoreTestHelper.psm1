
function Get-TestUser
{
    param(
        [Parameter(Mandatory)]
        [String]$Name
    )

    $password = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\.password' -Resolve) -TotalCount 1
    return [pscredential]::New($Name, (ConvertTo-SecureString -String $password -AsPlainText -Force))
}

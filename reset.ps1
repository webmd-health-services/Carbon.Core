[CmdletBinding()]
param(
)

#Requires -RunAsAdministrator
Set-StrictMode -Version 'Latest'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'PSModules\Carbon' -Resolve)

if( -not (Test-Path -Path 'variable:IsWindows') )
{
    $IsWindows = $true
    $IsLinux = $false
    $IsMacOS = $false
}

$usernames = 
    Import-LocalizedData -BaseDirectory (Join-Path -Path $PSScriptRoot -ChildPath 'Tests') -FileName 'users.psd1' |
    ForEach-Object { $_['Users'] } |
    ForEach-Object { $_['Name'] }

foreach( $username in $usernames )
{
    if( $IsWindows )
    {
        Uninstall-CUser -UserName $username
    }
    else
    {
        Write-Verbose -Message "Deleting user ""$($username)""."
        sudo userdel -r -f $username
    }
}

$passwordPath = Join-Path -Path $PSScriptRoot -ChildPath 'Tests\.password'
if( (Test-Path -Path $passwordPath) )
{
    Remove-Item -Path $passwordPath -Force
}

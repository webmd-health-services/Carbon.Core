<#
.SYNOPSIS
Installs Arc

.DESCRIPTION
The `init.ps1` script downloads the version of Arc listed in the `.arcversion` file in your repository root. The package is cached to your local app data (i.e. `$env:LOCALAPPDATA`) at `WebMD Health Services\Arc\upack.cache`. The script then uses `robocopy.exe` to mirror Arc from the cache into your local repository.

.EXAMPLE
.\init.ps1

Demonstrates how to initialize Arc in your repository. After the script runs, you'll have a full version of Arc in the `Arc` directory in your repository.
#>
[CmdletBinding()]
param(
    [string]
    # The path to the repository that is integrating Arc. The default is the parent directory of the directory where this script is located. That directory should have an `.arcversion` file that defines what version of Arc to use.
    $RepositoryPath,
    
    [string]
    # Path to the root directory for local WHS app data. The default is to "WebMD Health Services" in the current user's local app data directory.
    $WhsAppDataPath = (Join-Path -Path $env:LOCALAPPDATA -ChildPath ('WebMD Health Services')),

    [string]
    # Path to the directory where the Arc packages should be cached. The default is "WebMD Health Services\Arc\upack.cache" in the current user's local app data directory.
    $CachePath = (Join-Path -Path $WhsAppDataPath -ChildPath ('Arc\upack.cache')),

    [switch]
    # Force download a fresh copy of Arc from ProGet into the local Arc cache.
    $Force
)

#Requires -Version 4
Set-StrictMode -Version Latest

# Fail builds if we can't initialize Arc.
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

# Function should be shared (identical) between init.ps1 and Enable-Arc.ps1
function Initialize-ArcCache
{
    param(
        [Parameter(Mandatory)]
        [string]$ArcVersionCacheRoot,

        [Parameter(Mandatory)]
        [string]$WhsAppDataPath,

        [switch]$Force
    )

    if( (-not (Test-Path -Path $arcVersionCacheRoot -PathType Container)) -or $Force )
    {
        $upackVersion = '2.3.2.4'
        $upackExePath = Join-Path -Path $WhsAppDataPath -ChildPath ('upack\{0}\upack.exe' -f $upackVersion)
        $upackVersionDownloadUri = ('https://github.com/Inedo/upack/releases/download/upack-{0}/upack.exe' -f $upackVersion)

        if( -not (Test-Path -Path $upackExePath -PathType Leaf) )
        {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
            New-Item -Path ($upackExePath | Split-Path -Parent) -ItemType Directory -Force | Out-Null

            Invoke-WebRequest -Uri $upackVersionDownloadUri -OutFile $upackExePath

            if( -not (Test-Path -Path $upackExePath -PathType Leaf) )
            {
                Write-Error -Message ('Failed to download upack version "{0}" from GitHub at "{1}". Please open a new PowerShell session and re-run your command. If this problem persists, please contact WHS-DevOps@webmd.net.' -f $upackVersion, $upackVersionDownloadUri)
                exit 1
            }
        }

        Write-Verbose -Message ('Caching Arc {0} -> {1}' -f $arcVersion,$arcVersionCacheRoot)
        Invoke-Command -NoNewScope -ArgumentList $upackExePath -ScriptBlock {
            param(
                $upackExe
            )

            # If upack.exe fails, don't stop. Use $LASTEXITCODE to determine if it failed. If it fails with 
            # ErrorActionPreference set to Stop, under we won't see any of upack.exe's output.
            $ErrorActionPreference = 'Continue'

            & $upackExe 'install' 'Arc' $arcVersion '--source=https://proget.dev.webmd.com/upack/Apps' "--target=$arcVersionCacheRoot" '--overwrite' '--unregistered'
        }

        # Go back.
        $ErrorActionPreference = 'Stop'

        Write-Debug $LASTEXITCODE
        if( $LASTEXITCODE -ne 0 )
        {
            Write-Error -Message ('Failed to download and cache Arc {0}. This could be because that version does not exist or ProGet is not available.' -f $arcVersion)
            exit $LASTEXITCODE
        }
    }
}

function Remove-BuildMetadata
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]
        $InputObject
    )

    process
    {
        $InputObject -replace '\+.*$',''
    }
}

if( -not $RepositoryPath )
{
    $RepositoryPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve
}

$RepositoryPath = Resolve-Path -LiteralPath $RepositoryPath
if( -not $RepositoryPath )
{
    exit 1
}

$configPath = Join-Path -Path $RepositoryPath -ChildPath '.arcversion'
if( -not (Test-Path -Path $configPath -PathType Leaf) )
{
    Write-Error -Message ('Arc version file "{0}" does not exist. Have you integrated this repository with Arc? Instructions are at https://confluence.webmd.net/display/WHS/Arc.' -f $configPath)
    exit 1
}

$arcInfo = Get-Content -Raw -Path $configPath | ConvertFrom-Json
if( -not ($arcInfo | Get-Member -Name 'Version') )
{
    Write-Error -Message ('Arc version file "{0}" is missing a "Version" property. Have you integrated this repository with Arc? Instructions are at https://confluence.webmd.net/display/WHS/Arc.' -f $configPath)
    exit
}

if( -not $arcInfo.Version )
{
    Write-Error -Message ('The Version property in Arc version file "{0}" does not have a value. Have you integrated this repository with Arc? Instructions are at https://confluence.webmd.net/display/WHS/Arc.' -f $configPath)
    exit
}

[bool]$allowPrerelease = $false
if( $arcInfo | Get-Member -Name 'AllowPrerelease' )
{
    if( $arcInfo.AllowPrerelease -is [bool] )
    {
        $allowPrerelease = $arcInfo.AllowPrerelease
    }
    elseif( -not [bool]::TryParse($arcInfo.AllowPrerelease,[ref]$allowPrerelease) )
    {
        Write-Error -Message ('The "AllowPrerelease" property in "{0}" has a non-boolean value, "{1}". Please update this value to be "true" or "false" (without quotes).' -f $configPath,$arcInfo.AllowPrerelease)
        exit 1
    }
}

$arcVersion = $arcInfo.Version | Remove-BuildMetadata

if( [wildcardpattern]::ContainsWildcardCharacters($arcVersion) )
{
    $arcVersion = 
        Invoke-RestMethod -Method Get -Uri 'https://proget.dev.webmd.com/upack/Apps/versions?name=Arc' | 
        ForEach-Object { $_ } |
        ForEach-Object { 
            $package = $_

            $rawVersion = $package.version

            [version]$version = $null
            $isPrerelease = $false
            $prereleaseId = $null
            $prereleaseNumber = $null

            if( $allowPrerelease )
            {
                if( $package.version -notmatch ('^(\d+\.\d+\.\d+)(-([^.]+)\.(\d+))?$') )
                {
                    Write-Error -Message ('Uh oh. Arc package {0} has a version I can''t parse.' -f $package.version) -ErrorAction Stop
                    continue
                }

                $version = [version]$Matches[1]
                $prereleaseId = $Matches[3]
                $prereleaseNumber = [int]$Matches[4]
                $isPrerelease = $prereleaseId -and $prereleaseNumber 
            }
            else
            {
                if( -not [version]::TryParse($rawVersion,[ref]$version) )
                {
                    return
                }
            }

            $package.version = $version

            $package |
                Add-Member -Name 'rawVersion' -MemberType NoteProperty -Value $rawVersion -PassThru |
                Add-Member -Name 'prereleaseId' -MemberType NoteProperty -Value $prereleaseId -PassThru |
                Add-Member -Name 'prereleaseNumber' -MemberType NoteProperty -Value $prereleaseNumber -PassThru |
                Add-Member -Name 'isPrerelease' -MemberType NoteProperty -Value $isPrerelease -PassThru
        } |
        Where-Object { $_.rawVersion -like $arcVersion } |
        Sort-Object -Property 'version',{ -not $_.isPrerelease },'prereleaseId','prereleaseNumber' -Descending |
        Select-Object -First 1 |
        Select-Object -ExpandProperty 'rawVersion'
    if( -not $arcVersion )
    {
        Write-Error -Message ('Unable to find an Arc version that matches wildcard "{0}".' -f $arcInfo.Version)
        exit 1
    }
    Write-Verbose -Message ('Resolved wildcard version {0} -> {1}' -f $arcInfo.Version,$arcVersion)
}

New-Item -Path $CachePath -ItemType 'Directory' -Force -ErrorAction Ignore | Out-String | Write-Debug

$arcVersionCacheRoot = Join-Path -Path $CachePath -ChildPath $arcVersion

$mutexName = 'Arc-{0}' -f $arcVersion
$installLock = New-Object 'Threading.Mutex' $false,$mutexName
try
{
    try
    {
        [void]$installLock.WaitOne()
    }
    catch [Threading.AbandonedMutexException]
    {
        Write-Debug -Message ('[{0:yyyy-MM-dd HH:mm:ss}]  Process "{1}" caught "{2}" exception waiting to acquire mutex "{3}": {4}.' -f (Get-Date),$PID,$_.Exception.GetType().FullName,$mutexName,$_)
        $Global:Error.RemoveAt(0)
    }

    Initialize-ArcCache -WhsAppDataPath $WhsAppDataPath -ArcVersionCacheRoot $arcVersionCacheRoot -Force:$Force
}
finally
{
    $installLock.ReleaseMutex();
    $installLock.Dispose()
    $installLock.Close()
    $installLock = $null
}

$arcDestinationPath = Join-Path -Path $RepositoryPath -ChildPath 'Arc'
$sourceVersionPath = Join-Path -Path $arcVersionCacheRoot -ChildPath 'version.json'
$sourceVersion = Get-Content -Path $sourceVersionPath | ConvertFrom-Json
$destinationVersionPath = Join-Path -Path $arcDestinationPath -ChildPath 'version.json'
$action = ''
if( (Test-Path -Path $destinationVersionPath -PathType Leaf) )
{
    $action = 'update'
    $destinationVersion = Get-Content -Path $destinationVersionPath | ConvertFrom-Json
    if( -not $Force -and $sourceVersion.SemVer2NoBuildMetadata -eq $destinationVersion.SemVer2NoBuildMetadata )
    {
        Write-Verbose -Message ('Skipping Arc update. Arc is already at version "{0}". To force an update, use the -Force switch.' -f $destinationVersion.SemVer2NoBuildMetadata)
        return
    }
    if( -not $Force )
    {
        Write-Information -Message ('Updating Arc {0} -> {1}.' -f $destinationVersion.SemVer2NoBuildMetadata,$sourceVersion.SemVer2NoBuildMetadata)
    }
}
else
{
    $action = 'initialize'
    Write-Information -Message ('Initializing Arc {0}.' -f $sourceVersion.SemVer2NoBuildMetadata)
}

$assembliesInAppDomain =
    Invoke-Command -NoNewScope -ArgumentList 'AppDomainAssemblies' -ScriptBlock {
        [AppDomain]::CurrentDomain.GetAssemblies()
    } |
    Where-Object { -not $_.IsDynamic } |
    Select-Object -ExpandProperty 'Location' |
    Where-Object { $_.StartsWith($arcDestinationPath) }

$assembliesToExclude = New-Object -TypeName 'System.Collections.Generic.List[System.Object]'
foreach ($destAssembly in $assembliesInAppDomain)
{
    $relativePath = $destAssembly -replace [regex]::Escape($arcDestinationPath),''
    $relativePath = $relativePath.TrimStart([IO.Path]::DirectorySeparatorChar)
    $sourceAssembly = Join-Path -Path $arcVersionCacheRoot -ChildPath $relativePath -Resolve -ErrorAction Ignore

    if( -not $sourceAssembly )
    {
        Write-Debug -Message ('Excluding extra file "{0}", it''s already loaded in the current AppDomain and can''t be deleted.' -f $relativePath)
        $assembliesToExclude.Add($destAssembly)
        continue
    }

    $sourceFileHash = Get-FileHash -Path $sourceAssembly | Select-Object -ExpandProperty 'Hash'
    $destFileHash = Get-FileHash -Path $destAssembly | Select-Object -ExpandProperty 'Hash'

    if( $sourceFileHash -eq $destFileHash )
    {
        Write-Debug -Message ('Excluding assembly "{0}", it''s already loaded in the current AppDomain and has not changed.' -f $relativePath)
        $assembliesToExclude.Add($sourceAssembly)
    }
}

$excludeFileParam = & {
    '/XF'
    Join-Path -Path $arcDestinationPath -ChildPath '.gitignore'

    $assembliesToExclude | ForEach-Object { '/XF'; $_ }
}

Write-Verbose -Message ('Syncing {0} -> {1}' -f $arcVersionCacheRoot,$arcDestinationPath)
robocopy $arcVersionCacheRoot `
         $arcDestinationPath `
         /MIR `
         /R:0 `
         /NP `
         $excludeFileParam |
         Write-Debug

if( $LASTEXITCODE -ge 8 )
{
    Write-Error -Message ('We failed to {0} Arc. This is usually because files are loaded and locked by PowerShell. Please restart PowerShell and try again. If the problem persists, reach out to the Platform team for support.' -f $action)
} 
else
{
    Write-Verbose -Message ('Robocopy exit code was {0}, exiting PowerShell with success code 0.' -f $LASTEXITCODE)
    $LASTEXITCODE = 0
}
exit $LASTEXITCODE

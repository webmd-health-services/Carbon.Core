<#
.SYNOPSIS
Runs a build.

.DESCRIPTION
The `build.ps1` script runs the `Build` pipeline, as defined in the `whiskey.yml` file in the root of your repository. (If building on a build server, on a publishing branch, the `PublishTasks` pipeline is also run.)

If your `whiskey.yml` defines additional pipelines besides `Build`, you can run those pipelines by passing their names to the `PipelineName` parameter. For example, with this `whiskey.yml` file:

    Build:
    - Pipeline:
        Name:
        - App1
        - App2

    App1:
    - MSBuild:
        Path:
        - App1\App1.csproj

    App2:
    - MSBuild:
        Path:
        - App2\App2.csproj

You could build just `App2` by running:

    > .\Arc\build.ps1 App2

That way, you don't have to sit through App1's build to get to the build you care about.

If you want to use a different Whiskey YAML file to run your build, pass its path to the `ConfigurationPath` parameter.

To clean up any artifacts previous builds may have created, use the `-Clean` switch.

See [Whiskey](https://whsconfluence.webmd.net/display/WHS/Whiskey) for documentation on how Whiskey works. See [Whiskey Tasks](https://whsconfluence.webmd.net/display/WHS/Whiskey+Tasks) for a list of available tasks. See [whiskey.yml](https://whsconfluence.webmd.net/display/WHS/whiskey.yml) for documentation on the format of the Whiskey YAML file.

.LINK
https://whsconfluence.webmd.net/display/WHS/Whiskey

.LINK
https://whsconfluence.webmd.net/display/WHS/Whiskey+Tasks

.LINK
https://whsconfluence.webmd.net/display/WHS/whiskey.yml

.EXAMPLE
.\Arc\build.ps1

Demonstrates the simplest way to call `build.ps1`. In this case, `build.ps1` will look in the root of your repository for a `whiskey.yml` file and run the `Build` pipeline. If running on a build server on a publishing branch, the `PublishTasks` pipeline is also run.

.EXAMPLE
.\Arc\build.ps1 'App1','App2'

Demonstrates how to call specific pipelines defined in your `whiskey.yml` file. In this case, the `App1` and `App2` pipelines will run.

.EXAMPLE
.\Arc\build.ps1 -Clean

Demonstrates how to delete any artifacts created by previous builds.

.EXAMPLE
.\Arc\build.ps1 -ConfigurationPath '.\whiskey.custom.yml'

Demonstrates how to customzie which Whiskey YAML file to use when running the build.
#>

[CmdletBinding(DefaultParameterSetName='Build')]
param(
    [Parameter(Position=0)]
    [String[]]$PipelineName,

    # The environment you're building in. Defaults to `Developer`.
    [String]$Environment = 'Developer',

    # The path to the `whiskey.yml` file that defines what to build. The default is `whiskey.yml` in the root of the parent repository.
    [String]$ConfigurationPath,

    [Alias('SkipInit')]
    # Don't download and install Arc. You don't ever want to do that.
    [switch]$SkipArcInit,

    [Parameter(Mandatory,ParameterSetName='Clean')]
    # Runs the build in clean mode, which removes any files, tools, packages created by previous builds.
    [switch]$Clean,

    [Parameter(Mandatory,ParameterSetName='Initialize')]
    # Runs the build in initialize mode, which installs any tools used by any of your tasks.
    [switch]$Initialize,

    # The MSBuild configuration to use. The default is "Debug" when run by a developer and "Release" when run by a build server.
    [String]$MSBuildConfiguration
)

#Requires -Version 5.1
Set-StrictMode -Version Latest

$InformationPreference = 'Continue'

if( -not $SkipArcInit )
{
    $initPs1Path = Join-Path -Path $PSScriptRoot -ChildPath 'init.ps1' -Resolve
    $initPs1Hash = Get-FileHash -Path $initPs1Path
    $buildPs1Hash = Get-Filehash -Path $PSCommandPath

    & $initPs1Path

    $newInitPs1Hash = Get-FileHash -Path $initPs1Path
    $newBuildPs1Hash = Get-FileHash -Path $PSCommandPath

    $changedFiles = & {
        if( $newInitPs1Hash.Hash -ne $initPs1Hash.Hash )
        {
            Write-Output (Resolve-Path -Path $initPs1Path -Relative)
        }
        if( $buildPs1Hash.Hash -ne $newBuildPs1Hash.Hash )
        {
            Write-Output (Resolve-Path -Path $PSCommandPath -Relative)
        }
    }

    if( $changedFiles )
    {
        $fileWord = 'file'
        $thisWord = 'this'
        $changeWord = 'change'
        if( ($changedFiles | Measure-Object).Count -gt 1 )
        {
            $fileWord = 'files'
            $thisWord = 'these'
            $changeWord = 'changes'
        }
        $changedFileMsg = 'We''ve updated Arc {0} "{1}".' -f $fileWord,($changedFiles -join '" and "')

        try
        {
            Write-Information -MessageData ('{0} Restarting build.' -f $changedFileMsg)
            & $PSCommandPath @PSBoundParameters
        }
        finally
        {
            Write-Warning -Message ('{0} Please commit {1} {2}.' -f $changedFileMsg,$thisWord,$changeWord)
        }
        return
    }
}

& (Join-Path -Path $PSScriptRoot -ChildPath 'WhsAutomation\Import-WhsAutomation.ps1' -Resolve)
& (Join-Path -Path $PSScriptRoot -ChildPath 'Whiskey\Import-Whiskey.ps1' -Resolve)
& (Join-Path -Path $PSScriptRoot -ChildPath 'WhsWhiskeyTasks\Import-WhsWhiskeyTasks.ps1' -Resolve)

if( -not $ConfigurationPath )
{
    # TODO: Remove support for whsbuild.yml in Arc 4.
    $ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\whsbuild.yml'
    if( (Test-Path -Path $ConfigurationPath -PathType Leaf) )
    {
        Write-Warning -Message ('The default Whiskey build file is now named ''whiskey.yml'' (instead of ''whsbuild.yml''). Please rename ''{0}'' to ''whiskey.yml''. Support for whsbuild.yml files will be removed in a future major version of Arc.' -f ([IO.Path]::GetFullPath($ConfigurationPath)))
    }
    else
    {
        $ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\whiskey.yml'
    }
}

$ConfigurationPath = Resolve-Path -LiteralPath $ConfigurationPath
if( -not $ConfigurationPath )
{
    exit 1
}

$optionalParams = @{ }
if( $Clean )
{
    $optionalParams['Clean'] = $true
}

if( $Initialize )
{
    $optionalParams['Initialize'] = $true
}

[Whiskey.Context]$context = New-WhsWhiskeyContext -Environment $Environment -ConfigurationPath $ConfigurationPath

if( $MSBuildConfiguration )
{
    Set-WhiskeyMSBuildConfiguration -Context $context -Value $MSBuildConfiguration
}

if( $context.ByDeveloper )
{
    $context.BuildMetadata.ScmBranch = git -C $context.BuildRoot rev-parse --abbrev-ref HEAD 2>$null
}
else
{
    Get-ChildItem 'env:' | Out-String
}

if( $PipelineName )
{
    $optionalParams['PipelineName'] = $PipelineName
}

Invoke-WhiskeyBuild -Context $context @optionalParams

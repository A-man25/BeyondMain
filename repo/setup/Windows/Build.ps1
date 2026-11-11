# BeyondMain | Windows portable build / generator
# No absolute machine-specific paths are stored in this file.
[CmdletBinding()]
param(
    [ValidateSet('Build','Generate','Clean')][string]$Mode = 'Build',
    [ValidateSet('Debug','Release')][string]$Configuration = 'Debug'
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$PremakeHome = Join-Path $Repo 'build\build'
$PremakeLua = Join-Path $PremakeHome 'premake5.lua'
$SolutionHome = Join-Path $Repo 'proj'

function Die([string]$Message) { throw "[BeyondMain] $Message" }
function Require-File([string]$Path, [string]$Description) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Die "$Description missing: $Path" }
}
function Get-VSInfo {
    $programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
    $locator = Join-Path $programFilesX86 'Microsoft Visual Studio\Installer\vswhere.exe'
    Require-File $locator 'Visual Studio locator (vswhere.exe)'
    $root = @(& $locator -latest -products '*' -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath) | Select-Object -First 1
    if (-not $root) { Die 'MSVC Build Tools not found. Run Setup\SetupWindows.bat.' }
    $version = @(& $locator -latest -products '*' -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationVersion) | Select-Object -First 1
    $major = [int](($version -split '\.')[0])
    if ($major -lt 17) { Die "Visual Studio version $version is too old for this setup." }
    $action = if ($major -ge 18) { 'vs2026' } else { 'vs2022' }
    $msbuild = Join-Path $root 'MSBuild\Current\Bin\MSBuild.exe'
    Require-File $msbuild 'MSBuild.exe'
    return @{ Root=$root; Version=$version; Action=$action; MSBuild=$msbuild }
}
function Get-Premake([string]$Action) {
    $localExe = Join-Path $PremakeHome 'premake5.exe'
    $downloadExe = Join-Path $Repo '.beyondmain\tools\premake5.exe'
    $candidates = @()
    if (Test-Path -LiteralPath $localExe -PathType Leaf) { $candidates += $localExe }
    if (Test-Path -LiteralPath $downloadExe -PathType Leaf) { $candidates += $downloadExe }
    $cmd = Get-Command 'premake5.exe' -ErrorAction SilentlyContinue
    if ($cmd) { $candidates += $cmd.Source }
    foreach ($candidate in $candidates) {
        $helpText = (& $candidate --help 2>&1 | Out-String)
        if ($helpText -match "(?m)^\s*$Action\b") { return $candidate }
    }
    # Download a pinned official Premake executable only when necessary.
    # Official release SHA-256: https://github.com/premake/premake-core/releases/tag/v5.0.0
    $url = 'https://github.com/premake/premake-core/releases/download/v5.0.0/premake-5.0.0-windows.zip'
    $expected = '15e63506eed5dfd526b96c8e957a7feff2be6cfe70f46e353bfe4813b82e2fdc'
    $toolDir = Join-Path $Repo '.beyondmain\tools'
    New-Item -ItemType Directory -Path $toolDir -Force | Out-Null
    $archive = Join-Path $toolDir 'premake-windows.zip'
    Write-Host '[BeyondMain] Downloading official Premake v5.0.0 ...'
    Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { Remove-Item -LiteralPath $archive -Force; Die 'Premake archive SHA-256 mismatch. Refusing extraction.' }
    Expand-Archive -LiteralPath $archive -DestinationPath $toolDir -Force
    Remove-Item -LiteralPath $archive -Force
    Require-File $downloadExe 'Downloaded Premake'
    $helpText = (& $downloadExe --help 2>&1 | Out-String)
    if ($helpText -notmatch "(?m)^\s*$Action\b") { Die "Premake does not support $Action. Update Premake." }
    return $downloadExe
}
function Get-Solution([string]$Action) {
    $choices = if ($Action -eq 'vs2026') {
        @('BeyondMain.slnx')
    } else {
        @('BeyondMain.sln')
    }
    foreach ($name in $choices) {
        $path = Join-Path $SolutionHome $name
        if (Test-Path -LiteralPath $path -PathType Leaf) { return $path }
    }
    return $null
}
function Generate-Projects([string]$Action) {
    Require-File $PremakeLua 'Premake configuration'
    $premake = Get-Premake $Action
    Write-Host "[BeyondMain] Generating $Action projects ..."
    Push-Location $PremakeHome
    try {
        & $premake $Action
        if ($LASTEXITCODE -ne 0) { Die "Premake failed (exit $LASTEXITCODE)." }
    }
    finally { Pop-Location }
    $solution = Get-Solution $Action
    if (-not $solution) { Die "Generation finished but repo\proj\BeyondMain.sln[x] was not found. Check location/target name in premake5.lua." }
    return $solution
}

try {
    Write-Host "[BeyondMain] Repository: $Repo"
    $vs = Get-VSInfo
    Write-Host "[BeyondMain] Visual Studio $($vs.Version) found"
    $solution = Get-Solution $vs.Action
    if ($Mode -eq 'Generate' -or -not $solution) { $solution = Generate-Projects $vs.Action }
    if ($Mode -eq 'Generate') { Write-Host '[BeyondMain] Generation complete.'; exit 0 }
    $target = if ($Mode -eq 'Clean') { 'Clean' } else { 'Build' }
    Write-Host "[BeyondMain] $target $Configuration|x64 : $solution"
    & $vs.MSBuild $solution "/t:$target" "/p:Configuration=$Configuration" '/p:Platform=x64' '/m' '/verbosity:minimal' '/nologo'
    if ($LASTEXITCODE -ne 0) { Die "MSBuild failed (exit $LASTEXITCODE)." }
    if ($Mode -eq 'Build' -and $Configuration -eq 'Debug') {
        $exe = Join-Path $Repo 'build\bin\Debug-x64\BeyondMain.exe'
        if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
            Write-Warning "Debug executable not at expected location: $exe. Update .vscode\launch.json if your Premake targetdir differs."
        }
    }
    Write-Host "[BeyondMain] $target succeeded."
    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}

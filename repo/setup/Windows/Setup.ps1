# BeyondMain | One-time / repeatable Windows setup
$ErrorActionPreference = 'Stop'
$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Build = Join-Path $PSScriptRoot 'Build.ps1'

function Find-VSWhere {
    $pfx86 = [Environment]::GetFolderPath('ProgramFilesX86')
    return (Join-Path $pfx86 'Microsoft Visual Studio\Installer\vswhere.exe')
}
function Has-MSVC {
    $locator = Find-VSWhere
    if (-not (Test-Path -LiteralPath $locator)) { return $false }
    $path = @(& $locator -latest -products '*' -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath) | Select-Object -First 1
    return -not [string]::IsNullOrWhiteSpace($path)
}
function Get-CodeCLI {
    $cmd = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $possible = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),
        (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd')
    )
    foreach ($item in $possible) {
        if (Test-Path -LiteralPath $item -PathType Leaf) { return $item }
    }
    return $null
}
function Invoke-Winget([string[]]$CommandArgs) {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) { throw 'winget is unavailable. Install the missing tools via the official installers, then rerun setup.' }
    & $winget.Source @CommandArgs
    if ($LASTEXITCODE -ne 0) { throw "winget failed (exit $LASTEXITCODE). Check installer prompts/restart requirements and rerun." }
}
try {
    Write-Host "`n=== BEYONDMAIN | WINDOWS SETUP ==="
    Write-Host "Repo: $Repo"
    if (-not (Has-MSVC)) {
        Write-Host '[1/4] MSVC Build Tools missing.'
        Write-Host 'This is a large Microsoft installation and may require administrator approval.'
        $answer = Read-Host 'Install MSVC Build Tools automatically via winget? [Y/n]'
        if ($answer -and $answer -notmatch '^[Yy]') { throw 'Install Visual Studio Build Tools (Desktop development with C++) and rerun.' }
        Invoke-Winget -CommandArgs @('install','--id','Microsoft.VisualStudio.BuildTools','-e','--source','winget','--accept-package-agreements','--accept-source-agreements','--override','--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
        if (-not (Has-MSVC)) { throw 'MSVC not detected after installation. Restart Windows if prompted, then rerun this setup.' }
    } else { Write-Host '[1/4] MSVC is installed.' }
    $code = Get-CodeCLI
    if (-not $code) {
        Write-Host '[2/4] VS Code not detected.'
        $answer = Read-Host 'Install VS Code automatically via winget? [Y/n]'
        if ($answer -and $answer -notmatch '^[Yy]') { throw 'Install VS Code and rerun.' }
        Invoke-Winget -CommandArgs @('install','--id','Microsoft.VisualStudioCode','-e','--source','winget','--accept-package-agreements','--accept-source-agreements')
        $code = Get-CodeCLI
        if (-not $code) { throw 'VS Code installation completed, but CLI was not found. Reopen terminal or rerun after installation.' }
    } else { Write-Host '[2/4] VS Code found.' }
    if ((Test-Path -LiteralPath (Join-Path $Repo '.gitmodules')) -and (Get-Command git.exe -ErrorAction SilentlyContinue)) {
        Write-Host '[BeyondMain] Initializing required Git submodules ...'
        & git.exe -C $Repo submodule update --init --recursive
        if ($LASTEXITCODE -ne 0) { throw 'Git submodule initialization failed. Check network access and git credentials.' }
    }
    Write-Host '[3/4] Generating/building with Premake + MSBuild ...'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Build -Mode Build -Configuration Debug
    if ($LASTEXITCODE -ne 0) { throw 'Build failed. Read messages above for the exact compiler or Premake error.' }
    Write-Host '[4/4] Installing VS Code C/C++ extension ...'
    & $code --install-extension ms-vscode.cpptools --force
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Extension installation did not complete. Install Microsoft C/C++ from VS Code Extensions.' }
    Write-Host '[BeyondMain] Opening repository in VS Code ...'
    & $code $Repo
    Write-Host '[SUCCESS] Setup complete. Ctrl+Shift+B builds; F5 with the Windows debug profile debugs.'
    exit 0
}
catch {
    [Console]::Error.WriteLine('[BeyondMain] ' + $_.Exception.Message)
    exit 1
}

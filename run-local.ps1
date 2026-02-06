Param(
  [ValidateSet("smoke", "install", "uninstall", "build")]
  [string]$Action = "smoke"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$required = @(
  "install.bat",
  "uninstall.bat",
  "menu-template.reg",
  "README.md",
  "icons",
  "scripts"
)

function Assert-RequiredItems {
  foreach ($item in $required) {
    $path = Join-Path $root $item
    if (-not (Test-Path $path)) {
      throw "Missing required item: $item"
    }
  }
}

function Check-PowerShellSyntax {
  $scripts = Get-ChildItem -Path (Join-Path $root "scripts") -Filter "*.ps1" -File
  if (-not $scripts) {
    throw "No PowerShell scripts found in scripts/."
  }

  $parseErrors = @()
  foreach ($script in $scripts) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
      $script.FullName,
      [ref]$tokens,
      [ref]$errors
    )

    if ($errors -and $errors.Count -gt 0) {
      $parseErrors += $errors | ForEach-Object {
        "${($script.FullName)}:${($_.Extent.StartLineNumber)}:${($_.Extent.StartColumnNumber)} $($_.Message)"
      }
    }
  }

  if ($parseErrors.Count -gt 0) {
    $parseErrors | ForEach-Object { Write-Error $_ }
    throw "PowerShell parsing failed for $($parseErrors.Count) error(s)."
  }

  Write-Host "PowerShell syntax check passed for $($scripts.Count) script(s)."
}

switch ($Action) {
  "smoke" {
    Assert-RequiredItems
    Check-PowerShellSyntax
    Write-Host "Smoke checks passed."
  }
  "install" {
    Assert-RequiredItems
    Check-PowerShellSyntax
    $installPath = Join-Path $root "install.bat"
    Write-Host "Running install.bat..."
    Start-Process -FilePath $installPath -WorkingDirectory $root -Wait
  }
  "uninstall" {
    $uninstallPath = Join-Path $root "uninstall.bat"
    Write-Host "Running uninstall.bat..."
    Start-Process -FilePath $uninstallPath -WorkingDirectory $root -Wait
  }
  "build" {
    $buildPath = Join-Path $root "build.ps1"
    Write-Host "Running build.ps1..."
    & $buildPath
  }
}

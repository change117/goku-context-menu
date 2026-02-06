Param(
  [string]$OutputDir = "dist",
  [string]$ArchiveName = "goku-context-menu.zip"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$distPath = Join-Path $root $OutputDir
$archivePath = Join-Path $distPath $ArchiveName

$items = @(
  "install.bat",
  "uninstall.bat",
  "menu-template.reg",
  "README.md",
  "icons",
  "scripts"
)

foreach ($item in $items) {
  $fullPath = Join-Path $root $item
  if (-not (Test-Path $fullPath)) {
    throw "Missing required item: $item"
  }
}

if (-not (Test-Path $distPath)) {
  New-Item -ItemType Directory -Path $distPath | Out-Null
}

if (Test-Path $archivePath) {
  Remove-Item $archivePath -Force
}

$pathsToZip = $items | ForEach-Object { Join-Path $root $_ }
Compress-Archive -Path $pathsToZip -DestinationPath $archivePath -Force

Write-Host "Created archive: $archivePath"
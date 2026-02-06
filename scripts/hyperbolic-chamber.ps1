# Hyperbolic Time Chamber Compression System
# Advanced archive creation with space-time compression

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Paths
)

$script:ThemeColors = @{
    Chamber = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Info = 'White'
    Metric = 'Magenta'
}

function Show-ChamberEntrance {
    $entranceArt = @'

    🌀═══════════════════════════════════════════🌀
      H Y P E R B O L I C   T I M E   C H A M B E R
    🌀═══════════════════════════════════════════🌀
       >> Space-Time Compression Initialized <<
    ═════════════════════════════════════════════

'@
    Write-Host $entranceArt -ForegroundColor $script:ThemeColors.Chamber
}

function Get-ValidTargets {
    param([string[]]$TargetPaths)
    
    $validList = @()
    
    Write-Host "📦 Preparing items for chamber entry:" -ForegroundColor $script:ThemeColors.Info
    
    foreach ($targetPath in $TargetPaths) {
        if (Test-Path -LiteralPath $targetPath) {
            $itemData = Get-Item -LiteralPath $targetPath -Force
            $validList += @{
                Path = $targetPath
                Object = $itemData
                IsFolder = $itemData.PSIsContainer
            }
            
            $icon = if ($itemData.PSIsContainer) { "📁" } else { "📄" }
            $sizeInfo = if (-not $itemData.PSIsContainer) {
                $sizeKB = [math]::Round($itemData.Length / 1KB, 2)
                " ($sizeKB KB)"
            } else {
                ""
            }
            
            Write-Host ("  {0} {1}{2}" -f $icon, $itemData.Name, $sizeInfo) -ForegroundColor $script:ThemeColors.Chamber
        }
    }
    
    return $validList
}

function Request-ArchiveConfiguration {
    param($SourceItems)
    
    $firstSource = $SourceItems[0].Object
    $parentDirectory = if ($firstSource.PSIsContainer) {
        $firstSource.Parent.FullName
    } else {
        $firstSource.Directory.FullName
    }
    
    $defaultArchiveName = if ($SourceItems.Count -eq 1) {
        $firstSource.BaseName
    } else {
        "Compressed_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    }
    
    Write-Host ""
    Write-Host "💾 Archive Configuration:" -ForegroundColor $script:ThemeColors.Success
    $archiveName = Read-Host "  Enter archive name (default: $defaultArchiveName)"
    
    if ([string]::IsNullOrWhiteSpace($archiveName)) {
        $archiveName = $defaultArchiveName
    }
    
    if (-not $archiveName.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)) {
        $archiveName += '.zip'
    }
    
    $fullArchivePath = Join-Path $parentDirectory $archiveName
    
    return @{
        Path = $fullArchivePath
        Name = $archiveName
        Directory = $parentDirectory
    }
}

function Test-ArchiveConflict {
    param($ArchiveConfig)
    
    if (Test-Path -LiteralPath $ArchiveConfig.Path) {
        Write-Host ""
        Write-Host ("⚠️  Archive exists: {0}" -f $ArchiveConfig.Name) -ForegroundColor $script:ThemeColors.Warning
        $response = Read-Host "  Replace existing archive? (Y/N)"
        
        if ($response -eq 'Y' -or $response -eq 'y') {
            Remove-Item -LiteralPath $ArchiveConfig.Path -Force
            return $true
        }
        return $false
    }
    return $true
}

function Measure-OriginalSize {
    param($SourceItems)
    
    [long]$totalSize = 0
    
    foreach ($source in $SourceItems) {
        if ($source.IsFolder) {
            $folderFiles = Get-ChildItem -LiteralPath $source.Path -File -Recurse -Force -ErrorAction SilentlyContinue
            $folderSize = ($folderFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($null -ne $folderSize) {
                $totalSize += $folderSize
            }
        } else {
            $totalSize += $source.Object.Length
        }
    }
    
    return $totalSize
}

function New-TemporaryChamber {
    $chamberPath = Join-Path $env:TEMP ("Chamber_" + (Get-Date -Format 'yyyyMMddHHmmss'))
    New-Item -ItemType Directory -Path $chamberPath -Force | Out-Null
    return $chamberPath
}

function Copy-ItemsToChamber {
    param(
        [array]$Sources,
        [string]$ChamberPath
    )
    
    foreach ($source in $Sources) {
        $targetPath = Join-Path $ChamberPath $source.Object.Name
        
        if ($source.IsFolder) {
            Copy-Item -LiteralPath $source.Path -Destination $targetPath -Recurse -Force -ErrorAction Stop
        } else {
            Copy-Item -LiteralPath $source.Path -Destination $targetPath -Force -ErrorAction Stop
        }
    }
}

function Invoke-CompressionSequence {
    param(
        [array]$SourceItems,
        [hashtable]$ArchiveConfig
    )
    
    Write-Host ""
    Write-Host "🌀 Entering chamber dimensions..." -ForegroundColor $script:ThemeColors.Chamber
    Write-Host "   (Compression in progress - standby)" -ForegroundColor DarkGray
    
    $temporaryChamber = New-TemporaryChamber
    
    try {
        Copy-ItemsToChamber -Sources $SourceItems -ChamberPath $temporaryChamber
        
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
        
        [System.IO.Compression.ZipFile]::CreateFromDirectory(
            $temporaryChamber,
            $ArchiveConfig.Path,
            [System.IO.Compression.CompressionLevel]::Optimal,
            $false
        )
        
        return $true
        
    } catch {
        Write-Host ""
        Write-Host ("❌ Compression failed: {0}" -f $_.Exception.Message) -ForegroundColor $script:ThemeColors.Warning
        return $false
        
    } finally {
        if (Test-Path $temporaryChamber) {
            Remove-Item -LiteralPath $temporaryChamber -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-CompressionMetrics {
    param(
        [long]$OriginalBytes,
        [string]$ArchivePath
    )
    
    $archiveItem = Get-Item -LiteralPath $ArchivePath
    $compressedBytes = $archiveItem.Length
    
    $reductionPercent = if ($OriginalBytes -gt 0) {
        [math]::Round((1 - ($compressedBytes / $OriginalBytes)) * 100, 2)
    } else {
        0
    }
    
    $originalMB = [math]::Round($OriginalBytes / 1MB, 2)
    $compressedMB = [math]::Round($compressedBytes / 1MB, 2)
    
    Write-Host ""
    Write-Host "✓ Chamber training complete!" -ForegroundColor $script:ThemeColors.Success
    Write-Host ""
    Write-Host "📊 Compression Analytics:" -ForegroundColor $script:ThemeColors.Metric
    Write-Host ("  Original   : {0:N2} MB" -f $originalMB) -ForegroundColor $script:ThemeColors.Info
    Write-Host ("  Compressed : {0:N2} MB" -f $compressedMB) -ForegroundColor $script:ThemeColors.Info
    Write-Host ("  Reduction  : {0}%" -f $reductionPercent) -ForegroundColor $script:ThemeColors.Success
    Write-Host ("  Location   : {0}" -f $ArchivePath) -ForegroundColor $script:ThemeColors.Info
    
    # Training multiplier easter egg
    if ($reductionPercent -gt 0) {
        $multiplier = [math]::Floor(100 / (100 - $reductionPercent))
        if ($multiplier -gt 1) {
            Write-Host ""
            Write-Host ("🥋 Training Efficiency: {0}x multiplier" -f $multiplier) -ForegroundColor $script:ThemeColors.Metric
            Write-Host ("   Space saved equals {0} days of training!" -f $multiplier) -ForegroundColor DarkGray
        }
    }
}

function Open-ArchiveLocation {
    param([string]$ArchivePath)
    
    Write-Host ""
    Write-Host "📂 Revealing archive location..." -ForegroundColor $script:ThemeColors.Info
    Start-Process 'explorer.exe' -ArgumentList ("/select,`"$ArchivePath`"")
}

# Main chamber sequence
try {
    Show-ChamberEntrance
    
    $validSources = Get-ValidTargets -TargetPaths $Paths
    
    if ($validSources.Count -eq 0) {
        Write-Host ""
        Write-Host "❌ No valid items to compress!" -ForegroundColor $script:ThemeColors.Warning
        Start-Sleep -Seconds 2
        exit 0
    }
    
    $archiveSettings = Request-ArchiveConfiguration -SourceItems $validSources
    
    $canProceed = Test-ArchiveConflict -ArchiveConfig $archiveSettings
    if (-not $canProceed) {
        Write-Host ""
        Write-Host "❌ Operation cancelled" -ForegroundColor $script:ThemeColors.Warning
        Start-Sleep -Seconds 2
        exit 0
    }
    
    $originalSize = Measure-OriginalSize -SourceItems $validSources
    
    $compressionSuccess = Invoke-CompressionSequence -SourceItems $validSources -ArchiveConfig $archiveSettings
    
    if ($compressionSuccess) {
        Show-CompressionMetrics -OriginalBytes $originalSize -ArchivePath $archiveSettings.Path
        Open-ArchiveLocation -ArchivePath $archiveSettings.Path
    }
    
    Write-Host ""
    Write-Host "[Press any key to exit chamber]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host ""
    Write-Host ("⚠ Chamber Error: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

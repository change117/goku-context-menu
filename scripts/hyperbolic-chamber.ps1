# Archive Compression Facility
# Time chamber themed file packaging system

param([string[]]$Items)

$cfg = @{
    Colors = @{ Core='Cyan'; Win='Green'; Warn='Yellow'; Text='White'; Stat='Magenta' }
    Intro = @'

    🌀═══ TIME CHAMBER COMPRESSION ═══🌀
         Spatial reduction active
    
'@
}

Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

function Collect-ValidSources {
    param($list)
    
    $collection = @()
    
    Write-Host "📦 Items for compression:" -Fore $cfg.Colors.Text
    
    foreach ($entry in $list) {
        if (Test-Path -LiteralPath $entry) {
            $obj = Get-Item -LiteralPath $entry -Force
            $collection += @{
                Loc = $entry
                Obj = $obj
                Dir = $obj.PSIsContainer
            }
            
            $icon = if ($obj.PSIsContainer) { "📁" } else { "📄" }
            $detail = if (-not $obj.PSIsContainer) {
                $kb = [math]::Round($obj.Length / 1KB, 2)
                " ($kb KB)"
            } else { "" }
            
            Write-Host ("  {0} {1}{2}" -f $icon, $obj.Name, $detail) -Fore $cfg.Colors.Core
        }
    }
    
    return $collection
}

function Request-ArchiveName {
    param($sources)
    
    $first = $sources[0].Obj
    $folder = if ($first.PSIsContainer) {
        $first.Parent.FullName
    } else {
        $first.Directory.FullName
    }
    
    $suggestion = if ($sources.Count -eq 1) {
        $first.BaseName
    } else {
        "Archive_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    }
    
    Write-Host ""
    Write-Host "💾 Archive naming:" -Fore $cfg.Colors.Win
    $input = Read-Host "  Name (default: $suggestion)"
    
    $final = if ([string]::IsNullOrWhiteSpace($input)) { $suggestion } else { $input }
    
    if (-not $final.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)) {
        $final += '.zip'
    }
    
    return @{
        FullPath = Join-Path $folder $final
        Name = $final
        Folder = $folder
    }
}

function Handle-Collision {
    param($config)
    
    if (Test-Path -LiteralPath $config.FullPath) {
        Write-Host ""
        Write-Host ("⚠️  File exists: {0}" -f $config.Name) -Fore $cfg.Colors.Warn
        $choice = Read-Host "  Overwrite? (Y/N)"
        
        if ($choice -eq 'Y' -or $choice -eq 'y') {
            Remove-Item -LiteralPath $config.FullPath -Force
            return $true
        }
        return $false
    }
    return $true
}

function Measure-TotalVolume {
    param($sources)
    
    [long]$total = 0
    
    foreach ($src in $sources) {
        if ($src.Dir) {
            $files = Get-ChildItem -LiteralPath $src.Loc -File -Recurse -Force -EA SilentlyContinue
            $volume = ($files | Measure-Object -Property Length -Sum -EA SilentlyContinue).Sum
            if ($null -ne $volume) { $total += $volume }
        } else {
            $total += $src.Obj.Length
        }
    }
    
    return $total
}

function Create-StagingArea {
    $path = Join-Path $env:TEMP ("Staging_" + (Get-Date -Format 'yyyyMMddHHmmss'))
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}

function Stage-Content {
    param($sources, $staging)
    
    foreach ($src in $sources) {
        $dest = Join-Path $staging $src.Obj.Name
        
        if ($src.Dir) {
            Copy-Item -LiteralPath $src.Loc -Destination $dest -Recurse -Force -EA Stop
        } else {
            Copy-Item -LiteralPath $src.Loc -Destination $dest -Force -EA Stop
        }
    }
}

function Perform-Compression {
    param($sources, $config)
    
    Write-Host ""
    Write-Host "🌀 Compressing spatial data..." -Fore $cfg.Colors.Core
    Write-Host "   (Processing - please wait)" -Fore DarkGray
    
    $staging = Create-StagingArea
    
    try {
        Stage-Content -sources $sources -staging $staging
        
        [IO.Compression.ZipFile]::CreateFromDirectory(
            $staging,
            $config.FullPath,
            [IO.Compression.CompressionLevel]::Optimal,
            $false
        )
        
        return $true
    } catch {
        Write-Host ""
        Write-Host ("❌ Compression error: {0}" -f $_.Exception.Message) -Fore $cfg.Colors.Warn
        return $false
    } finally {
        if (Test-Path $staging) {
            Remove-Item -LiteralPath $staging -Recurse -Force -EA SilentlyContinue
        }
    }
}

function Display-Statistics {
    param($originalVol, $archiveLoc)
    
    $archive = Get-Item -LiteralPath $archiveLoc
    $compressedVol = $archive.Length
    
    $reduction = if ($originalVol -gt 0) {
        [math]::Round((1 - ($compressedVol / $originalVol)) * 100, 2)
    } else { 0 }
    
    $origMB = [math]::Round($originalVol / 1MB, 2)
    $compMB = [math]::Round($compressedVol / 1MB, 2)
    
    Write-Host ""
    Write-Host "✓ Compression sequence complete" -Fore $cfg.Colors.Win
    Write-Host ""
    Write-Host "📊 Results:" -Fore $cfg.Colors.Stat
    Write-Host ("  Before  : {0:N2} MB" -f $origMB) -Fore $cfg.Colors.Text
    Write-Host ("  After   : {0:N2} MB" -f $compMB) -Fore $cfg.Colors.Text
    Write-Host ("  Saved   : {0}%" -f $reduction) -Fore $cfg.Colors.Win
    Write-Host ("  Archive : {0}" -f $archiveLoc) -Fore $cfg.Colors.Text
    
    if ($reduction -gt 0) {
        $factor = [math]::Floor(100 / (100 - $reduction))
        if ($factor -gt 1) {
            Write-Host ""
            Write-Host ("🥋 Efficiency factor: {0}x" -f $factor) -Fore $cfg.Colors.Stat
            Write-Host ("   Equivalent to {0} training sessions!" -f $factor) -Fore DarkGray
        }
    }
}

function Open-Result {
    param($path)
    
    Write-Host ""
    Write-Host "📂 Opening archive folder..." -Fore $cfg.Colors.Text
    Start-Process 'explorer.exe' -ArgumentList ("/select,`"$path`"")
}

# Execute compression
try {
    Write-Host $cfg.Intro -Fore $cfg.Colors.Core
    
    $sources = Collect-ValidSources -list $Items
    
    if ($sources.Count -eq 0) {
        Write-Host ""
        Write-Host "❌ No items to compress" -Fore $cfg.Colors.Warn
        Start-Sleep 2
        exit 0
    }
    
    $archiveConfig = Request-ArchiveName -sources $sources
    
    if (-not (Handle-Collision -config $archiveConfig)) {
        Write-Host ""
        Write-Host "❌ Cancelled" -Fore $cfg.Colors.Warn
        Start-Sleep 2
        exit 0
    }
    
    $originalSize = Measure-TotalVolume -sources $sources
    
    $success = Perform-Compression -sources $sources -config $archiveConfig
    
    if ($success) {
        Display-Statistics -originalVol $originalSize -archiveLoc $archiveConfig.FullPath
        Open-Result -path $archiveConfig.FullPath
    }
    
    Write-Host ""
    Write-Host "[Press any key]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host ""
    Write-Host ("⚠ System error: {0}" -f $_.Exception.Message) -Fore Red
    Start-Sleep 2
    exit 1
}

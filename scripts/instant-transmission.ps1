# Spatial Relocation Engine
# Quantum file transfer to predefined zones

param([string[]]$Sources)

$env = @{
    Theme = @{ Portal='Magenta'; Pass='Green'; Alert='Yellow'; Fail='Red'; Data='Cyan' }
    Title = @'

    ✨═══ QUANTUM TELEPORTATION ═══✨
       Dimensional Transfer Active
    
'@
}

function Build-ZoneRegistry {
    $shell = New-Object -ComObject Shell.Application
    
    return [ordered]@{
        '1' = @{ Tag="Desktop Sector"; Dir=[Environment]::GetFolderPath("Desktop") }
        '2' = @{ Tag="Document Vault"; Dir=[Environment]::GetFolderPath("MyDocuments") }
        '3' = @{ Tag="Download Bay"; Dir=$shell.NameSpace('shell:Downloads').Self.Path }
        '4' = @{ Tag="Image Gallery"; Dir=[Environment]::GetFolderPath("MyPictures") }
        '5' = @{ Tag="Video Archive"; Dir=[Environment]::GetFolderPath("MyVideos") }
        '6' = @{ Tag="Audio Chamber"; Dir=[Environment]::GetFolderPath("MyMusic") }
    }
}

function Display-SourceItems {
    param($items)
    
    Write-Host "`n📦 Items queued for transport:" -Fore $env.Theme.Data
    
    $valid = 0
    foreach ($src in $items) {
        if (Test-Path -LiteralPath $src) {
            $obj = Get-Item -LiteralPath $src -Force
            Write-Host "  ► $($obj.Name)" -Fore $env.Theme.Portal
            $valid++
        }
    }
    return $valid
}

function Render-ZoneOptions {
    param($registry)
    
    Write-Host "`n🌟 Available zones:" -Fore $env.Theme.Pass
    
    foreach ($k in $registry.Keys) {
        $zone = $registry[$k]
        Write-Host ("  [{0}] {1}" -f $k, $zone.Tag) -Fore White
        Write-Host ("      → {0}" -f $zone.Dir) -Fore DarkGray
    }
}

function Generate-UniquePath {
    param($original, $destFolder)
    
    $item = Get-Item -LiteralPath $original
    $proposed = $item.Name
    $target = Join-Path $destFolder $proposed
    
    $idx = 1
    while (Test-Path -LiteralPath $target) {
        if ($item.PSIsContainer) {
            $proposed = "$($item.BaseName)_$idx"
        } else {
            $name = [IO.Path]::GetFileNameWithoutExtension($item.Name)
            $ext = $item.Extension
            $proposed = "${name}_${idx}${ext}"
        }
        $target = Join-Path $destFolder $proposed
        $idx++
    }
    
    return $target
}

function Execute-Transfer {
    param($sources, $zone)
    
    Write-Host "`n✨ Quantum transfer initiated..." -Fore $env.Theme.Portal
    Write-Host ("   Destination: {0}" -f $zone.Tag) -Fore $env.Theme.Data
    
    $metrics = @{ Moved=0; Failed=0 }
    
    foreach ($src in $sources) {
        if (-not (Test-Path -LiteralPath $src)) { continue }
        
        try {
            $item = Get-Item -LiteralPath $src -Force
            $dest = Generate-UniquePath -original $src -destFolder $zone.Dir
            
            Move-Item -LiteralPath $src -Destination $dest -Force -EA Stop
            
            $destName = Split-Path -Leaf $dest
            Write-Host ("  ✓ {0} → {1}" -f $item.Name, $destName) -Fore $env.Theme.Pass
            $metrics.Moved++
        } catch {
            Write-Host ("  ✗ Failed: {0}" -f $item.Name) -Fore $env.Theme.Fail
            Write-Host ("    {0}" -f $_.Exception.Message) -Fore DarkRed
            $metrics.Failed++
        }
    }
    
    return $metrics
}

function Display-TransferStats {
    param($stats, $zone)
    
    Write-Host "`n════════════════════════════════" -Fore $env.Theme.Portal
    Write-Host "✨ Transfer sequence complete" -Fore $env.Theme.Pass
    Write-Host "════════════════════════════════" -Fore $env.Theme.Portal
    Write-Host ("  Transferred: {0}" -f $stats.Moved) -Fore $env.Theme.Pass
    Write-Host ("  Errors: {0}" -f $stats.Failed) -Fore $env.Theme.Alert
    
    if ($stats.Moved -gt 0) {
        Write-Host "`n📂 Opening destination..." -Fore $env.Theme.Data
        Start-Process 'explorer.exe' -ArgumentList $zone.Dir
    }
}

# Main execution
try {
    Write-Host $env.Title -Fore $env.Theme.Portal
    
    $count = Display-SourceItems -items $Sources
    
    if ($count -eq 0) {
        Write-Host "`n⚠ No valid items for transfer" -Fore $env.Theme.Alert
        Start-Sleep 2
        exit 0
    }
    
    $zones = Build-ZoneRegistry
    Render-ZoneOptions -registry $zones
    
    $selection = Read-Host "`nSelect zone (1-6)"
    
    if ($zones.ContainsKey($selection)) {
        $targetZone = $zones[$selection]
        $outcome = Execute-Transfer -sources $Sources -zone $targetZone
        Display-TransferStats -stats $outcome -zone $targetZone
    } else {
        Write-Host "`n❌ Invalid zone selection" -Fore $env.Theme.Fail
    }
    
    Write-Host "`n[Press any key]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "`n⚠ Transfer error: $($_.Exception.Message)" -Fore Red
    Start-Sleep 2
    exit 1
}

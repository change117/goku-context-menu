# Destructive Energy Wave System
# File elimination with safety protocols

param([string[]]$Targets)

$ctx = @{
    Palette = @{ Wave='Blue'; Danger='Red'; Glow='Cyan'; Win='Green'; Neu='Yellow' }
    Header = @'

    ═══ ENERGY WAVE ELIMINATION ═══
        Kamehameha Charging...
    
'@
}

function Build-TargetManifest {
    param($list)
    
    $manifest = @()
    foreach ($entry in $list) {
        if (Test-Path -LiteralPath $entry) {
            $obj = Get-Item -LiteralPath $entry -Force
            $manifest += [PSCustomObject]@{
                Location = $entry
                Label = $obj.Name
                Folder = $obj.PSIsContainer
                Bytes = if ($obj.PSIsContainer) { 0 } else { $obj.Length }
            }
        }
    }
    return $manifest
}

function Render-TargetDisplay {
    param($manifest)
    
    Write-Host "`n🎯 Targets in range:" -Fore $ctx.Palette.Neu
    
    foreach ($item in $manifest) {
        $glyph = if ($item.Folder) { "📁" } else { "📄" }
        $metric = if ($item.Bytes -gt 0) {
            $kb = [math]::Round($item.Bytes / 1KB, 2)
            "($kb KB)"
        } else { "(Folder)" }
        
        Write-Host "  $glyph $($item.Label) $metric" -Fore $ctx.Palette.Glow
    }
}

function Get-SafetyConfirmation {
    Write-Host "`n⚠️  CRITICAL: IRREVERSIBLE DESTRUCTION ⚠️" -Fore $ctx.Palette.Danger
    Write-Host "Safety protocol requires exact phrase entry" -Fore $ctx.Palette.Neu
    
    $input = Read-Host "`nType 'KAMEHAMEHA' to proceed"
    return ($input -ceq "KAMEHAMEHA")
}

function Execute-Obliteration {
    param($manifest)
    
    Write-Host "`n⚡ Energy concentration..." -Fore $ctx.Palette.Wave
    Start-Sleep -Milliseconds 250
    
    $sequence = @("KA", "ME", "HA", "ME")
    foreach ($syllable in $sequence) {
        Write-Host "⚡ $syllable..." -Fore $ctx.Palette.Wave -NoNewline
        Start-Sleep -Milliseconds 180
    }
    Write-Host "HAAAAAA!" -Fore $ctx.Palette.Glow
    
    $stats = @{ Success=0; Fail=0; Errors=@() }
    
    foreach ($target in $manifest) {
        try {
            if (Test-Path -LiteralPath $target.Location) {
                Remove-Item -LiteralPath $target.Location -Recurse -Force -EA Stop
                Write-Host "  ✓ Eliminated: $($target.Label)" -Fore $ctx.Palette.Win
                $stats.Success++
            }
        } catch {
            Write-Host "  ✗ Resisted: $($target.Label)" -Fore $ctx.Palette.Danger
            $stats.Fail++
            $stats.Errors += $_.Exception.Message
        }
    }
    
    return $stats
}

function Display-Results {
    param($outcome)
    
    Write-Host "`n═══════════════════════════════" -Fore $ctx.Palette.Wave
    Write-Host "💥 Wave execution finished" -Fore $ctx.Palette.Win
    Write-Host "═══════════════════════════════" -Fore $ctx.Palette.Wave
    Write-Host "  Eliminated: $($outcome.Success)" -Fore $ctx.Palette.Win
    Write-Host "  Protected: $($outcome.Fail)" -Fore $ctx.Palette.Danger
    
    if ($outcome.Errors.Count -gt 0) {
        Write-Host "`n⚠ Error log:" -Fore $ctx.Palette.Neu
        $outcome.Errors | ForEach-Object { Write-Host "    • $_" -Fore $ctx.Palette.Danger }
    }
}

# Execute
try {
    Write-Host $ctx.Header -Fore $ctx.Palette.Wave
    
    $manifest = Build-TargetManifest -list $Targets
    
    if ($manifest.Count -eq 0) {
        Write-Host "`n⚠ No valid targets detected" -Fore $ctx.Palette.Danger
        Start-Sleep 2
        exit 0
    }
    
    Render-TargetDisplay -manifest $manifest
    
    if (Get-SafetyConfirmation) {
        $result = Execute-Obliteration -manifest $manifest
        Display-Results -outcome $result
    } else {
        Write-Host "`n🛡️ Wave cancelled - all targets safe" -Fore $ctx.Palette.Neu
    }
    
    Write-Host "`n[Press any key]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "`n⚠ Error: $($_.Exception.Message)" -Fore Red
    Start-Sleep 2
    exit 1
}

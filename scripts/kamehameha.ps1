# Kamehameha Deletion System
# Secure file obliteration with energy wave confirmation

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Paths
)

$script:ColorScheme = @{
    Wave = 'Blue'
    Alert = 'Red'
    Charge = 'Cyan'
    Victory = 'Green'
    Neutral = 'Yellow'
}

function Write-EnergyWaveHeader {
    $headerArt = @'

    ═══════════════════════════════════════════════
         K A M E H A M E H A   S Y S T E M
    ═══════════════════════════════════════════════
         ⚡ DESTRUCTIVE WAVE GENERATOR ⚡
    ═══════════════════════════════════════════════

'@
    Write-Host $headerArt -ForegroundColor $script:ColorScheme.Wave
}

function Get-TargetInformation {
    param([string[]]$TargetList)
    
    $targetData = @()
    foreach ($targetPath in $TargetList) {
        if (Test-Path -LiteralPath $targetPath) {
            $itemData = Get-Item -LiteralPath $targetPath -Force
            $info = [PSCustomObject]@{
                Path = $targetPath
                Name = $itemData.Name
                IsDirectory = $itemData.PSIsContainer
                Size = if ($itemData.PSIsContainer) { 0 } else { $itemData.Length }
            }
            $targetData += $info
        }
    }
    return $targetData
}

function Show-TargetList {
    param([array]$Targets)
    
    Write-Host "`n🎯 Locked-on Targets:" -ForegroundColor $script:ColorScheme.Neutral
    
    foreach ($target in $Targets) {
        $icon = if ($target.IsDirectory) { "📁" } else { "📄" }
        $sizeDisplay = if ($target.Size -gt 0) {
            $kb = [math]::Round($target.Size / 1KB, 2)
            "($kb KB)"
        } else {
            "(Directory)"
        }
        Write-Host "  $icon $($target.Name) $sizeDisplay" -ForegroundColor $script:ColorScheme.Charge
    }
}

function Request-WaveConfirmation {
    Write-Host "`n" -NoNewline
    Write-Host "⚠️  DANGER ZONE ACTIVATED ⚠️" -ForegroundColor $script:ColorScheme.Alert
    Write-Host "Unleashing this energy wave will permanently destroy all targets!" -ForegroundColor $script:ColorScheme.Neutral
    Write-Host "`nSafety Protocol: Type the exact phrase 'KAMEHAMEHA' to proceed" -ForegroundColor $script:ColorScheme.Neutral
    
    $userInput = Read-Host "`nConfirmation"
    return ($userInput -ceq "KAMEHAMEHA")
}

function Invoke-EnergyWave {
    param([array]$Targets)
    
    Write-Host "`n⚡ Charging energy..." -ForegroundColor $script:ColorScheme.Wave
    Start-Sleep -Milliseconds 300
    Write-Host "⚡ KA..." -ForegroundColor $script:ColorScheme.Wave -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host "ME..." -ForegroundColor $script:ColorScheme.Wave -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host "HA..." -ForegroundColor $script:ColorScheme.Wave -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host "ME..." -ForegroundColor $script:ColorScheme.Wave -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host "HAAAAAA!" -ForegroundColor $script:ColorScheme.Charge
    
    $results = @{
        Destroyed = 0
        Failed = 0
        Errors = @()
    }
    
    foreach ($target in $Targets) {
        try {
            if (Test-Path -LiteralPath $target.Path) {
                Remove-Item -LiteralPath $target.Path -Recurse -Force -ErrorAction Stop
                Write-Host "  ✓ Obliterated: $($target.Name)" -ForegroundColor $script:ColorScheme.Victory
                $results.Destroyed++
            }
        } catch {
            Write-Host "  ✗ Deflected: $($target.Name)" -ForegroundColor $script:ColorScheme.Alert
            $results.Failed++
            $results.Errors += $_.Exception.Message
        }
    }
    
    return $results
}

function Show-BattleReport {
    param($Results)
    
    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor $script:ColorScheme.Wave
    Write-Host "💥 ENERGY WAVE COMPLETE!" -ForegroundColor $script:ColorScheme.Victory
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor $script:ColorScheme.Wave
    Write-Host "  Obliterated: $($Results.Destroyed)" -ForegroundColor $script:ColorScheme.Victory
    Write-Host "  Survived: $($Results.Failed)" -ForegroundColor $script:ColorScheme.Alert
    
    if ($Results.Errors.Count -gt 0) {
        Write-Host "`n⚠ Deflection Details:" -ForegroundColor $script:ColorScheme.Neutral
        foreach ($err in $Results.Errors) {
            Write-Host "    • $err" -ForegroundColor $script:ColorScheme.Alert
        }
    }
}

# Execute deletion sequence
try {
    Write-EnergyWaveHeader
    
    $targetObjects = Get-TargetInformation -TargetList $Paths
    
    if ($targetObjects.Count -eq 0) {
        Write-Host "`n⚠ No valid targets detected!" -ForegroundColor $script:ColorScheme.Alert
        Start-Sleep -Seconds 2
        exit 0
    }
    
    Show-TargetList -Targets $targetObjects
    
    $confirmed = Request-WaveConfirmation
    
    if ($confirmed) {
        $battleResults = Invoke-EnergyWave -Targets $targetObjects
        Show-BattleReport -Results $battleResults
    } else {
        Write-Host "`n🛡️ Wave cancelled - Targets remain intact" -ForegroundColor $script:ColorScheme.Neutral
    }
    
    Write-Host "`n[Press any key to exit]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "`n⚠ System Error: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Instant Transmission Teleportation Module
# Rapid file relocation system with dimensional coordinates

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Paths
)

$script:UIColors = @{
    Teleport = 'Magenta'
    Success = 'Green'
    Warn = 'Yellow'
    Error = 'Red'
    Info = 'Cyan'
}

function Show-TeleportHeader {
    $bannerText = @'

    ✨════════════════════════════════════════════✨
         I N S T A N T   T R A N S M I S S I O N
    ✨════════════════════════════════════════════✨
       >> Dimensional Coordinate Selector <<
    ════════════════════════════════════════════════

'@
    Write-Host $bannerText -ForegroundColor $script:UIColors.Teleport
}

function Get-DimensionalCoordinates {
    $shellApp = New-Object -ComObject Shell.Application
    $downloadPath = $shellApp.NameSpace('shell:Downloads').Self.Path
    
    $coordinates = [ordered]@{
        '1' = @{ Label = "Desktop Zone"; Location = [Environment]::GetFolderPath("Desktop") }
        '2' = @{ Label = "Documents Realm"; Location = [Environment]::GetFolderPath("MyDocuments") }
        '3' = @{ Label = "Downloads Sector"; Location = $downloadPath }
        '4' = @{ Label = "Pictures Dimension"; Location = [Environment]::GetFolderPath("MyPictures") }
        '5' = @{ Label = "Videos Chamber"; Location = [Environment]::GetFolderPath("MyVideos") }
        '6' = @{ Label = "Music Domain"; Location = [Environment]::GetFolderPath("MyMusic") }
    }
    
    return $coordinates
}

function Show-ItemsToTeleport {
    param([string[]]$ItemPaths)
    
    Write-Host "`n📦 Items ready for transmission:" -ForegroundColor $script:UIColors.Info
    
    $validCount = 0
    foreach ($itemPath in $ItemPaths) {
        if (Test-Path -LiteralPath $itemPath) {
            $itemObj = Get-Item -LiteralPath $itemPath -Force
            Write-Host "  ► $($itemObj.Name)" -ForegroundColor $script:UIColors.Teleport
            $validCount++
        }
    }
    
    return $validCount
}

function Show-CoordinateMenu {
    param($CoordinateMap)
    
    Write-Host "`n🌟 Available Destinations:" -ForegroundColor $script:UIColors.Success
    
    foreach ($key in $CoordinateMap.Keys) {
        $dest = $CoordinateMap[$key]
        Write-Host ("  [{0}] {1}" -f $key, $dest.Label) -ForegroundColor White
        Write-Host ("      Path: {0}" -f $dest.Location) -ForegroundColor DarkGray
    }
}

function Resolve-NameConflict {
    param(
        [string]$OriginalPath,
        [string]$TargetDirectory
    )
    
    $itemInfo = Get-Item -LiteralPath $OriginalPath
    $proposedName = $itemInfo.Name
    $finalPath = Join-Path $TargetDirectory $proposedName
    
    $iteration = 1
    while (Test-Path -LiteralPath $finalPath) {
        if ($itemInfo.PSIsContainer) {
            $proposedName = "{0} ({1})" -f $itemInfo.BaseName, $iteration
        } else {
            $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($itemInfo.Name)
            $extension = $itemInfo.Extension
            $proposedName = "{0} ({1}){2}" -f $nameWithoutExt, $iteration, $extension
        }
        $finalPath = Join-Path $TargetDirectory $proposedName
        $iteration++
    }
    
    return $finalPath
}

function Invoke-TeleportSequence {
    param(
        [string[]]$Sources,
        [hashtable]$Destination
    )
    
    Write-Host "`n✨ Initiating teleportation sequence..." -ForegroundColor $script:UIColors.Teleport
    Write-Host ("   Target: {0}" -f $Destination.Label) -ForegroundColor $script:UIColors.Info
    
    $stats = @{
        Teleported = 0
        Failed = 0
    }
    
    foreach ($srcPath in $Sources) {
        if (-not (Test-Path -LiteralPath $srcPath)) {
            continue
        }
        
        try {
            $itemObj = Get-Item -LiteralPath $srcPath -Force
            $destPath = Resolve-NameConflict -OriginalPath $srcPath -TargetDirectory $Destination.Location
            
            Move-Item -LiteralPath $srcPath -Destination $destPath -Force -ErrorAction Stop
            
            $destName = Split-Path -Leaf $destPath
            Write-Host ("  ✓ {0} → {1}" -f $itemObj.Name, $destName) -ForegroundColor $script:UIColors.Success
            $stats.Teleported++
            
        } catch {
            Write-Host ("  ✗ Failed: {0}" -f $itemObj.Name) -ForegroundColor $script:UIColors.Error
            Write-Host ("    Reason: {0}" -f $_.Exception.Message) -ForegroundColor DarkRed
            $stats.Failed++
        }
    }
    
    return $stats
}

function Show-TransmissionResults {
    param($Statistics, $DestinationInfo)
    
    Write-Host "`n════════════════════════════════════════════════" -ForegroundColor $script:UIColors.Teleport
    Write-Host "✨ Transmission Complete!" -ForegroundColor $script:UIColors.Success
    Write-Host "════════════════════════════════════════════════" -ForegroundColor $script:UIColors.Teleport
    Write-Host ("  Successfully teleported: {0}" -f $Statistics.Teleported) -ForegroundColor $script:UIColors.Success
    Write-Host ("  Failed transmissions: {0}" -f $Statistics.Failed) -ForegroundColor $script:UIColors.Warn
    
    if ($Statistics.Teleported -gt 0) {
        Write-Host "`n📂 Opening destination portal..." -ForegroundColor $script:UIColors.Info
        Start-Process 'explorer.exe' -ArgumentList $DestinationInfo.Location
    }
}

# Main transmission process
try {
    Show-TeleportHeader
    
    $validItems = Show-ItemsToTeleport -ItemPaths $Paths
    
    if ($validItems -eq 0) {
        Write-Host "`n⚠ No valid items found for teleportation!" -ForegroundColor $script:UIColors.Warn
        Start-Sleep -Seconds 2
        exit 0
    }
    
    $dimensionMap = Get-DimensionalCoordinates
    Show-CoordinateMenu -CoordinateMap $dimensionMap
    
    $userChoice = Read-Host "`nSelect destination (1-6)"
    
    if ($dimensionMap.ContainsKey($userChoice)) {
        $selectedDest = $dimensionMap[$userChoice]
        $results = Invoke-TeleportSequence -Sources $Paths -Destination $selectedDest
        Show-TransmissionResults -Statistics $results -DestinationInfo $selectedDest
    } else {
        Write-Host "`n❌ Invalid coordinates! Teleportation aborted." -ForegroundColor $script:UIColors.Error
    }
    
    Write-Host "`n[Press any key to continue]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "`n⚠ Transmission Error: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Power Level Detection System
# Advanced metadata extraction and analysis tool

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
)

$script:DisplayColors = @{
    Header = 'Green'
    Label = 'Cyan'
    Data = 'White'
    Metric = 'Yellow'
    Divider = 'DarkGray'
}

function Show-ScannerBanner {
    $banner = @'

    🔍═══════════════════════════════════════════🔍
       P O W E R   L E V E L   D E T E C T O R
    🔍═══════════════════════════════════════════🔍
         >> Initiating Deep Scan Protocol <<
    ═════════════════════════════════════════════

'@
    Write-Host $banner -ForegroundColor $script:DisplayColors.Header
}

function Get-ItemMetrics {
    param([string]$TargetPath)
    
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        throw "Target path does not exist: $TargetPath"
    }
    
    $targetItem = Get-Item -LiteralPath $TargetPath -Force
    
    $metrics = @{
        Item = $targetItem
        IsContainer = $targetItem.PSIsContainer
        BasicInfo = @{}
        TimeInfo = @{}
        AttributeInfo = @{}
        ExtendedInfo = @{}
    }
    
    return $metrics
}

function Get-ContainerAnalysis {
    param($DirectoryPath)
    
    $analysis = @{
        FileCount = 0
        FolderCount = 0
        TotalBytes = 0
        TypeDistribution = @{}
    }
    
    try {
        $allFiles = Get-ChildItem -LiteralPath $DirectoryPath -File -Recurse -Force -ErrorAction SilentlyContinue
        $allFolders = Get-ChildItem -LiteralPath $DirectoryPath -Directory -Recurse -Force -ErrorAction SilentlyContinue
        
        $analysis.FileCount = ($allFiles | Measure-Object).Count
        $analysis.FolderCount = ($allFolders | Measure-Object).Count
        $analysis.TotalBytes = ($allFiles | Measure-Object -Property Length -Sum).Sum
        
        $typeGroups = $allFiles | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First 5
        foreach ($group in $typeGroups) {
            $extName = if ([string]::IsNullOrEmpty($group.Name)) { "[no extension]" } else { $group.Name }
            $analysis.TypeDistribution[$extName] = $group.Count
        }
    } catch {
        # Silently handle permission errors
    }
    
    return $analysis
}

function Format-ByteSize {
    param([long]$Bytes)
    
    $units = @(
        @{Suffix = "bytes"; Divisor = 1}
        @{Suffix = "KB"; Divisor = 1KB}
        @{Suffix = "MB"; Divisor = 1MB}
        @{Suffix = "GB"; Divisor = 1GB}
    )
    
    $selectedUnit = $units[0]
    foreach ($unit in $units) {
        if ($Bytes -ge $unit.Divisor) {
            $selectedUnit = $unit
        }
    }
    
    $value = [math]::Round($Bytes / $selectedUnit.Divisor, 2)
    return "{0:N2} {1}" -f $value, $selectedUnit.Suffix
}

function Calculate-PowerLevel {
    param([long]$SizeInBytes)
    
    $baseLevel = [math]::Floor($SizeInBytes / 100)
    return $baseLevel
}

function Show-BasicMetadata {
    param($Metrics)
    
    $itemType = if ($Metrics.IsContainer) { "📁 Directory" } else { "📄 File" }
    
    Write-Host "═════════════════════════════════════════════" -ForegroundColor $script:DisplayColors.Divider
    Write-Host "🎯 TARGET ANALYSIS" -ForegroundColor $script:DisplayColors.Header
    Write-Host "═════════════════════════════════════════════" -ForegroundColor $script:DisplayColors.Divider
    Write-Host ""
    Write-Host "  Name       : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $Metrics.Item.Name -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Type       : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $itemType -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Location   : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $Metrics.Item.FullName -ForegroundColor $script:DisplayColors.Data
}

function Show-TemporalData {
    param($ItemObject)
    
    Write-Host ""
    Write-Host "⏰ TEMPORAL METRICS" -ForegroundColor $script:DisplayColors.Header
    Write-Host "  Created    : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $ItemObject.CreationTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Modified   : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $ItemObject.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Accessed   : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $ItemObject.LastAccessTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor $script:DisplayColors.Data
}

function Show-AttributeData {
    param($ItemObject)
    
    $isHidden = ($ItemObject.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0
    $isReadOnly = $ItemObject.IsReadOnly
    
    Write-Host ""
    Write-Host "🏷️  ATTRIBUTE FLAGS" -ForegroundColor $script:DisplayColors.Header
    Write-Host "  Flags      : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $ItemObject.Attributes.ToString() -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Read-Only  : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $(if ($isReadOnly) { "Yes ✓" } else { "No ✗" }) -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Hidden     : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $(if ($isHidden) { "Yes ✓" } else { "No ✗" }) -ForegroundColor $script:DisplayColors.Data
}

function Show-FileDetails {
    param($ItemObject)
    
    Write-Host ""
    Write-Host "📄 FILE METRICS" -ForegroundColor $script:DisplayColors.Header
    Write-Host "  Size       : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host (Format-ByteSize -Bytes $ItemObject.Length) -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Extension  : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $(if ($ItemObject.Extension) { $ItemObject.Extension } else { "[none]" }) -ForegroundColor $script:DisplayColors.Data
    
    $powerLevel = Calculate-PowerLevel -SizeInBytes $ItemObject.Length
    Write-Host ""
    if ($powerLevel -gt 9000) {
        Write-Host "  ⚡ POWER LEVEL: IT'S OVER 9000!!! ⚡" -ForegroundColor $script:DisplayColors.Metric
    } else {
        Write-Host ("  ⚡ POWER LEVEL: {0} ⚡" -f $powerLevel) -ForegroundColor $script:DisplayColors.Metric
    }
    
    # Hash computation for smaller files
    if ($ItemObject.Length -lt 50MB -and $ItemObject.Length -gt 0) {
        try {
            Write-Host ""
            Write-Host "🔐 INTEGRITY HASH" -ForegroundColor $script:DisplayColors.Header
            $hashData = Get-FileHash -LiteralPath $ItemObject.FullName -Algorithm SHA256 -ErrorAction Stop
            Write-Host "  SHA256     : " -NoNewline -ForegroundColor $script:DisplayColors.Label
            Write-Host $hashData.Hash -ForegroundColor $script:DisplayColors.Data
        } catch {
            # Skip hash display on error
        }
    }
}

function Show-DirectoryDetails {
    param($ItemObject)
    
    Write-Host ""
    Write-Host "📁 DIRECTORY ANALYSIS" -ForegroundColor $script:DisplayColors.Header
    
    $dirAnalysis = Get-ContainerAnalysis -DirectoryPath $ItemObject.FullName
    
    Write-Host "  Files      : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $dirAnalysis.FileCount -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Folders    : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host $dirAnalysis.FolderCount -ForegroundColor $script:DisplayColors.Data
    Write-Host "  Total Size : " -NoNewline -ForegroundColor $script:DisplayColors.Label
    Write-Host (Format-ByteSize -Bytes $dirAnalysis.TotalBytes) -ForegroundColor $script:DisplayColors.Data
    
    if ($dirAnalysis.TypeDistribution.Count -gt 0) {
        Write-Host ""
        Write-Host "📊 TOP FILE TYPES" -ForegroundColor $script:DisplayColors.Header
        foreach ($typeEntry in $dirAnalysis.TypeDistribution.GetEnumerator()) {
            Write-Host ("  {0,-15}: {1} files" -f $typeEntry.Key, $typeEntry.Value) -ForegroundColor $script:DisplayColors.Data
        }
    }
}

function Show-ScanComplete {
    Write-Host ""
    Write-Host "═════════════════════════════════════════════" -ForegroundColor $script:DisplayColors.Divider
    Write-Host "✓ Scan Complete" -ForegroundColor $script:DisplayColors.Header
    Write-Host "═════════════════════════════════════════════" -ForegroundColor $script:DisplayColors.Divider
}

# Execute scanning sequence
try {
    Show-ScannerBanner
    
    $analysisData = Get-ItemMetrics -TargetPath $Path
    
    Show-BasicMetadata -Metrics $analysisData
    Show-TemporalData -ItemObject $analysisData.Item
    Show-AttributeData -ItemObject $analysisData.Item
    
    if ($analysisData.IsContainer) {
        Show-DirectoryDetails -ItemObject $analysisData.Item
    } else {
        Show-FileDetails -ItemObject $analysisData.Item
    }
    
    Show-ScanComplete
    
    Write-Host "`n[Press any key to exit scanner]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "`n⚠ Scanner Error: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

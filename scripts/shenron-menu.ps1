# Shenron Wish Granting System
# Multi-utility submenu with advanced file operations

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Paths
)

$script:UITheme = @{
    Dragon = 'Yellow'
    Option = 'White'
    Success = 'Green'
    Error = 'Red'
    Info = 'Cyan'
    Warning = 'DarkYellow'
}

function Show-DragonSummoning {
    $summoningArt = @'

    🐉═══════════════════════════════════════════🐉
         S H E N R O N   W I S H   S Y S T E M
    🐉═══════════════════════════════════════════🐉
      The Eternal Dragon has been summoned!
           State your wish carefully...
    ═════════════════════════════════════════════

'@
    Write-Host $summoningArt -ForegroundColor $script:UITheme.Dragon
}

function Show-SelectedItems {
    param([string[]]$ItemPaths)
    
    Write-Host "🔮 Selected Items ($($ItemPaths.Count)):" -ForegroundColor $script:UITheme.Info
    
    foreach ($itemPath in $ItemPaths) {
        if (Test-Path -LiteralPath $itemPath) {
            $itemObj = Get-Item -LiteralPath $itemPath -Force
            Write-Host ("  • {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Option
        }
    }
}

function Show-WishMenu {
    Write-Host ""
    Write-Host "🐉 AVAILABLE WISHES:" -ForegroundColor $script:UITheme.Dragon
    Write-Host "  [1] 📋 Copy Full Path to Clipboard" -ForegroundColor $script:UITheme.Option
    Write-Host "  [2] 🔗 Create Symbolic Link" -ForegroundColor $script:UITheme.Option
    Write-Host "  [3] 🎨 Toggle File Attributes" -ForegroundColor $script:UITheme.Option
    Write-Host "  [4] 📅 Modify Timestamps" -ForegroundColor $script:UITheme.Option
    Write-Host "  [5] 🔍 Detect Duplicates" -ForegroundColor $script:UITheme.Option
    Write-Host "  [6] 📊 Generate Analysis Report" -ForegroundColor $script:UITheme.Option
    Write-Host "  [7] 🔄 Pattern-Based Rename" -ForegroundColor $script:UITheme.Option
    Write-Host "  [0] ❌ Dismiss Dragon" -ForegroundColor DarkGray
}

function Invoke-PathCopyWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "📋 Copying paths to system clipboard..." -ForegroundColor $script:UITheme.Info
    
    $existingPaths = $TargetPaths | Where-Object { Test-Path -LiteralPath $_ }
    $concatenated = $existingPaths -join "`r`n"
    
    Set-Clipboard -Value $concatenated
    
    Write-Host ("✓ {0} path(s) copied successfully!" -f $existingPaths.Count) -ForegroundColor $script:UITheme.Success
}

function Invoke-SymlinkWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "🔗 Symbolic Link Creation..." -ForegroundColor $script:UITheme.Info
    
    if ($TargetPaths.Count -ne 1) {
        Write-Host "❌ Shenron can only create one symlink per wish!" -ForegroundColor $script:UITheme.Error
        return
    }
    
    $sourcePath = $TargetPaths[0]
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        Write-Host "❌ Source path does not exist!" -ForegroundColor $script:UITheme.Error
        return
    }
    
    $sourceObj = Get-Item -LiteralPath $sourcePath -Force
    $defaultLinkName = "{0}_Link{1}" -f $sourceObj.BaseName, $sourceObj.Extension
    $defaultLinkPath = Join-Path $sourceObj.Directory.FullName $defaultLinkName
    
    Write-Host ("  Default location: {0}" -f $defaultLinkPath) -ForegroundColor DarkGray
    $linkPath = Read-Host "  Enter symlink path (or press Enter for default)"
    
    if ([string]::IsNullOrWhiteSpace($linkPath)) {
        $linkPath = $defaultLinkPath
    }
    
    try {
        $itemType = if ($sourceObj.PSIsContainer) { 'SymbolicLink' } else { 'SymbolicLink' }
        New-Item -ItemType $itemType -Path $linkPath -Target $sourcePath -Force -ErrorAction Stop | Out-Null
        Write-Host ("✓ Symbolic link created: {0}" -f $linkPath) -ForegroundColor $script:UITheme.Success
    } catch {
        Write-Host ("❌ Failed: {0}" -f $_.Exception.Message) -ForegroundColor $script:UITheme.Error
        Write-Host "   Note: Administrator privileges may be required" -ForegroundColor $script:UITheme.Warning
    }
}

function Invoke-AttributeWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "🎨 Attribute Modification..." -ForegroundColor $script:UITheme.Info
    Write-Host "  [1] Toggle Hidden flag" -ForegroundColor $script:UITheme.Option
    Write-Host "  [2] Toggle Read-Only flag" -ForegroundColor $script:UITheme.Option
    
    $selection = Read-Host "  Choose attribute to modify"
    
    $modCount = 0
    
    foreach ($targetPath in $TargetPaths) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            continue
        }
        
        try {
            $itemObj = Get-Item -LiteralPath $targetPath -Force
            
            if ($selection -eq '1') {
                $currentAttribs = $itemObj.Attributes
                $hiddenFlag = [System.IO.FileAttributes]::Hidden
                
                if (($currentAttribs -band $hiddenFlag) -ne 0) {
                    $itemObj.Attributes = $currentAttribs -bxor $hiddenFlag
                    Write-Host ("  ✓ Unhidden: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Success
                } else {
                    $itemObj.Attributes = $currentAttribs -bor $hiddenFlag
                    Write-Host ("  ✓ Hidden: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Success
                }
                $modCount++
                
            } elseif ($selection -eq '2') {
                $itemObj.IsReadOnly = -not $itemObj.IsReadOnly
                $status = if ($itemObj.IsReadOnly) { "locked" } else { "unlocked" }
                Write-Host ("  ✓ Read-Only {0}: {1}" -f $status, $itemObj.Name) -ForegroundColor $script:UITheme.Success
                $modCount++
            }
            
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Error
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Modified {0} item(s)" -f $modCount) -ForegroundColor $script:UITheme.Success
}

function Invoke-TimestampWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "📅 Timestamp Modification..." -ForegroundColor $script:UITheme.Info
    Write-Host "  [1] Set to current time" -ForegroundColor $script:UITheme.Option
    Write-Host "  [2] Set custom date/time" -ForegroundColor $script:UITheme.Option
    
    $choice = Read-Host "  Select option"
    
    $targetTime = Get-Date
    
    if ($choice -eq '2') {
        $dateInput = Read-Host "  Enter date/time (YYYY-MM-DD HH:MM:SS)"
        try {
            $targetTime = [DateTime]::Parse($dateInput)
        } catch {
            Write-Host "❌ Invalid format! Using current time instead." -ForegroundColor $script:UITheme.Warning
            $targetTime = Get-Date
        }
    }
    
    $updateCount = 0
    
    foreach ($targetPath in $TargetPaths) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            continue
        }
        
        try {
            $itemObj = Get-Item -LiteralPath $targetPath -Force
            $itemObj.CreationTime = $targetTime
            $itemObj.LastWriteTime = $targetTime
            $itemObj.LastAccessTime = $targetTime
            Write-Host ("  ✓ Updated: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Success
            $updateCount++
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Error
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Updated {0} item(s) to {1}" -f $updateCount, $targetTime.ToString("yyyy-MM-dd HH:mm:ss")) -ForegroundColor $script:UITheme.Success
}

function Invoke-DuplicateWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "🔍 Scanning for duplicates..." -ForegroundColor $script:UITheme.Info
    Write-Host "   (Comparing by name and size)" -ForegroundColor DarkGray
    
    $fileCollection = @()
    
    foreach ($targetPath in $TargetPaths) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            continue
        }
        
        $itemObj = Get-Item -LiteralPath $targetPath -Force
        
        if ($itemObj.PSIsContainer) {
            $folderFiles = Get-ChildItem -LiteralPath $targetPath -File -Recurse -Force -ErrorAction SilentlyContinue
            $fileCollection += $folderFiles
        } else {
            $fileCollection += $itemObj
        }
    }
    
    $duplicateGroups = $fileCollection | Group-Object Name, Length | Where-Object { $_.Count -gt 1 }
    
    if ($duplicateGroups.Count -eq 0) {
        Write-Host ""
        Write-Host "✓ No duplicates detected!" -ForegroundColor $script:UITheme.Success
    } else {
        Write-Host ""
        Write-Host ("🎯 Found {0} potential duplicate group(s):" -f $duplicateGroups.Count) -ForegroundColor $script:UITheme.Warning
        
        foreach ($group in $duplicateGroups) {
            $fileName = $group.Values[0]
            $fileSize = [math]::Round($group.Values[1] / 1KB, 2)
            Write-Host ""
            Write-Host ("  📄 {0} ({1} KB):" -f $fileName, $fileSize) -ForegroundColor $script:UITheme.Info
            
            foreach ($file in $group.Group) {
                Write-Host ("    • {0}" -f $file.FullName) -ForegroundColor $script:UITheme.Option
            }
        }
    }
}

function Invoke-ReportWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "📊 Generating analysis report..." -ForegroundColor $script:UITheme.Info
    
    $reportName = "ShenronReport_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss')
    $reportPath = Join-Path ([Environment]::GetFolderPath("Desktop")) $reportName
    
    $reportContent = @()
    $reportContent += "╔═══════════════════════════════════════════════════════════╗"
    $reportContent += "║        SHENRON ANALYSIS REPORT                            ║"
    $reportContent += "║        Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')          ║"
    $reportContent += "╚═══════════════════════════════════════════════════════════╝"
    $reportContent += ""
    
    foreach ($targetPath in $TargetPaths) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            continue
        }
        
        $itemObj = Get-Item -LiteralPath $targetPath -Force
        
        $reportContent += ("=" * 60)
        $reportContent += ("Item: {0}" -f $itemObj.FullName)
        $reportContent += ("Type: {0}" -f $(if ($itemObj.PSIsContainer) { "Directory" } else { "File" }))
        $reportContent += ("Created: {0}" -f $itemObj.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"))
        $reportContent += ("Modified: {0}" -f $itemObj.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))
        
        if (-not $itemObj.PSIsContainer) {
            $sizeKB = [math]::Round($itemObj.Length / 1KB, 2)
            $reportContent += ("Size: {0} KB" -f $sizeKB)
            $reportContent += ("Extension: {0}" -f $(if ($itemObj.Extension) { $itemObj.Extension } else { "[none]" }))
        }
        
        $reportContent += ""
    }
    
    $reportContent | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Host ("✓ Report saved: {0}" -f $reportPath) -ForegroundColor $script:UITheme.Success
    Start-Process 'notepad.exe' -ArgumentList $reportPath
}

function Invoke-RenameWish {
    param([string[]]$TargetPaths)
    
    Write-Host ""
    Write-Host "🔄 Pattern-Based Renaming..." -ForegroundColor $script:UITheme.Info
    Write-Host "  Variables:" -ForegroundColor DarkGray
    Write-Host "    {name}  - Original name (no extension)" -ForegroundColor DarkGray
    Write-Host "    {ext}   - File extension" -ForegroundColor DarkGray
    Write-Host "    {n}     - Sequential number" -ForegroundColor DarkGray
    Write-Host "    {date}  - Current date (YYYYMMDD)" -ForegroundColor DarkGray
    Write-Host ""
    
    $pattern = Read-Host "  Enter rename pattern (e.g., 'DBZ_{name}_{n}')"
    
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Write-Host "❌ No pattern provided!" -ForegroundColor $script:UITheme.Error
        return
    }
    
    $counter = 1
    $renameCount = 0
    
    foreach ($targetPath in $TargetPaths) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            continue
        }
        
        try {
            $itemObj = Get-Item -LiteralPath $targetPath -Force
            
            $newName = $pattern
            $newName = $newName -replace '\{name\}', $itemObj.BaseName
            $newName = $newName -replace '\{ext\}', $itemObj.Extension
            $newName = $newName -replace '\{n\}', $counter
            $newName = $newName -replace '\{date\}', (Get-Date -Format 'yyyyMMdd')
            
            if (-not $itemObj.PSIsContainer -and -not $newName.Contains('.')) {
                $newName += $itemObj.Extension
            }
            
            $newPath = Join-Path $itemObj.Directory.FullName $newName
            
            Rename-Item -LiteralPath $targetPath -NewName $newName -ErrorAction Stop
            Write-Host ("  ✓ {0} → {1}" -f $itemObj.Name, $newName) -ForegroundColor $script:UITheme.Success
            
            $counter++
            $renameCount++
            
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $itemObj.Name) -ForegroundColor $script:UITheme.Error
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Renamed {0} item(s)" -f $renameCount) -ForegroundColor $script:UITheme.Success
}

function Invoke-WishDispatcher {
    param(
        [string]$WishNumber,
        [string[]]$ItemPaths
    )
    
    switch ($WishNumber) {
        '1' { Invoke-PathCopyWish -TargetPaths $ItemPaths }
        '2' { Invoke-SymlinkWish -TargetPaths $ItemPaths }
        '3' { Invoke-AttributeWish -TargetPaths $ItemPaths }
        '4' { Invoke-TimestampWish -TargetPaths $ItemPaths }
        '5' { Invoke-DuplicateWish -TargetPaths $ItemPaths }
        '6' { Invoke-ReportWish -TargetPaths $ItemPaths }
        '7' { Invoke-RenameWish -TargetPaths $ItemPaths }
        '0' { 
            Write-Host ""
            Write-Host "🐉 Shenron returns to the heavens..." -ForegroundColor $script:UITheme.Dragon
        }
        default {
            Write-Host ""
            Write-Host "❌ Invalid wish! Shenron cannot grant this request." -ForegroundColor $script:UITheme.Error
        }
    }
}

# Main wish granting sequence
try {
    Show-DragonSummoning
    Show-SelectedItems -ItemPaths $Paths
    Show-WishMenu
    
    $userWish = Read-Host "`nEnter your wish (0-7)"
    
    Invoke-WishDispatcher -WishNumber $userWish -ItemPaths $Paths
    
    Write-Host ""
    Write-Host "🐉 The Dragon Balls scatter across the world..." -ForegroundColor $script:UITheme.Dragon
    Write-Host ""
    Write-Host "[Press any key to continue]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host ""
    Write-Host ("⚠ Shenron Error: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

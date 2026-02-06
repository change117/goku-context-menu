# Multi-Function Utility Gateway
# Dragon-themed operations menu system

param([string[]]$Selections)

$theme = @{
    Pal = @{ Dragon='Yellow'; Opt='White'; Pass='Green'; Fail='Red'; Info='Cyan'; Note='DarkYellow' }
    Header = @'

    🐉═══ ETERNAL DRAGON INTERFACE ═══🐉
          Seven utilities await...
    
'@
}

function Display-IntroScreen {
    Write-Host $theme.Header -Fore $theme.Pal.Dragon
    
    Write-Host "🔮 Selected Items ($($Selections.Count)):" -Fore $theme.Pal.Info
    
    foreach ($item in $Selections) {
        if (Test-Path -LiteralPath $item) {
            $obj = Get-Item -LiteralPath $item -Force
            Write-Host ("  • {0}" -f $obj.Name) -Fore $theme.Pal.Opt
        }
    }
}

function Render-Menu {
    Write-Host ""
    Write-Host "🐉 SELECT OPERATION:" -Fore $theme.Pal.Dragon
    Write-Host "  [1] 📋 Path Export" -Fore $theme.Pal.Opt
    Write-Host "  [2] 🔗 Link Generator" -Fore $theme.Pal.Opt
    Write-Host "  [3] 🎨 Attribute Editor" -Fore $theme.Pal.Opt
    Write-Host "  [4] 📅 Time Modifier" -Fore $theme.Pal.Opt
    Write-Host "  [5] 🔍 Duplicate Finder" -Fore $theme.Pal.Opt
    Write-Host "  [6] 📊 Report Builder" -Fore $theme.Pal.Opt
    Write-Host "  [7] 🔄 Batch Renamer" -Fore $theme.Pal.Opt
    Write-Host "  [0] ❌ Exit" -Fore DarkGray
}

function Op-PathExport {
    param($targets)
    
    Write-Host ""
    Write-Host "📋 Exporting paths..." -Fore $theme.Pal.Info
    
    $valid = $targets | Where-Object { Test-Path -LiteralPath $_ }
    $combined = $valid -join "`r`n"
    
    Set-Clipboard -Value $combined
    
    Write-Host ("✓ {0} path(s) exported to clipboard" -f $valid.Count) -Fore $theme.Pal.Pass
}

function Op-LinkGenerator {
    param($targets)
    
    Write-Host ""
    Write-Host "🔗 Link creation..." -Fore $theme.Pal.Info
    
    if ($targets.Count -ne 1) {
        Write-Host "❌ Only one item allowed" -Fore $theme.Pal.Fail
        return
    }
    
    $source = $targets[0]
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "❌ Source missing" -Fore $theme.Pal.Fail
        return
    }
    
    $srcObj = Get-Item -LiteralPath $source -Force
    $suggestedLink = "{0}_Link{1}" -f $srcObj.BaseName, $srcObj.Extension
    $suggestedPath = Join-Path $srcObj.Directory.FullName $suggestedLink
    
    Write-Host ("  Suggested: {0}" -f $suggestedPath) -Fore DarkGray
    $linkPath = Read-Host "  Link path (Enter=default)"
    
    if ([string]::IsNullOrWhiteSpace($linkPath)) {
        $linkPath = $suggestedPath
    }
    
    try {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $source -Force -EA Stop | Out-Null
        Write-Host ("✓ Link created: {0}" -f $linkPath) -Fore $theme.Pal.Pass
    } catch {
        Write-Host ("❌ Error: {0}" -f $_.Exception.Message) -Fore $theme.Pal.Fail
        Write-Host "   Admin rights may be required" -Fore $theme.Pal.Note
    }
}

function Op-AttributeEditor {
    param($targets)
    
    Write-Host ""
    Write-Host "🎨 Attribute modification..." -Fore $theme.Pal.Info
    Write-Host "  [1] Toggle hidden" -Fore $theme.Pal.Opt
    Write-Host "  [2] Toggle readonly" -Fore $theme.Pal.Opt
    
    $sel = Read-Host "  Choose"
    
    $count = 0
    
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) { continue }
        
        try {
            $obj = Get-Item -LiteralPath $target -Force
            
            if ($sel -eq '1') {
                $attrs = $obj.Attributes
                $hiddenBit = [IO.FileAttributes]::Hidden
                
                if (($attrs -band $hiddenBit) -ne 0) {
                    $obj.Attributes = $attrs -bxor $hiddenBit
                    Write-Host ("  ✓ Unhidden: {0}" -f $obj.Name) -Fore $theme.Pal.Pass
                } else {
                    $obj.Attributes = $attrs -bor $hiddenBit
                    Write-Host ("  ✓ Hidden: {0}" -f $obj.Name) -Fore $theme.Pal.Pass
                }
                $count++
            } elseif ($sel -eq '2') {
                $obj.IsReadOnly = -not $obj.IsReadOnly
                $state = if ($obj.IsReadOnly) { "locked" } else { "unlocked" }
                Write-Host ("  ✓ {0}: {1}" -f $state, $obj.Name) -Fore $theme.Pal.Pass
                $count++
            }
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $obj.Name) -Fore $theme.Pal.Fail
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Modified {0} item(s)" -f $count) -Fore $theme.Pal.Pass
}

function Op-TimeModifier {
    param($targets)
    
    Write-Host ""
    Write-Host "📅 Time modification..." -Fore $theme.Pal.Info
    Write-Host "  [1] Current time" -Fore $theme.Pal.Opt
    Write-Host "  [2] Custom time" -Fore $theme.Pal.Opt
    
    $opt = Read-Host "  Choose"
    
    $time = Get-Date
    
    if ($opt -eq '2') {
        $input = Read-Host "  Enter time (YYYY-MM-DD HH:MM:SS)"
        try {
            $time = [DateTime]::Parse($input)
        } catch {
            Write-Host "❌ Invalid format, using current" -Fore $theme.Pal.Note
            $time = Get-Date
        }
    }
    
    $count = 0
    
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) { continue }
        
        try {
            $obj = Get-Item -LiteralPath $target -Force
            $obj.CreationTime = $time
            $obj.LastWriteTime = $time
            $obj.LastAccessTime = $time
            Write-Host ("  ✓ Updated: {0}" -f $obj.Name) -Fore $theme.Pal.Pass
            $count++
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $obj.Name) -Fore $theme.Pal.Fail
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Updated {0} to {1}" -f $count, $time.ToString("yyyy-MM-dd HH:mm:ss")) -Fore $theme.Pal.Pass
}

function Op-DuplicateFinder {
    param($targets)
    
    Write-Host ""
    Write-Host "🔍 Searching duplicates..." -Fore $theme.Pal.Info
    Write-Host "   (Name + size comparison)" -Fore DarkGray
    
    $files = @()
    
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) { continue }
        
        $obj = Get-Item -LiteralPath $target -Force
        
        if ($obj.PSIsContainer) {
            $files += Get-ChildItem -LiteralPath $target -File -Recurse -Force -EA SilentlyContinue
        } else {
            $files += $obj
        }
    }
    
    $groups = $files | Group-Object Name, Length | Where-Object { $_.Count -gt 1 }
    
    if ($groups.Count -eq 0) {
        Write-Host ""
        Write-Host "✓ No duplicates found" -Fore $theme.Pal.Pass
    } else {
        Write-Host ""
        Write-Host ("🎯 Found {0} duplicate set(s):" -f $groups.Count) -Fore $theme.Pal.Note
        
        foreach ($grp in $groups) {
            $name = $grp.Values[0]
            $size = [math]::Round($grp.Values[1] / 1KB, 2)
            Write-Host ""
            Write-Host ("  📄 {0} ({1} KB):" -f $name, $size) -Fore $theme.Pal.Info
            
            foreach ($f in $grp.Group) {
                Write-Host ("    • {0}" -f $f.FullName) -Fore $theme.Pal.Opt
            }
        }
    }
}

function Op-ReportBuilder {
    param($targets)
    
    Write-Host ""
    Write-Host "📊 Building report..." -Fore $theme.Pal.Info
    
    $name = "DragonReport_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss')
    $path = Join-Path ([Environment]::GetFolderPath("Desktop")) $name
    
    $content = @()
    $content += "╔════════════════════════════════════════════════╗"
    $content += "║     DRAGON ANALYSIS REPORT                     ║"
    $content += "║     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                  ║"
    $content += "╚════════════════════════════════════════════════╝"
    $content += ""
    
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) { continue }
        
        $obj = Get-Item -LiteralPath $target -Force
        
        $content += ("=" * 50)
        $content += ("Item: {0}" -f $obj.FullName)
        $content += ("Type: {0}" -f $(if ($obj.PSIsContainer) { "Folder" } else { "File" }))
        $content += ("Created: {0}" -f $obj.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"))
        $content += ("Modified: {0}" -f $obj.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))
        
        if (-not $obj.PSIsContainer) {
            $kb = [math]::Round($obj.Length / 1KB, 2)
            $content += ("Size: {0} KB" -f $kb)
            $content += ("Extension: {0}" -f $(if ($obj.Extension) { $obj.Extension } else { "[none]" }))
        }
        
        $content += ""
    }
    
    $content | Out-File -FilePath $path -Encoding UTF8
    
    Write-Host ("✓ Report saved: {0}" -f $path) -Fore $theme.Pal.Pass
    Start-Process 'notepad.exe' -ArgumentList $path
}

function Op-BatchRenamer {
    param($targets)
    
    Write-Host ""
    Write-Host "🔄 Batch renaming..." -Fore $theme.Pal.Info
    Write-Host "  Tokens:" -Fore DarkGray
    Write-Host "    {name} - Base name" -Fore DarkGray
    Write-Host "    {ext}  - Extension" -Fore DarkGray
    Write-Host "    {n}    - Number" -Fore DarkGray
    Write-Host "    {date} - Date stamp" -Fore DarkGray
    Write-Host ""
    
    $pattern = Read-Host "  Pattern (e.g. 'Item_{n}_{name}')"
    
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Write-Host "❌ No pattern" -Fore $theme.Pal.Fail
        return
    }
    
    $num = 1
    $count = 0
    
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) { continue }
        
        try {
            $obj = Get-Item -LiteralPath $target -Force
            
            $newName = $pattern
            $newName = $newName -replace '\{name\}', $obj.BaseName
            $newName = $newName -replace '\{ext\}', $obj.Extension
            $newName = $newName -replace '\{n\}', $num
            $newName = $newName -replace '\{date\}', (Get-Date -Format 'yyyyMMdd')
            
            if (-not $obj.PSIsContainer -and -not $newName.Contains('.')) {
                $newName += $obj.Extension
            }
            
            Rename-Item -LiteralPath $target -NewName $newName -EA Stop
            Write-Host ("  ✓ {0} → {1}" -f $obj.Name, $newName) -Fore $theme.Pal.Pass
            
            $num++
            $count++
        } catch {
            Write-Host ("  ❌ Failed: {0}" -f $obj.Name) -Fore $theme.Pal.Fail
        }
    }
    
    Write-Host ""
    Write-Host ("✓ Renamed {0} item(s)" -f $count) -Fore $theme.Pal.Pass
}

function Route-Operation {
    param($code, $items)
    
    switch ($code) {
        '1' { Op-PathExport -targets $items }
        '2' { Op-LinkGenerator -targets $items }
        '3' { Op-AttributeEditor -targets $items }
        '4' { Op-TimeModifier -targets $items }
        '5' { Op-DuplicateFinder -targets $items }
        '6' { Op-ReportBuilder -targets $items }
        '7' { Op-BatchRenamer -targets $items }
        '0' { 
            Write-Host ""
            Write-Host "🐉 Dragon dismissed..." -Fore $theme.Pal.Dragon
        }
        default {
            Write-Host ""
            Write-Host "❌ Invalid operation" -Fore $theme.Pal.Fail
        }
    }
}

# Main execution
try {
    Display-IntroScreen
    Render-Menu
    
    $choice = Read-Host "`nOperation (0-7)"
    
    Route-Operation -code $choice -items $Selections
    
    Write-Host ""
    Write-Host "🐉 Dragon balls scatter..." -Fore $theme.Pal.Dragon
    Write-Host ""
    Write-Host "[Press any key]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host ""
    Write-Host ("⚠ Error: {0}" -f $_.Exception.Message) -Fore Red
    Start-Sleep 2
    exit 1
}

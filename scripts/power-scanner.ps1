# Metadata Extraction Scanner
# Deep analysis tool for files and directories

param([string]$Subject)

$ui = @{
    Scheme = @{ Prime='Green'; Tag='Cyan'; Val='White'; Num='Yellow'; Sep='DarkGray' }
    Banner = @'

    🔍═══ DEEP SCAN PROTOCOL ═══🔍
       Analyzing target signature...
    
'@
}

function Compute-SizeLabel {
    param([long]$raw)
    
    $tiers = @(
        @{Label="B"; Factor=1}
        @{Label="KB"; Factor=1KB}
        @{Label="MB"; Factor=1MB}
        @{Label="GB"; Factor=1GB}
    )
    
    $pick = $tiers[0]
    foreach ($t in $tiers) {
        if ($raw -ge $t.Factor) { $pick = $t }
    }
    
    $num = [math]::Round($raw / $pick.Factor, 2)
    return "{0:N2} {1}" -f $num, $pick.Label
}

function Calculate-Strength {
    param([long]$size)
    return [math]::Floor($size / 100)
}

function Scan-Container {
    param($path)
    
    $data = @{ Files=0; Folders=0; Volume=0; Types=@{} }
    
    try {
        $files = Get-ChildItem -LiteralPath $path -File -Recurse -Force -EA SilentlyContinue
        $folders = Get-ChildItem -LiteralPath $path -Directory -Recurse -Force -EA SilentlyContinue
        
        $data.Files = ($files | Measure-Object).Count
        $data.Folders = ($folders | Measure-Object).Count
        $data.Volume = ($files | Measure-Object -Property Length -Sum).Sum
        
        $groups = $files | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First 5
        foreach ($g in $groups) {
            $ext = if ([string]::IsNullOrEmpty($g.Name)) { "[none]" } else { $g.Name }
            $data.Types[$ext] = $g.Count
        }
    } catch {}
    
    return $data
}

function Render-BasicInfo {
    param($obj)
    
    $category = if ($obj.PSIsContainer) { "📁 Folder" } else { "📄 File" }
    
    Write-Host "═════════════════════════════════════" -Fore $ui.Scheme.Sep
    Write-Host "🎯 SUBJECT IDENTIFICATION" -Fore $ui.Scheme.Prime
    Write-Host "═════════════════════════════════════" -Fore $ui.Scheme.Sep
    Write-Host ""
    Write-Host "  Name    : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.Name -Fore $ui.Scheme.Val
    Write-Host "  Type    : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $category -Fore $ui.Scheme.Val
    Write-Host "  Path    : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.FullName -Fore $ui.Scheme.Val
}

function Render-Chronology {
    param($obj)
    
    Write-Host ""
    Write-Host "⏰ TIME COORDINATES" -Fore $ui.Scheme.Prime
    Write-Host "  Born    : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.CreationTime.ToString("yyyy-MM-dd HH:mm:ss") -Fore $ui.Scheme.Val
    Write-Host "  Changed : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") -Fore $ui.Scheme.Val
    Write-Host "  Viewed  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.LastAccessTime.ToString("yyyy-MM-dd HH:mm:ss") -Fore $ui.Scheme.Val
}

function Render-Properties {
    param($obj)
    
    $hidden = ($obj.Attributes -band [IO.FileAttributes]::Hidden) -ne 0
    $locked = $obj.IsReadOnly
    
    Write-Host ""
    Write-Host "🏷️  FLAGS & ATTRIBUTES" -Fore $ui.Scheme.Prime
    Write-Host "  Flags   : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $obj.Attributes.ToString() -Fore $ui.Scheme.Val
    Write-Host "  Locked  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $(if ($locked) { "Yes ✓" } else { "No ✗" }) -Fore $ui.Scheme.Val
    Write-Host "  Hidden  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $(if ($hidden) { "Yes ✓" } else { "No ✗" }) -Fore $ui.Scheme.Val
}

function Render-FileData {
    param($obj)
    
    Write-Host ""
    Write-Host "📄 FILE ANALYSIS" -Fore $ui.Scheme.Prime
    Write-Host "  Volume  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host (Compute-SizeLabel -raw $obj.Length) -Fore $ui.Scheme.Val
    Write-Host "  Format  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $(if ($obj.Extension) { $obj.Extension } else { "[none]" }) -Fore $ui.Scheme.Val
    
    $level = Calculate-Strength -size $obj.Length
    Write-Host ""
    if ($level -gt 9000) {
        Write-Host "  ⚡ STRENGTH: BEYOND 9000!!! ⚡" -Fore $ui.Scheme.Num
    } else {
        Write-Host ("  ⚡ STRENGTH: {0} ⚡" -f $level) -Fore $ui.Scheme.Num
    }
    
    if ($obj.Length -lt 50MB -and $obj.Length -gt 0) {
        try {
            Write-Host ""
            Write-Host "🔐 CHECKSUM DATA" -Fore $ui.Scheme.Prime
            $hash = Get-FileHash -LiteralPath $obj.FullName -Algorithm SHA256 -EA Stop
            Write-Host "  SHA256  : " -NoNewline -Fore $ui.Scheme.Tag
            Write-Host $hash.Hash -Fore $ui.Scheme.Val
        } catch {}
    }
}

function Render-FolderData {
    param($obj)
    
    Write-Host ""
    Write-Host "📁 CONTAINER ANALYSIS" -Fore $ui.Scheme.Prime
    
    $scan = Scan-Container -path $obj.FullName
    
    Write-Host "  Files   : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $scan.Files -Fore $ui.Scheme.Val
    Write-Host "  Folders : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host $scan.Folders -Fore $ui.Scheme.Val
    Write-Host "  Volume  : " -NoNewline -Fore $ui.Scheme.Tag
    Write-Host (Compute-SizeLabel -raw $scan.Volume) -Fore $ui.Scheme.Val
    
    if ($scan.Types.Count -gt 0) {
        Write-Host ""
        Write-Host "📊 FORMAT DISTRIBUTION" -Fore $ui.Scheme.Prime
        foreach ($entry in $scan.Types.GetEnumerator()) {
            Write-Host ("  {0,-12}: {1} files" -f $entry.Key, $entry.Value) -Fore $ui.Scheme.Val
        }
    }
}

function Render-Complete {
    Write-Host ""
    Write-Host "═════════════════════════════════════" -Fore $ui.Scheme.Sep
    Write-Host "✓ Scan finished" -Fore $ui.Scheme.Prime
    Write-Host "═════════════════════════════════════" -Fore $ui.Scheme.Sep
}

# Main scanner
try {
    Write-Host $ui.Banner -Fore $ui.Scheme.Prime
    
    if (-not (Test-Path -LiteralPath $Subject)) {
        Write-Host "⚠ Subject not found" -Fore Red
        Start-Sleep 2
        exit 1
    }
    
    $target = Get-Item -LiteralPath $Subject -Force
    
    Render-BasicInfo -obj $target
    Render-Chronology -obj $target
    Render-Properties -obj $target
    
    if ($target.PSIsContainer) {
        Render-FolderData -obj $target
    } else {
        Render-FileData -obj $target
    }
    
    Render-Complete
    
    Write-Host "`n[Press any key]"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "`n⚠ Scanner fault: $($_.Exception.Message)" -Fore Red
    Start-Sleep 2
    exit 1
}

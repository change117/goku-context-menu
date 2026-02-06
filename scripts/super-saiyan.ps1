# Elite Privilege Escalator
# Dragon Ball themed administrative access module

param([string]$TargetResource)

$cfg = @{ Colors = @{ Pri='Yellow'; Ok='Green'; Err='Red'; Txt='Cyan' }; Banner = @'
    
    ═══ SUPER SAIYAN TRANSFORMATION ═══
    Escalating to maximum power level...
    
'@ }

function Test-AdminContext { 
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ItemCategory { 
    param($res)
    return (Get-Item -LiteralPath $res -Force -EA SilentlyContinue).PSIsContainer
}

function Launch-WithPrivilege {
    param($resource, $isFolder)
    
    $params = @{ Verb='RunAs'; ErrorAction='Stop' }
    
    if ($isFolder) {
        $params.FilePath = 'explorer.exe'
        $params.ArgumentList = "`"$resource`""
    } else {
        $params.FilePath = $resource
    }
    
    Start-Process @params
}

function Request-Elevation {
    param($scriptFile, $target)
    
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptFile`" `"$target`""
    Start-Process 'powershell.exe' -ArgumentList $args -Verb RunAs -EA Stop
}

# Main flow
try {
    Write-Host $cfg.Banner -Fore $cfg.Colors.Pri
    
    if (-not (Test-Path -LiteralPath $TargetResource)) {
        Write-Host "⚠ Target not accessible in this dimension" -Fore $cfg.Colors.Err
        Start-Sleep 2
        exit 1
    }
    
    if (Test-AdminContext) {
        Write-Host "✓ Already transformed - executing with full power" -Fore $cfg.Colors.Ok
        $category = Get-ItemCategory -res $TargetResource
        Launch-WithPrivilege -resource $TargetResource -isFolder $category
        Write-Host "`n⚡ Transformation complete" -Fore $cfg.Colors.Ok
    } else {
        Write-Host "⚡ Initiating power-up sequence..." -Fore $cfg.Colors.Pri
        Request-Elevation -scriptFile $MyInvocation.MyCommand.Path -target $TargetResource
    }
    
    Start-Sleep 2
} catch {
    Write-Host "⚠ Power surge failed: $($_.Exception.Message)" -Fore Red
    Start-Sleep 2
    exit 1
}

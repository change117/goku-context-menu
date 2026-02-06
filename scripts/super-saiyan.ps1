# Super Saiyan Elevation Module
# Provides administrative privilege escalation with themed interface

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
)

# Configuration
$script:ThemeColor = @{
    Primary = 'Yellow'
    Success = 'Green'
    Error = 'Red'
    Info = 'Cyan'
}

function Show-GokuBanner {
    $artWork = @'
    
    ⚡ TRANSFORMATION SEQUENCE INITIATED ⚡
    ╔══════════════════════════════════════╗
    ║   SUPER SAIYAN ACTIVATION MODE       ║
    ║   Power Surge Detected: OVER 9000!   ║
    ╚══════════════════════════════════════╝
    
'@
    Write-Host $artWork -ForegroundColor $script:ThemeColor.Primary
}

function Test-ElevatedPrivileges {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($adminRole)
}

function Invoke-PathWithElevation {
    param([string]$TargetPath)
    
    $itemProperties = Get-Item -LiteralPath $TargetPath -Force -ErrorAction Stop
    $launchParams = @{
        Verb = 'RunAs'
        ErrorAction = 'Stop'
    }
    
    if ($itemProperties.PSIsContainer) {
        $launchParams.FilePath = 'explorer.exe'
        $launchParams.ArgumentList = "`"$TargetPath`""
    } else {
        $launchParams.FilePath = $TargetPath
    }
    
    Start-Process @launchParams
}

function Start-TransformationSequence {
    param([string]$TargetPath)
    
    Show-GokuBanner
    
    $pathExists = Test-Path -LiteralPath $TargetPath -ErrorAction SilentlyContinue
    if (-not $pathExists) {
        Write-Host "⚠ ERROR: Target does not exist in this dimension!" -ForegroundColor $script:ThemeColor.Error
        Start-Sleep -Seconds 3
        exit 1
    }
    
    $hasAdminPowers = Test-ElevatedPrivileges
    
    if ($hasAdminPowers) {
        Write-Host "✓ Super Saiyan form already achieved!" -ForegroundColor $script:ThemeColor.Success
        Write-Host "  Accessing: $TargetPath" -ForegroundColor $script:ThemeColor.Info
        
        try {
            Invoke-PathWithElevation -TargetPath $TargetPath
            Write-Host "`n⚡ Access granted with maximum power!" -ForegroundColor $script:ThemeColor.Success
        } catch {
            Write-Host "⚠ Transformation incomplete: $($_.Exception.Message)" -ForegroundColor $script:ThemeColor.Error
            Start-Sleep -Seconds 3
            exit 1
        }
    } else {
        Write-Host "⚡ Gathering energy for transformation..." -ForegroundColor $script:ThemeColor.Primary
        
        $scriptLocation = $MyInvocation.MyCommand.Path
        $psArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptLocation`" -Path `"$TargetPath`""
        
        try {
            Start-Process 'powershell.exe' -ArgumentList $psArgs -Verb RunAs -ErrorAction Stop
        } catch {
            Write-Host "⚠ Transformation rejected: $($_.Exception.Message)" -ForegroundColor $script:ThemeColor.Error
            Start-Sleep -Seconds 3
            exit 1
        }
    }
    
    Start-Sleep -Seconds 2
}

# Main execution
try {
    Start-TransformationSequence -TargetPath $Path
} catch {
    Write-Host "⚠ Critical failure: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

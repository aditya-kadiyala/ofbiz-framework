# Master Validation Script for OFBiz Architecture Documentation
# Runs all validation checks and generates a comprehensive report

param(
    [string]$DocsPath = "..",
    [string]$OFBizRoot = "../../..",
    [switch]$Verbose,
    [switch]$SkipExternal
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TotalErrors = 0
$TotalWarnings = 0

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  OFBiz Architecture Documentation - Master Validator           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation Path: $DocsPath" -ForegroundColor Gray
Write-Host "OFBiz Root: $OFBizRoot" -ForegroundColor Gray
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Function to run a validation script and capture results
function Run-Validation {
    param(
        [string]$ScriptName,
        [string]$Description,
        [hashtable]$Parameters
    )
    
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│ Running: $Description" -ForegroundColor White
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    
    $ScriptPath = Join-Path $ScriptDir $ScriptName
    
    try {
        $Result = & $ScriptPath @Parameters
        $ExitCode = $LASTEXITCODE
        
        Write-Host ""
        
        if ($ExitCode -eq 0) {
            Write-Host "✓ $Description: PASSED" -ForegroundColor Green
        } elseif ($ExitCode -eq 1) {
            Write-Host "✗ $Description: FAILED" -ForegroundColor Red
            $script:TotalErrors++
        } else {
            Write-Host "⚠ $Description: WARNINGS" -ForegroundColor Yellow
            $script:TotalWarnings++
        }
    }
    catch {
        Write-Host "✗ $Description: ERROR" -ForegroundColor Red
        Write-Host "  Exception: $($_.Exception.Message)" -ForegroundColor Red
        $script:TotalErrors++
    }
    
    Write-Host ""
}

# 1. Template Compliance Check
Run-Validation -ScriptName "validate-template.ps1" `
               -Description "Template Compliance" `
               -Parameters @{
                   DocsPath = $DocsPath
                   Verbose = $Verbose
               }

# 2. Diagram Presence Check
Run-Validation -ScriptName "validate-diagrams.ps1" `
               -Description "Diagram Presence" `
               -Parameters @{
                   DocsPath = $DocsPath
                   Verbose = $Verbose
               }

# 3. Internal Link Validation
Run-Validation -ScriptName "validate-links.ps1" `
               -Description "Internal Links" `
               -Parameters @{
                   DocsPath = $DocsPath
                   InternalOnly = $true
                   Verbose = $Verbose
               }

# 4. External Link Validation (if not skipped)
if (-not $SkipExternal) {
    Run-Validation -ScriptName "validate-links.ps1" `
                   -Description "External Links" `
                   -Parameters @{
                       DocsPath = $DocsPath
                       ExternalOnly = $true
                       Verbose = $Verbose
                   }
}

# 5. Code Reference Validation
Run-Validation -ScriptName "validate-code-refs.ps1" `
               -Description "Code References" `
               -Parameters @{
                   DocsPath = $DocsPath
                   OFBizRoot = $OFBizRoot
                   Verbose = $Verbose
               }

# Generate Summary Report
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Validation Summary Report                                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$TotalChecks = 5
if ($SkipExternal) { $TotalChecks = 4 }

$PassedChecks = $TotalChecks - $TotalErrors - $TotalWarnings

Write-Host "Total Checks: $TotalChecks" -ForegroundColor Gray
Write-Host "Passed: $PassedChecks" -ForegroundColor Green
Write-Host "Warnings: $TotalWarnings" -ForegroundColor $(if ($TotalWarnings -gt 0) { "Yellow" } else { "Gray" })
Write-Host "Errors: $TotalErrors" -ForegroundColor $(if ($TotalErrors -gt 0) { "Red" } else { "Gray" })
Write-Host ""

# Final Status
if ($TotalErrors -gt 0) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║  VALIDATION FAILED                                             ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Documentation has $TotalErrors critical error(s) that must be fixed." -ForegroundColor Red
    Write-Host ""
    exit 1
}
elseif ($TotalWarnings -gt 0) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  VALIDATION PASSED WITH WARNINGS                               ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Documentation passed but has $TotalWarnings warning(s)." -ForegroundColor Yellow
    Write-Host "Consider addressing warnings for better documentation quality." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}
else {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  VALIDATION PASSED                                             ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "All validation checks passed successfully!" -ForegroundColor Green
    Write-Host "Documentation is ready for publication." -ForegroundColor Green
    Write-Host ""
    exit 0
}

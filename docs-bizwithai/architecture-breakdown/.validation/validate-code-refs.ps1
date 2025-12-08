# Code Reference Validation Script for OFBiz Architecture Documentation
# Validates that all code file references point to existing files

param(
    [string]$DocsPath = ".",
    [string]$OFBizRoot = "../../..",
    [switch]$Verbose
)

$ErrorCount = 0
$TotalRefs = 0

Write-Host "=== OFBiz Architecture Documentation - Code Reference Validator ===" -ForegroundColor Cyan
Write-Host "Docs directory: $DocsPath" -ForegroundColor Gray
Write-Host "OFBiz root: $OFBizRoot" -ForegroundColor Gray
Write-Host ""

# Get all markdown files
$MarkdownFiles = Get-ChildItem -Path $DocsPath -Filter "*.md" -Recurse | Where-Object { $_.FullName -notlike "*\.templates*" }

Write-Host "Found $($MarkdownFiles.Count) markdown files to validate" -ForegroundColor Gray
Write-Host ""

foreach ($File in $MarkdownFiles) {
    $RelativePath = $File.FullName.Replace((Get-Location).Path, "").TrimStart('\')
    
    if ($Verbose) {
        Write-Host "Checking: $RelativePath" -ForegroundColor Gray
    }
    
    $Content = Get-Content $File.FullName -Raw
    
    # Find code references in format: **File**: `path/to/file.java`
    $FileRefPattern = '\*\*File\*\*:\s*`([^`]+)`'
    $FileRefs = [regex]::Matches($Content, $FileRefPattern)
    
    foreach ($Ref in $FileRefs) {
        $FilePath = $Ref.Groups[1].Value
        $TotalRefs++
        
        if ($Verbose) {
            Write-Host "  Code ref: $FilePath" -ForegroundColor DarkGray
        }
        
        # Resolve path relative to OFBiz root
        $FullPath = Join-Path $OFBizRoot $FilePath
        $FullPath = [System.IO.Path]::GetFullPath($FullPath)
        
        # Check if file exists
        if (-not (Test-Path $FullPath)) {
            Write-Host "  [ERROR] Code reference not found: $FilePath" -ForegroundColor Red
            Write-Host "    in file: $RelativePath" -ForegroundColor Red
            Write-Host "    expected at: $FullPath" -ForegroundColor Red
            $ErrorCount++
        }
    }
    
    # Also check for inline code paths in backticks that look like file paths
    $InlinePathPattern = '`(framework/[^`]+\.(java|groovy|xml))`'
    $InlinePaths = [regex]::Matches($Content, $InlinePathPattern)
    
    foreach ($Path in $InlinePaths) {
        $FilePath = $Path.Groups[1].Value
        
        # Skip if already checked as a File reference
        if ($FileRefs | Where-Object { $_.Groups[1].Value -eq $FilePath }) {
            continue
        }
        
        $TotalRefs++
        
        if ($Verbose) {
            Write-Host "  Inline path: $FilePath" -ForegroundColor DarkGray
        }
        
        # Resolve path relative to OFBiz root
        $FullPath = Join-Path $OFBizRoot $FilePath
        $FullPath = [System.IO.Path]::GetFullPath($FullPath)
        
        # Check if file exists
        if (-not (Test-Path $FullPath)) {
            Write-Host "  [ERROR] Inline code path not found: $FilePath" -ForegroundColor Red
            Write-Host "    in file: $RelativePath" -ForegroundColor Red
            Write-Host "    expected at: $FullPath" -ForegroundColor Red
            $ErrorCount++
        }
    }
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Total code references checked: $TotalRefs" -ForegroundColor Gray
Write-Host "Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "FAILED: Documentation has invalid code references" -ForegroundColor Red
    exit 1
} else {
    Write-Host "SUCCESS: All code references are valid" -ForegroundColor Green
    exit 0
}

# Link Validation Script for OFBiz Architecture Documentation
# Validates all internal and external links in markdown files

param(
    [string]$DocsPath = ".",
    [switch]$ExternalOnly,
    [switch]$InternalOnly,
    [switch]$Verbose
)

$ErrorCount = 0
$WarningCount = 0
$TotalLinks = 0

Write-Host "=== OFBiz Architecture Documentation - Link Validator ===" -ForegroundColor Cyan
Write-Host "Scanning directory: $DocsPath" -ForegroundColor Gray
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
    
    # Find all markdown links [text](url) and [text](url#anchor)
    $LinkPattern = '\[([^\]]+)\]\(([^)]+)\)'
    $Links = [regex]::Matches($Content, $LinkPattern)
    
    foreach ($Link in $Links) {
        $LinkText = $Link.Groups[1].Value
        $LinkUrl = $Link.Groups[2].Value
        $TotalLinks++
        
        # Skip external URLs if InternalOnly
        if ($InternalOnly -and ($LinkUrl -match '^https?://')) {
            continue
        }
        
        # Skip internal links if ExternalOnly
        if ($ExternalOnly -and -not ($LinkUrl -match '^https?://')) {
            continue
        }
        
        # Check external links
        if ($LinkUrl -match '^https?://') {
            if ($Verbose) {
                Write-Host "  External: $LinkUrl" -ForegroundColor DarkGray
            }
            # Note: Full external link validation requires HTTP requests
            # For now, just check format
            if ($LinkUrl -notmatch '^https?://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}') {
                Write-Host "  [ERROR] Invalid external URL format: $LinkUrl" -ForegroundColor Red
                Write-Host "    in file: $RelativePath" -ForegroundColor Red
                $ErrorCount++
            }
        }
        # Check internal links
        else {
            # Handle anchor-only links
            if ($LinkUrl -match '^#') {
                if ($Verbose) {
                    Write-Host "  Anchor: $LinkUrl (in same file)" -ForegroundColor DarkGray
                }
                # Check if anchor exists in current file
                $AnchorName = $LinkUrl.Substring(1)
                $AnchorPattern = "^#{1,6}\s+.*$AnchorName"
                if ($Content -notmatch $AnchorPattern) {
                    Write-Host "  [WARNING] Anchor not found: $LinkUrl" -ForegroundColor Yellow
                    Write-Host "    in file: $RelativePath" -ForegroundColor Yellow
                    $WarningCount++
                }
                continue
            }
            
            # Split URL and anchor
            $UrlParts = $LinkUrl -split '#'
            $FilePath = $UrlParts[0]
            $Anchor = if ($UrlParts.Length -gt 1) { $UrlParts[1] } else { $null }
            
            # Resolve relative path
            $BaseDir = Split-Path $File.FullName -Parent
            $TargetPath = Join-Path $BaseDir $FilePath
            $TargetPath = [System.IO.Path]::GetFullPath($TargetPath)
            
            if ($Verbose) {
                Write-Host "  Internal: $FilePath" -ForegroundColor DarkGray
            }
            
            # Check if target file exists
            if (-not (Test-Path $TargetPath)) {
                Write-Host "  [ERROR] Broken link: $LinkUrl" -ForegroundColor Red
                Write-Host "    in file: $RelativePath" -ForegroundColor Red
                Write-Host "    target not found: $TargetPath" -ForegroundColor Red
                $ErrorCount++
            }
            # Check anchor if specified
            elseif ($Anchor) {
                $TargetContent = Get-Content $TargetPath -Raw
                $AnchorPattern = "^#{1,6}\s+.*$Anchor"
                if ($TargetContent -notmatch $AnchorPattern) {
                    Write-Host "  [WARNING] Anchor not found: #$Anchor" -ForegroundColor Yellow
                    Write-Host "    in file: $RelativePath" -ForegroundColor Yellow
                    Write-Host "    target file: $TargetPath" -ForegroundColor Yellow
                    $WarningCount++
                }
            }
        }
    }
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Total links checked: $TotalLinks" -ForegroundColor Gray
Write-Host "Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $WarningCount" -ForegroundColor $(if ($WarningCount -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "FAILED: Documentation has broken links" -ForegroundColor Red
    exit 1
} elseif ($WarningCount -gt 0) {
    Write-Host "WARNING: Documentation has missing anchors" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "SUCCESS: All links are valid" -ForegroundColor Green
    exit 0
}

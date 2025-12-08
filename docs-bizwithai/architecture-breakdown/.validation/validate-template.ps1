# Template Compliance Validation Script for OFBiz Architecture Documentation
# Validates that all documents follow the required template structure

param(
    [string]$DocsPath = ".",
    [switch]$Verbose
)

$ErrorCount = 0
$WarningCount = 0
$TotalDocs = 0

Write-Host "=== OFBiz Architecture Documentation - Template Compliance Validator ===" -ForegroundColor Cyan
Write-Host "Scanning directory: $DocsPath" -ForegroundColor Gray
Write-Host ""

# Required sections for technical documents
$RequiredSections = @(
    "Purpose",
    "Audience",
    "Prerequisites",
    "Related Documents"
)

# Get all markdown files (excluding README, INDEX, and template files)
$MarkdownFiles = Get-ChildItem -Path $DocsPath -Filter "*.md" -Recurse | Where-Object { 
    $_.FullName -notlike "*\.templates*" -and
    $_.Name -ne "README.md" -and
    $_.Name -ne "00-INDEX.md" -and
    $_.Name -notlike "*-TEMPLATE.md" -and
    $_.Name -notlike "*-EXAMPLES.md"
}

Write-Host "Found $($MarkdownFiles.Count) documents to validate" -ForegroundColor Gray
Write-Host ""

foreach ($File in $MarkdownFiles) {
    $RelativePath = $File.FullName.Replace((Get-Location).Path, "").TrimStart('\')
    $TotalDocs++
    
    if ($Verbose) {
        Write-Host "Checking: $RelativePath" -ForegroundColor Gray
    }
    
    $Content = Get-Content $File.FullName -Raw
    $MissingSections = @()
    
    # Check for required sections
    foreach ($Section in $RequiredSections) {
        # Check for bold format: **Purpose**:
        $Pattern = "\*\*$Section\*\*:"
        if ($Content -notmatch $Pattern) {
            $MissingSections += $Section
        }
    }
    
    if ($MissingSections.Count -gt 0) {
        Write-Host "  [ERROR] Missing required sections in: $RelativePath" -ForegroundColor Red
        foreach ($Missing in $MissingSections) {
            Write-Host "    - $Missing" -ForegroundColor Red
        }
        $ErrorCount++
    } elseif ($Verbose) {
        Write-Host "  ✓ All required sections present" -ForegroundColor Green
    }
    
    # Check for Overview section
    if ($Content -notmatch "^##\s+Overview" -and $Content -notmatch "^##\s+Introduction") {
        Write-Host "  [WARNING] Missing Overview/Introduction section in: $RelativePath" -ForegroundColor Yellow
        $WarningCount++
    }
    
    # Check for navigation links at bottom
    $HasNext = $Content -match "\*\*Next\*\*:"
    $HasUp = $Content -match "\*\*Up\*\*:"
    $HasHome = $Content -match "\*\*Home\*\*:"
    
    if (-not ($HasUp -or $HasHome)) {
        Write-Host "  [WARNING] Missing navigation links (Up/Home) in: $RelativePath" -ForegroundColor Yellow
        $WarningCount++
    }
    
    # Check for collapsible code blocks
    $CodeBlocks = [regex]::Matches($Content, '```[\w]*\s+([\s\S]*?)```')
    foreach ($Block in $CodeBlocks) {
        $CodeContent = $Block.Groups[1].Value
        $LineCount = ($CodeContent -split "`n").Count
        
        # If code block has more than 10 lines, check if it's in a details block
        if ($LineCount -gt 10) {
            $BlockStart = $Block.Index
            # Look backwards for <details> tag
            $PrecedingContent = $Content.Substring(0, $BlockStart)
            $HasDetails = $PrecedingContent -match '<details>[\s\S]*$'
            
            if (-not $HasDetails) {
                Write-Host "  [WARNING] Code block with $LineCount lines not in collapsible block" -ForegroundColor Yellow
                Write-Host "    in file: $RelativePath" -ForegroundColor Yellow
                Write-Host "    Code blocks >10 lines should be in <details> tags" -ForegroundColor Yellow
                $WarningCount++
                break  # Only warn once per file
            }
        }
    }
    
    # Check for document metadata at bottom
    if ($Content -notmatch "Version:") {
        if ($Verbose) {
            Write-Host "  [INFO] Missing version metadata in: $RelativePath" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Total documents checked: $TotalDocs" -ForegroundColor Gray
Write-Host "Errors (missing required sections): $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings (missing recommended sections): $WarningCount" -ForegroundColor $(if ($WarningCount -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "FAILED: $ErrorCount document(s) missing required sections" -ForegroundColor Red
    Write-Host "Required sections: Purpose, Audience, Prerequisites, Related Documents" -ForegroundColor Red
    exit 1
} elseif ($WarningCount -gt 0) {
    Write-Host "WARNING: $WarningCount document(s) missing recommended sections" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "SUCCESS: All documents comply with template requirements" -ForegroundColor Green
    exit 0
}

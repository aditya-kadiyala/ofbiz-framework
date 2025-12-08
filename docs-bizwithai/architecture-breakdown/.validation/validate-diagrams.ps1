# Diagram Presence Validation Script for OFBiz Architecture Documentation
# Validates that all technical documents contain at least one diagram

param(
    [string]$DocsPath = ".",
    [switch]$Verbose
)

$ErrorCount = 0
$TotalDocs = 0
$DocsWithDiagrams = 0

Write-Host "=== OFBiz Architecture Documentation - Diagram Presence Validator ===" -ForegroundColor Cyan
Write-Host "Scanning directory: $DocsPath" -ForegroundColor Gray
Write-Host ""

# Get all markdown files (excluding README, INDEX, and template files)
$MarkdownFiles = Get-ChildItem -Path $DocsPath -Filter "*.md" -Recurse | Where-Object { 
    $_.FullName -notlike "*\.templates*" -and
    $_.Name -ne "README.md" -and
    $_.Name -ne "00-INDEX.md" -and
    $_.Name -notlike "*-TEMPLATE.md"
}

Write-Host "Found $($MarkdownFiles.Count) technical documents to validate" -ForegroundColor Gray
Write-Host ""

foreach ($File in $MarkdownFiles) {
    $RelativePath = $File.FullName.Replace((Get-Location).Path, "").TrimStart('\')
    $TotalDocs++
    
    if ($Verbose) {
        Write-Host "Checking: $RelativePath" -ForegroundColor Gray
    }
    
    $Content = Get-Content $File.FullName -Raw
    
    # Check for Mermaid diagrams
    $HasMermaid = $Content -match '```mermaid'
    
    # Check for PlantUML diagrams
    $HasPlantUML = $Content -match '```plantuml'
    
    # Check for image references (PNG, SVG, JPG)
    $HasImage = $Content -match '!\[.*\]\(.*\.(png|svg|jpg|jpeg)\)'
    
    $HasDiagram = $HasMermaid -or $HasPlantUML -or $HasImage
    
    if ($HasDiagram) {
        $DocsWithDiagrams++
        if ($Verbose) {
            $DiagramTypes = @()
            if ($HasMermaid) { $DiagramTypes += "Mermaid" }
            if ($HasPlantUML) { $DiagramTypes += "PlantUML" }
            if ($HasImage) { $DiagramTypes += "Image" }
            Write-Host "  ✓ Has diagram(s): $($DiagramTypes -join ', ')" -ForegroundColor Green
        }
    } else {
        Write-Host "  [ERROR] No diagram found in: $RelativePath" -ForegroundColor Red
        Write-Host "    Technical documents MUST include at least one diagram" -ForegroundColor Red
        $ErrorCount++
    }
    
    # Additional check: If has mermaid, validate basic syntax
    if ($HasMermaid) {
        $MermaidBlocks = [regex]::Matches($Content, '```mermaid\s+([\s\S]*?)```')
        foreach ($Block in $MermaidBlocks) {
            $DiagramContent = $Block.Groups[1].Value.Trim()
            
            # Check if diagram block is empty
            if ([string]::IsNullOrWhiteSpace($DiagramContent)) {
                Write-Host "  [ERROR] Empty Mermaid diagram block in: $RelativePath" -ForegroundColor Red
                $ErrorCount++
            }
            
            # Check for common diagram types
            $ValidTypes = @('classDiagram', 'sequenceDiagram', 'erDiagram', 'flowchart', 'graph', 'stateDiagram', 'gantt', 'pie')
            $HasValidType = $false
            foreach ($Type in $ValidTypes) {
                if ($DiagramContent -match $Type) {
                    $HasValidType = $true
                    break
                }
            }
            
            if (-not $HasValidType -and $Verbose) {
                Write-Host "  [WARNING] Mermaid diagram may be missing type declaration" -ForegroundColor Yellow
                Write-Host "    in file: $RelativePath" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Total technical documents: $TotalDocs" -ForegroundColor Gray
Write-Host "Documents with diagrams: $DocsWithDiagrams" -ForegroundColor Gray
Write-Host "Documents missing diagrams: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "FAILED: $ErrorCount document(s) missing required diagrams" -ForegroundColor Red
    Write-Host "Every technical document MUST include at least one diagram" -ForegroundColor Red
    exit 1
} else {
    Write-Host "SUCCESS: All technical documents contain diagrams" -ForegroundColor Green
    exit 0
}

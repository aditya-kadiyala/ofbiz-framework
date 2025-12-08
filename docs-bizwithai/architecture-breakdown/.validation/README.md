# Documentation Validation Scripts

This directory contains validation scripts to ensure the quality and consistency of the OFBiz Architecture Documentation.

## Available Scripts

### 1. validate-all.ps1 (Master Validator)

Runs all validation checks and generates a comprehensive report.

**Usage**:
```powershell
# Run all validations
.\validate-all.ps1

# Run with verbose output
.\validate-all.ps1 -Verbose

# Skip external link validation (faster)
.\validate-all.ps1 -SkipExternal

# Custom paths
.\validate-all.ps1 -DocsPath ".." -OFBizRoot "../../.."
```

**Exit Codes**:
- `0`: All checks passed
- `1`: One or more checks failed

---

### 2. validate-template.ps1

Validates that documents follow the required template structure.

**Checks**:
- Required sections present (Purpose, Audience, Prerequisites, Related Documents)
- Overview/Introduction section exists
- Navigation links present (Up, Home)
- Code blocks >10 lines are in collapsible `<details>` blocks
- Document metadata present

**Usage**:
```powershell
# Basic validation
.\validate-template.ps1

# With verbose output
.\validate-template.ps1 -Verbose

# Custom docs path
.\validate-template.ps1 -DocsPath ".."
```

---

### 3. validate-diagrams.ps1

Validates that all technical documents contain at least one diagram.

**Checks**:
- Presence of Mermaid diagrams
- Presence of PlantUML diagrams
- Presence of image references
- Mermaid diagram syntax (basic)
- Empty diagram blocks

**Usage**:
```powershell
# Basic validation
.\validate-diagrams.ps1

# With verbose output
.\validate-diagrams.ps1 -Verbose

# Custom docs path
.\validate-diagrams.ps1 -DocsPath ".."
```

---

### 4. validate-links.ps1

Validates all internal and external links in markdown files.

**Checks**:
- Internal file links point to existing files
- Anchor links point to existing headings
- External URL format is valid
- Relative paths resolve correctly

**Usage**:
```powershell
# Validate all links
.\validate-links.ps1

# Internal links only
.\validate-links.ps1 -InternalOnly

# External links only
.\validate-links.ps1 -ExternalOnly

# With verbose output
.\validate-links.ps1 -Verbose

# Custom docs path
.\validate-links.ps1 -DocsPath ".."
```

---

### 5. validate-code-refs.ps1

Validates that all code file references point to existing files in the OFBiz codebase.

**Checks**:
- File references in format `**File**: \`path/to/file.java\``
- Inline code paths in backticks
- Paths resolve to actual files in OFBiz

**Usage**:
```powershell
# Basic validation
.\validate-code-refs.ps1

# With verbose output
.\validate-code-refs.ps1 -Verbose

# Custom paths
.\validate-code-refs.ps1 -DocsPath ".." -OFBizRoot "../../.."
```

---

## Validation Workflow

### During Development

Run individual validators as you work on specific aspects:

```powershell
# After adding diagrams
.\validate-diagrams.ps1 -Verbose

# After adding links
.\validate-links.ps1 -InternalOnly -Verbose

# After adding code references
.\validate-code-refs.ps1 -Verbose
```

### Before Committing

Run the master validator to ensure everything passes:

```powershell
.\validate-all.ps1
```

### In CI/CD Pipeline

Add to your CI/CD pipeline:

```yaml
# Example GitHub Actions
- name: Validate Documentation
  run: |
    cd ofbiz-framework/docs-bizwithai/architecture-breakdown/.validation
    pwsh -File validate-all.ps1
```

---

## Validation Rules

### Template Compliance

**Required Sections** (must be present):
- `**Purpose**:` - What the document covers
- `**Audience**:` - Who should read it
- `**Prerequisites**:` - What to read first
- `**Related Documents**:` - Links to related docs

**Recommended Sections**:
- `## Overview` or `## Introduction`
- Navigation links (`**Next**:`, `**Up**:`, `**Home**:`)
- Document metadata (Version, Last Updated, Status)

### Diagram Requirements

**Every technical document MUST include at least one diagram**:
- Mermaid diagram (preferred)
- PlantUML diagram
- Image reference (PNG, SVG, JPG)

**Excluded from requirement**:
- README.md files
- 00-INDEX.md
- Template files

### Link Validation

**Internal Links**:
- Must point to existing files
- Anchors must exist in target files
- Relative paths must resolve correctly

**External Links**:
- Must have valid URL format
- Should use HTTPS where possible

### Code References

**Format**:
- `**File**: \`framework/path/to/file.java\``
- Inline: \`framework/path/to/file.java\`

**Requirements**:
- Paths must be relative to OFBiz root
- Files must exist in the codebase
- Use forward slashes (/)

### Collapsible Code Blocks

Code blocks with more than 10 lines should be in collapsible `<details>` blocks:

```markdown
<details>
<summary>View Source Code</summary>

\`\`\`java
// Long code snippet here
\`\`\`

</details>
```

---

## Troubleshooting

### "Script cannot be loaded because running scripts is disabled"

Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Path not found" errors

Ensure you're running scripts from the `.validation` directory or provide correct paths:
```powershell
cd ofbiz-framework/docs-bizwithai/architecture-breakdown/.validation
.\validate-all.ps1
```

### False positives for anchors

Anchor validation is case-sensitive and whitespace-sensitive. Ensure:
- Anchor names match heading text exactly
- Use lowercase and hyphens (GitHub style)
- Example: `#visual-architecture` for heading `## Visual Architecture`

---

## Exit Codes

All scripts use consistent exit codes:
- `0`: Success (all checks passed)
- `1`: Failure (one or more errors found)
- Warnings do not cause failure (exit 0)

---

## Continuous Improvement

These validation scripts are living tools. If you identify new validation needs:

1. Document the requirement in the design document
2. Add validation logic to appropriate script
3. Update this README
4. Test thoroughly before committing

---

**Last Updated**: December 2024
**Maintained By**: Documentation Team

# Documentation Style Guide

**Version:** 1.0.0
**Last Updated:** 2025-11-18
**Status:** Active

This guide documents the standard patterns and conventions for all documentation in this repository, derived from Phase 0 training modules and existing best practices.

---

## Table of Contents

- [YAML Frontmatter](#yaml-frontmatter)
- [Section Organization](#section-organization)
- [Prerequisites Sections](#prerequisites-sections)
- [Exercises](#exercises)
- [Quick Reference Sections](#quick-reference-sections)
- [Code Examples](#code-examples)
- [Cross-Platform Documentation](#cross-platform-documentation)
- [Component README Template](#component-readme-template)
- [Document Types](#document-types)

---

## YAML Frontmatter

### Standard Metadata Header

All documentation should include a metadata header at the top of the file. Use bold key-value pairs (not YAML frontmatter delimiters) for consistency with the existing codebase:

```markdown
# Document Title

**Version:** 1.0.0
**Last Updated:** YYYY-MM-DD
**Status:** Draft | Active | Deprecated
```

### Extended Metadata for Reports

Generated reports should include additional metadata:

```markdown
# Report Title

**Generated:** YYYY-MM-DD
**Project:** Personal Dotfiles Repository
**Analysis Scope:** [Relevant scope]
**Status:** [Status with emoji indicator]
```

### Status Indicators

- `Draft` - Work in progress, not ready for use
- `Active` - Current and maintained
- `Deprecated` - Scheduled for removal or replacement
- `Archived` - Historical reference only

---

## Section Organization

### Standard Hierarchy

Use consistent heading levels:

```markdown
# Document Title (H1) - One per document

## Major Section (H2) - Primary content divisions

### Subsection (H3) - Supporting details

#### Detail Section (H4) - Fine-grained information (use sparingly)
```

### Required Sections by Document Type

#### Setup/Installation Guides
1. Overview/Introduction
2. Prerequisites
3. Installation Steps
4. Configuration
5. Verification
6. Troubleshooting
7. Quick Reference

#### Configuration Guides
1. Overview
2. Prerequisites
3. Configuration Options
4. Examples
5. Advanced Usage
6. Quick Reference

#### Troubleshooting Guides
1. Overview
2. Common Issues (organized by category)
3. Diagnostic Steps
4. Solutions
5. Prevention

### Table of Contents

Include a table of contents for documents exceeding 300 lines:

```markdown
## Table of Contents

- [Section One](#section-one)
- [Section Two](#section-two)
  - [Subsection](#subsection)
- [Quick Reference](#quick-reference)
```

---

## Prerequisites Sections

### Standard Format

Prerequisites should be clearly listed at the beginning of relevant documents:

```markdown
## Prerequisites

Before proceeding, ensure you have:

- [ ] **Operating System:** macOS 12+ or Ubuntu 20.04+
- [ ] **Tools:** Git 2.30+, Bash 5.0+ or Zsh 5.8+
- [ ] **Knowledge:** Basic command line familiarity
- [ ] **Access:** Administrator/sudo privileges
```

### Categorized Prerequisites

For complex documents, categorize prerequisites:

```markdown
## Prerequisites

### System Requirements
- macOS 12+ (Monterey) or Ubuntu 20.04+
- 2GB free disk space
- Internet connection for package downloads

### Required Tools
- Git 2.30 or newer
- Homebrew (macOS) or apt (Linux)
- A text editor (VS Code, Neovim, etc.)

### Knowledge Requirements
- Basic terminal/command line usage
- Understanding of dotfiles concept
- Familiarity with your preferred shell
```

### Verification Commands

Include commands to verify prerequisites:

```markdown
### Verify Prerequisites

```bash
# Check Git version
git --version  # Should be 2.30+

# Check shell
echo $SHELL
$SHELL --version

# Check Homebrew (macOS)
brew --version
```
```

---

## Exercises

### Exercise Format

When including hands-on exercises, use this consistent format:

```markdown
## Exercises

### Exercise 1: [Descriptive Title]

**Objective:** [What the user will learn/accomplish]

**Time Estimate:** [X minutes]

**Steps:**

1. First action to take
   ```bash
   command-to-run
   ```

2. Second action to take
   ```bash
   another-command
   ```

**Expected Result:**
```
Expected output or state
```

**Verification:**
```bash
command-to-verify-success
```

---
```

### Exercise Difficulty Levels

Label exercises with difficulty:

- **Beginner** - Basic operations, following exact instructions
- **Intermediate** - Requires understanding, some customization
- **Advanced** - Complex scenarios, troubleshooting required

### Exercise Best Practices

1. Start with clear objectives
2. Provide exact commands (copy-paste ready)
3. Show expected output
4. Include verification steps
5. Offer hints for common mistakes
6. Separate exercises with horizontal rules

---

## Quick Reference Sections

### Standard Quick Reference Format

Every guide should end with a Quick Reference section for common operations:

```markdown
## Quick Reference

### Common Commands

| Command | Description |
|---------|-------------|
| `command-one` | Brief description |
| `command-two` | Brief description |
| `command-three` | Brief description |

### Key Locations

| Path | Purpose |
|------|---------|
| `~/.config/tool/` | Configuration files |
| `~/.local/share/tool/` | Data files |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel operation |
| `Ctrl+D` | Exit shell |
```

### Cheat Sheet Style

For comprehensive tools, use a condensed cheat sheet format:

```markdown
## Quick Reference

### Setup
```bash
./install.sh          # Full installation
./install.sh --check  # Dry run
```

### Daily Use
```bash
git pull origin main  # Update dotfiles
stow */               # Re-link all packages
```

### Troubleshooting
```bash
./scripts/health-check.sh  # Diagnose issues
stow -R package-name       # Re-stow package
```
```

---

## Code Examples

### Language Specification

Always specify the language for code blocks:

```markdown
```bash
echo "Shell commands"
```

```zsh
# Zsh-specific syntax
```

```python
print("Python code")
```

```json
{"config": "value"}
```
```

### Command Prompts

Omit shell prompts (`$`, `%`, `#`) for copy-paste friendliness:

**Do:**
```bash
echo "Hello World"
cd ~/.config
```

**Don't:**
```bash
$ echo "Hello World"
$ cd ~/.config
```

### Output Examples

Show expected output in separate blocks or with comments:

```bash
git status
# Output:
# On branch main
# nothing to commit, working tree clean
```

Or use a separate block:

```bash
git status
```

Output:
```
On branch main
nothing to commit, working tree clean
```

### Inline Code

Use backticks for:
- Commands: `stow git`
- File names: `~/.zshrc`
- Variables: `$HOME`
- Configuration keys: `theme`

---

## Cross-Platform Documentation

### Platform-Specific Sections

Clearly mark platform-specific content:

```markdown
### Installation

#### macOS

```bash
brew install package-name
```

#### Linux (Ubuntu/Debian)

```bash
sudo apt install package-name
```

#### Linux (Fedora/RHEL)

```bash
sudo dnf install package-name
```
```

### Inline Platform Notes

For brief differences, use inline notation:

```bash
# Install the package
brew install tool      # macOS
sudo apt install tool  # Linux (Debian/Ubuntu)
```

### Architecture-Specific Notes

When relevant, note architecture differences:

```markdown
> **Apple Silicon Note:** On M1/M2 Macs, Homebrew installs to `/opt/homebrew`.
> Ensure this is in your PATH.
```

---

## Component README Template

Use this template for all component directories (git/, neovim/, etc.):

```markdown
# Component Name

Brief one-line description of what this component configures.

## Overview

2-3 sentences explaining:
- What this component does
- Why it's included in the dotfiles
- Key features or customizations

## Prerequisites

- Required tools or dependencies
- Minimum versions if applicable

## Installation

```bash
stow component-name
```

## Configuration

### Main Configuration

Explanation of primary configuration file(s).

### Key Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `option` | `value` | What it does |

## Local Overrides

How to customize without modifying tracked files:

```bash
# Create local override
touch ~/.config/tool/local.conf
```

## Troubleshooting

### Common Issue

**Problem:** Description of issue

**Solution:**
```bash
fix-command
```

## Quick Reference

```bash
command-one   # Description
command-two   # Description
```
```

---

## Document Types

### Type-Specific Guidelines

#### Guides (SETUP, USAGE, CONFIGURATION)
- Focus on step-by-step instructions
- Include screenshots or diagrams for complex UIs
- Provide both quick-start and detailed paths
- End with Quick Reference

#### Reference Documents (TROUBLESHOOTING)
- Organize by problem category
- Use consistent Problem/Solution format
- Include diagnostic commands
- Cross-reference related issues

#### Reports (Analysis, Validation)
- Include generation metadata
- Use executive summary format
- Provide actionable recommendations
- Include status indicators

#### Templates (PR, Issues)
- Use checkboxes for required items
- Include clear section headers
- Provide examples where helpful
- Keep concise but complete

---

## Formatting Conventions

### Lists

Use `-` for unordered lists:
```markdown
- Item one
- Item two
  - Nested item
```

Use numbers for sequential steps:
```markdown
1. First step
2. Second step
3. Third step
```

### Emphasis

- **Bold** for UI elements, important terms, file names in context
- *Italic* for introducing new terms, emphasis in prose
- `Code` for commands, paths, variables, configuration values

### Callouts

Use blockquotes for important notes:

```markdown
> **Note:** Additional context or tips.

> **Warning:** Critical information to prevent errors.

> **macOS:** Platform-specific information.
```

### Horizontal Rules

Use `---` to separate major sections or exercises:

```markdown
## Section One

Content here.

---

## Section Two

More content.
```

---

## Maintenance

### Review Cycle

- Review all documentation quarterly
- Update version numbers when content changes
- Move deprecated docs to `docs/archive/`
- Maintain changelog for significant updates

### Quality Checklist

Before committing documentation changes:

- [ ] Metadata header present and accurate
- [ ] All code blocks have language specified
- [ ] Commands tested and working
- [ ] Cross-platform variations documented
- [ ] Quick Reference section included (for guides)
- [ ] Links verified
- [ ] Spelling and grammar checked

---

## Examples

### Well-Formatted Document Example

See these documents as examples of good style:
- `docs/USAGE_GUIDE.md` - Comprehensive guide with exercises
- `docs/GHOSTTY_TROUBLESHOOTING.md` - Problem/solution format
- `docs/STARSHIP_CONFIGURATION.md` - Configuration reference

### Template Files

- `.github/pull_request_template.md` - PR template
- `.github/ISSUE_TEMPLATE/bug_report.md` - Bug report template
- `.github/ISSUE_TEMPLATE/feature_request.md` - Feature request template

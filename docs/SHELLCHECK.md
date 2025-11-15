# ShellCheck Integration

This document explains how to use ShellCheck to maintain shell script quality in the dotfiles repository.

## Overview

ShellCheck is a static analysis tool for shell scripts that helps identify bugs, portability issues, and coding style problems. This repository includes ShellCheck configuration and tooling to ensure high-quality shell scripts.

## Quick Start

### Installation

Install ShellCheck using your system's package manager:

```bash
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt install shellcheck

# Fedora/RHEL
sudo dnf install ShellCheck

# Arch Linux
sudo pacman -S shellcheck
```

### Running ShellCheck

Use the provided script to check all shell scripts in the repository:

```bash
# Check all scripts
./scripts/run-shellcheck.sh

# Check specific file
./scripts/run-shellcheck.sh install.sh

# Show summary only
./scripts/run-shellcheck.sh --summary

# Show auto-fixable issues
./scripts/run-shellcheck.sh --fix
```

### Manual Checks

You can also run ShellCheck directly on individual files:

```bash
shellcheck install.sh
shellcheck scripts/setup-packages.sh
```

## Configuration

ShellCheck is configured via `.shellcheckrc` in the repository root:

- **Enabled checks**: Additional optional checks for better code quality
- **Disabled checks**: SC1090, SC1091 (non-constant source paths)
- **Severity threshold**: Warning level and above
- **Optional checks**:
  - `add-default-case`: Require default case in switch statements
  - `avoid-nullary-conditions`: Avoid conditions without comparisons
  - `check-unassigned-uppercase`: Check for unassigned uppercase variables
  - `quote-safe-variables`: Require quoting of variables
  - `require-variable-braces`: Require braces around variables

## Common Issues and Fixes

### SC2164: Use 'cd ... || exit' in case cd fails

**Problem:**
```bash
cd "$DOTFILES_DIR"
```

**Fix:**
```bash
cd "$DOTFILES_DIR" || exit 1
# or for functions:
cd "$DOTFILES_DIR" || return 1
```

### SC2086: Double quote to prevent globbing and word splitting

**Problem:**
```bash
cp $file $destination
```

**Fix:**
```bash
cp "$file" "$destination"
```

### SC2155: Declare and assign separately to avoid masking return values

**Problem:**
```bash
local result=$(some_command)
```

**Fix:**
```bash
local result
result=$(some_command) || return 1
```

### SC2181: Check exit code directly instead of $?

**Problem:**
```bash
some_command
if [ $? -eq 0 ]; then
    echo "Success"
fi
```

**Fix:**
```bash
if some_command; then
    echo "Success"
fi
```

## Critical Fixes Applied

The following critical issues have been fixed in key files:

### install.sh
- **SC2164**: Added error checks for `cd` commands (lines 40, 599)
- Changed `cd "$DOTFILES_DIR"` to `cd "$DOTFILES_DIR" || return 1`

### scripts/lib/utils.sh
- **SC2086**: Separated pwd command substitution into variable (line 412)
- Improved error handling for `stow` command

### scripts/setup-packages.sh
- **SC2164**: Added error checks for `cd` commands (lines 10, 190)
- Changed `cd "$DOTFILES_DIR"` to `cd "$DOTFILES_DIR" || exit 1`

## Repository Statistics

Based on the analysis report:
- **Total scripts**: 34 shell scripts
- **Total lines**: 9,079 lines of code
- **Estimated warnings**: 100-200+ before fixes
- **Common patterns found**:
  - SC2155: 69+ instances (declare and assign separately)
  - SC2086: 50+ instances (unquoted variables)
  - SC2164: 12+ instances (cd without check)
  - SC2181: 2+ instances (check exit code directly)

## Pre-commit Hook Integration

To automatically check scripts before committing, create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash

# Run shellcheck on all shell scripts
echo "Running ShellCheck..."

if ./scripts/run-shellcheck.sh --summary; then
    echo "ShellCheck passed!"
    exit 0
else
    echo "ShellCheck failed. Please fix the issues above."
    echo "To skip this check, use: git commit --no-verify"
    exit 1
fi
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## CI Integration

### GitHub Actions

Add to `.github/workflows/shellcheck.yml`:

```yaml
name: ShellCheck

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  shellcheck:
    name: ShellCheck Analysis
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install ShellCheck
        run: sudo apt-get install -y shellcheck

      - name: Run ShellCheck
        run: ./scripts/run-shellcheck.sh --summary
```

### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
shellcheck:
  stage: test
  image: koalaman/shellcheck-alpine:stable
  script:
    - ./scripts/run-shellcheck.sh --summary
  only:
    - merge_requests
    - main
```

## Best Practices

1. **Always quote variables**: Use `"$var"` instead of `$var`
2. **Check cd commands**: Always use `cd ... || exit 1` or `cd ... || return 1`
3. **Declare and assign separately**: Separate variable declaration from command substitution
4. **Use shellcheck directives**: For intentional exceptions, use `# shellcheck disable=SC####`
5. **Test before committing**: Run `./scripts/run-shellcheck.sh` before committing changes
6. **Fix warnings**: Don't ignore warnings; they often indicate real bugs
7. **Use set -euo pipefail**: Enable strict error handling in scripts

## Additional Resources

- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [ShellCheck GitHub](https://github.com/koalaman/shellcheck)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)

## Troubleshooting

### ShellCheck not found
Ensure ShellCheck is installed and in your PATH. See the Installation section above.

### False positives
If you encounter a false positive, you can disable specific checks using:
```bash
# shellcheck disable=SC2086
some_command $intentionally_unquoted
```

### Too many warnings
Start by fixing critical issues (SC2164, SC2086) first, then gradually address other warnings.

### Script-specific configuration
You can add ShellCheck directives at the top of individual scripts:
```bash
#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090
```

## Contributing

When adding new shell scripts:
1. Add appropriate shebang: `#!/usr/bin/env bash`
2. Enable error handling: `set -euo pipefail`
3. Run ShellCheck before committing
4. Fix all critical warnings (SC2164, SC2086)
5. Document any intentional ShellCheck disables

## Future Improvements

- Automated fixing of simple issues
- Integration with VS Code/other editors
- Regular automated scans via CI/CD
- Tracking ShellCheck score improvements over time
- Adding more custom ShellCheck rules

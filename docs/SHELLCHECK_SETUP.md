# ShellCheck Integration Setup Guide

This guide provides quick setup instructions for the ShellCheck integration in this dotfiles repository.

## Quick Setup

### 1. Install ShellCheck

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

### 2. Test the Integration

Run ShellCheck on all scripts:

```bash
./scripts/run-shellcheck.sh
```

View summary only:

```bash
./scripts/run-shellcheck.sh --summary
```

### 3. Enable Pre-commit Hook (Optional)

Configure git to use the provided hooks:

```bash
git config core.hooksPath .githooks
```

This will automatically run ShellCheck before each commit.

### 4. Enable CI Integration (Optional)

The repository includes CI configurations:

- **GitHub Actions**: `.github/workflows/shellcheck.yml` (auto-enabled)
- **GitLab CI**: Include `.gitlab-ci-shellcheck.yml` in your main `.gitlab-ci.yml`

## What Was Fixed

### Critical Issues Resolved

1. **SC2164** - cd without error checking:
   - `/home/user/dotfiles/install.sh` (lines 40, 599)
   - `/home/user/dotfiles/scripts/setup-packages.sh` (lines 10, 190)

2. **SC2086** - Unquoted variables:
   - `/home/user/dotfiles/scripts/lib/utils.sh` (line 412)

### Files Modified

- `/home/user/dotfiles/install.sh` - Added error checks for cd commands
- `/home/user/dotfiles/scripts/lib/utils.sh` - Improved command substitution handling
- `/home/user/dotfiles/scripts/setup-packages.sh` - Added error checks for cd commands

## Configuration Files

- `.shellcheckrc` - ShellCheck configuration
- `scripts/run-shellcheck.sh` - Script to run ShellCheck on all scripts
- `.githooks/pre-commit` - Git pre-commit hook
- `.github/workflows/shellcheck.yml` - GitHub Actions workflow
- `.gitlab-ci-shellcheck.yml` - GitLab CI configuration

## Documentation

For detailed documentation, see `/home/user/dotfiles/docs/SHELLCHECK.md`

## Common Commands

```bash
# Check all scripts
./scripts/run-shellcheck.sh

# Check specific file
./scripts/run-shellcheck.sh install.sh

# Show summary
./scripts/run-shellcheck.sh --summary

# Show auto-fixable issues
./scripts/run-shellcheck.sh --fix

# Run shellcheck directly on a file
shellcheck install.sh
```

## Next Steps

1. Review remaining warnings: `./scripts/run-shellcheck.sh --summary`
2. Fix high-priority issues (SC2155, SC2086 instances)
3. Enable pre-commit hook: `git config core.hooksPath .githooks`
4. Run ShellCheck before committing changes

## Support

For issues or questions:
- Check `/home/user/dotfiles/docs/SHELLCHECK.md` for detailed documentation
- Visit [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- See [ShellCheck GitHub](https://github.com/koalaman/shellcheck)

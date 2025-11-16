# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them by creating a private security advisory on GitHub or by contacting the maintainer directly through GitHub.

You should receive a response within 48 hours. If for some reason you do not, please follow up to ensure we received your original message.

Please include the following information:
- Type of issue (e.g., command injection, path traversal, etc.)
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## What to Expect

- Acknowledgment of your report within 48 hours
- Regular updates on our progress (at least every 5 business days)
- Notification when the issue is fixed
- Credit in the release notes (unless you prefer to remain anonymous)

## Security Best Practices

When using these dotfiles:

1. **Never commit sensitive data**
   - Use `*.local` files for personal information
   - Keep credentials in `.env` files (gitignored)
   - Review `.gitignore` before committing

2. **Review scripts before execution**
   - Especially scripts downloaded from the internet
   - Check setup-*.sh scripts for unexpected behavior
   - Understand what install scripts will do to your system

3. **Use SSH keys properly**
   - Never commit private keys
   - Use SSH agent for key management
   - Set appropriate file permissions (600 for private keys)

4. **Keep dependencies updated**
   - Regularly update packages: `brew upgrade`, `apt update && apt upgrade`
   - Monitor security advisories for installed tools
   - Review the CHANGELOG for security-related updates

5. **Use .local files for customization**
   - Never commit `.zshrc.local`, `.gitconfig.local`, etc.
   - These files are gitignored by default
   - Store sensitive configuration there

## Scope

This security policy applies to:
- Installation scripts
- Configuration files
- Shell scripts and utilities
- Documentation examples

Out of scope:
- Third-party tools installed by these dotfiles
- Operating system vulnerabilities
- Hardware issues

## Known Security Considerations

### Script Execution
The installation scripts require running with user privileges and will:
- Download and install packages
- Modify shell configuration files
- Create symlinks to configuration files
- Execute setup scripts for various tools

Always review the scripts before running them on your system.

### Backup System
The backup system creates timestamped backups before making changes. These backups may contain sensitive information and should be:
- Stored securely
- Excluded from version control
- Deleted when no longer needed

### Third-Party Dependencies
This project installs various third-party tools and dependencies. Each has its own security considerations:
- Homebrew packages (macOS)
- APT/DNF/Pacman packages (Linux)
- Oh My Zsh and plugins
- Tmux plugins
- Node.js packages (if using NVM)

Regularly update these dependencies and review their security advisories.

## Security Update Process

When a security issue is identified:

1. **Assessment**: Evaluate the severity and impact
2. **Fix Development**: Create a patch in a private branch
3. **Testing**: Verify the fix across supported platforms
4. **Disclosure**: Coordinate with the reporter
5. **Release**: Deploy the fix and notify users
6. **Post-Release**: Monitor for any issues

## Contact

For security-related questions or concerns, please create a GitHub issue or contact the maintainer directly.

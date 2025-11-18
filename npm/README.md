# NPM Configuration

This directory contains NPM configuration files and global package lists managed via GNU Stow.

## Files

- `global-packages.txt` - Essential global NPM packages
- `README.md` - This documentation

**Note:** This module does not include a `.npmrc` file. NPM configuration is typically machine-specific and may contain sensitive information (registry tokens, proxy settings). Create your own `~/.npmrc` as needed.

## Setup

1. Create global npm directory (recommended to avoid permission issues):
   ```bash
   mkdir -p ~/.npm-global
   npm config set prefix '~/.npm-global'
   ```

2. Add to shell PATH (add to your `~/.zshrc` or `~/.bashrc`):
   ```bash
   export PATH="$HOME/.npm-global/bin:$PATH"
   ```

3. Install essential global packages:
   ```bash
   # Install all recommended packages
   xargs -a ~/.dotfiles/npm/global-packages.txt npm install -g

   # Or install selectively based on your needs
   npm install -g npm typescript nodemon eslint prettier
   ```

4. (Optional) Create your own `.npmrc`:
   ```bash
   # Set global prefix
   npm config set prefix '~/.npm-global'

   # This creates ~/.npmrc automatically
   ```

## Configuration

### Local Overrides

Create `~/.npmrc.local` for machine-specific or sensitive settings:

```ini
# Company registry
@yourcompany:registry=https://npm.yourcompany.com

# Authentication tokens (never commit)
//registry.npmjs.org/:_authToken=your_token_here

# Proxy settings (if needed)
proxy=http://proxy.company.com:8080
```

### Package Management

The global packages list is organized by category:

- **Development Tools** - Core development utilities
- **Build Tools** - Bundlers and build systems
- **Testing** - Testing frameworks and tools
- **Code Quality** - Linting and formatting
- **Documentation** - Documentation generators
- **Deployment** - CLI tools for deployment platforms

### Custom Installation

Install packages selectively based on your workflow:

```bash
# Web development stack
npm install -g typescript webpack eslint prettier

# Node.js backend development
npm install -g nodemon pm2 jest eslint

# Full-stack development
npm install -g typescript webpack-cli nodemon pm2 jest eslint prettier

# AI/ML development
npm install -g @anthropic-ai/claude-code @mermaid-js/mermaid-cli
```

## Security Notes

- Never commit authentication tokens to version control
- Use `~/.npmrc.local` for sensitive configuration
- Regular security audits are enabled by default
- Consider using `npm audit` to check for vulnerabilities

## Maintenance

```bash
# Update global packages
npm update -g

# Check for outdated packages
npm outdated -g

# Clean npm cache
npm cache clean --force

# Remove unused packages
npm prune -g
```
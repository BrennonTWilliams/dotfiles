# NPM Configuration

This directory contains NPM configuration files and global package lists managed via GNU Stow.

## Files

- `.npmrc` - NPM configuration with development settings
- `global-packages.txt` - Essential global NPM packages
- `.stowrc` - Stow configuration

## Setup

1. Stow the NPM configuration:
   ```bash
   cd ~/.dotfiles
   stow npm
   ```

2. Create global npm directory (if not exists):
   ```bash
   mkdir -p ~/.npm-global
   ```

3. Add to shell PATH (add to your `~/.zshrc` or `~/.bashrc`):
   ```bash
   export PATH="$HOME/.npm-global/bin:$PATH"
   ```

4. Install essential global packages:
   ```bash
   # Install all recommended packages
   xargs -a ~/.dotfiles/npm/global-packages.txt npm install -g

   # Or install selectively based on your needs
   npm install -g npm typescript nodemon eslint prettier
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
# Troubleshooting Guide

## Claude Command Not Found After Restart

**Symptom**: The `claude` command works after running `install.sh --all`, but stops working after restarting the Raspberry Pi.

**Root Cause**: The PATH configuration for Claude Code was only in `.zshrc`, which isn't always sourced early enough for GUI applications like Sway or when starting new terminal sessions.

**Solution**: The PATH configuration has been moved to `.zshenv`, which is sourced earlier in the Zsh initialization sequence and ensures the PATH is available to all shells and GUI applications.

### Zsh Initialization Order

Zsh reads configuration files in this order:

1. **`.zshenv`** - Always sourced (even for non-interactive shells)
   - Use for: PATH, environment variables needed by all shells
   - This is where Claude Code PATH is now configured

2. **`.zprofile`** - Sourced for login shells
   - Use for: Login-specific configuration

3. **`.zshrc`** - Sourced for interactive shells
   - Use for: Aliases, functions, prompts, shell options

4. **`.zlogin`** - Sourced for login shells (after .zshrc)
   - Use for: Commands to run after login

### How to Apply the Fix

On your Raspberry Pi 5:

```bash
# Pull the latest dotfiles changes
cd ~/dotfiles  # or wherever you cloned the dotfiles
git pull

# Reinstall with the updated configuration
./install.sh --all

# Restart your shell or reboot to test
exec zsh
# or
sudo reboot
```

### Verification

After applying the fix:

1. Open a new terminal
2. Run: `echo $PATH` - you should see `.npm-global/bin` in the PATH
3. Run: `which claude` - should show the path to the claude command
4. Run: `claude --version` - should show the version

If you still have issues after reboot, check:

```bash
# Verify .zshenv is symlinked correctly
ls -la ~/.zshenv

# Verify the file contains Claude PATH
cat ~/.zshenv | grep npm-global

# Check current shell
echo $SHELL

# Manually source to test
source ~/.zshenv
```

### Local Overrides

If you need machine-specific environment variables, add them to `~/.zshenv.local`:

```bash
# Example: Add custom PATH entries
export PATH="$HOME/custom/bin:$PATH"

# Example: Set custom environment variables
export MY_CUSTOM_VAR="value"
```

## Other Common Issues

### Oh My Zsh Not Found

If you see "Oh My Zsh not found" errors:

```bash
# Run the Oh My Zsh setup script
cd ~/dotfiles
./scripts/setup-ohmyzsh.sh
```

### NVM Not Working

NVM is configured with lazy loading. The first time you use `node`, `npm`, `nvm`, or `npx`, it will automatically load NVM.

If you need to install NVM:

```bash
cd ~/dotfiles
./scripts/setup-nvm.sh
```

### Sway Not Starting

Check the Sway logs:

```bash
# View Sway logs
journalctl --user -u sway

# Or run Sway with debug output
sway --debug
```

Common Sway issues:
- Missing `~/.config/sway/config.local` - created by install script
- Display configuration issues - edit `~/.config/sway/config.local` to set your display settings

### Permissions Issues

If you get permission errors:

```bash
# Fix permissions on dotfiles
chmod 644 ~/.zshenv ~/.zshrc ~/.bashrc
chmod 755 ~/dotfiles/install.sh ~/dotfiles/scripts/*.sh
```

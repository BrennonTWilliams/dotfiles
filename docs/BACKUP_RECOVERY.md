# Backup & Recovery

Guide to the automatic backup system and recovery procedures.

---

## Table of Contents

- [Automatic Backups](#automatic-backups)
- [Manual Backup](#manual-backup)
- [Restore Procedures](#restore-procedures)
- [Recovery from Conflicts](#recovery-from-conflicts)
- [Backup Management](#backup-management)

---

## Automatic Backups

The installer automatically creates backups when conflicts are detected.

### When Backups Are Created

Backups are created automatically when:
- Running `./install.sh --all` with existing dotfiles
- Running `./install.sh --dotfiles` with conflicts
- Using `--auto-resolve=overwrite` strategy
- Choosing "Overwrite" during interactive conflict resolution

### Backup Location

```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

Example:
```
~/.dotfiles_backup_20250123_143022/
├── gitconfig.backup
├── gitconfig.backup.meta
├── zshrc.backup
├── zshrc.backup.meta
└── tmux.conf.backup
```

### Backup Metadata

Each backup includes a `.meta` file with:

```bash
$ cat ~/.dotfiles_backup_20250123_143022/gitconfig.backup.meta

original_path=/Users/username/.gitconfig
backup_date=Wed Jan 23 14:30:22 PST 2025
backup_reason=overwritten
file_size=2847
file_lines=145
```

---

## Manual Backup

### Before Major Changes

```bash
# Create timestamped backup
cp -r ~/.dotfiles ~/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)

# Or backup specific files
mkdir -p ~/dotfiles_manual_backup
cp ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/dotfiles_manual_backup/
```

### Backup Critical Configurations

```bash
# Backup local overrides (not in git)
cp ~/.zshrc.local ~/backup_zshrc.local
cp ~/.gitconfig.local ~/backup_gitconfig.local
cp ~/.tmux.local ~/backup_tmux.local
```

### Full Repository Backup

```bash
# Create compressed archive
tar -czf dotfiles_backup_$(date +%Y%m%d).tar.gz ~/.dotfiles

# Verify archive
tar -tzf dotfiles_backup_*.tar.gz | head -20
```

---

## Restore Procedures

### Quick Recovery

```bash
# List all available backups
./scripts/recover.sh --list

# Restore from the latest backup (with confirmation)
./scripts/recover.sh --latest

# Interactive mode - select what to restore
./scripts/recover.sh --interactive
```

### Restore Specific Files

```bash
# Manual restore of specific file
cp ~/.dotfiles_backup_20250123_143022/gitconfig.backup ~/.gitconfig

# Remove symlink first if it exists
rm ~/.gitconfig
cp ~/.dotfiles_backup_20250123_143022/gitconfig.backup ~/.gitconfig
```

### Restore from Specific Backup

```bash
# List backups to find the one you want
./scripts/recover.sh --list

# Restore from specific backup
./scripts/recover.sh --backup ~/.dotfiles_backup_20250123_143022
```

### Verify Before Restoring

```bash
# Check backup integrity
./scripts/recover.sh --verify ~/.dotfiles_backup_20250123_143022

# Preview what would be restored (dry run)
./scripts/recover.sh --backup ~/.dotfiles_backup_20250123_143022 --dry-run
```

### Recovery Script Options

```bash
./scripts/recover.sh --help

# Common flags
--force      # Skip confirmation prompts
--dry-run    # Preview without making changes
--list       # List all available backups
--verify     # Check backup integrity
--latest     # Use most recent backup
--interactive # Select files interactively
```

---

## Recovery from Conflicts

### During Installation

If installation fails due to conflicts:

1. **Check the error message** - It shows which files conflict
2. **View the conflicts:**
   ```bash
   ./install.sh --preview --dotfiles
   ```
3. **Choose a resolution strategy:**
   ```bash
   # Keep your existing files
   ./install.sh --dotfiles --auto-resolve=keep-existing

   # Backup and overwrite
   ./install.sh --dotfiles --auto-resolve=overwrite

   # Interactive resolution
   ./install.sh --dotfiles
   ```

### After Failed Installation

```bash
# 1. Find the backup directory
ls -la ~/.dotfiles_backup_*

# 2. Restore the backup
./scripts/recover.sh --latest

# 3. Or manually restore specific files
cp ~/.dotfiles_backup_*/zshrc.backup ~/.zshrc
```

### Stow Conflict Resolution

If stow reports conflicts:

```bash
# Remove the conflicting symlink
rm ~/.zshrc

# Re-run stow
cd ~/.dotfiles
stow zsh
```

---

## Backup Management

### List All Backups

```bash
ls -la ~/.dotfiles_backup_*
```

### View Backup Contents

```bash
# List files in a backup
ls -la ~/.dotfiles_backup_20250123_143022/

# View metadata
cat ~/.dotfiles_backup_20250123_143022/*.meta
```

### Clean Up Old Backups

```bash
# Remove backups older than 30 days
find ~ -maxdepth 1 -name ".dotfiles_backup_*" -type d -mtime +30 -exec rm -rf {} \;

# Or remove specific backup
rm -rf ~/.dotfiles_backup_20250123_143022
```

### Backup Best Practices

1. **Before major updates:** Always backup before running `git pull` on dotfiles
2. **Keep recent backups:** Maintain at least the last 3-5 backups
3. **Backup local files:** Remember to backup `.local` files separately (they're gitignored)
4. **Off-site backup:** Consider copying critical backups to cloud storage

---

## Safety Features

The recovery system includes:

- **Verification** - Checks backup integrity before restoring
- **Safety Backup** - Creates backup of current files before overwriting
- **Confirmation Prompts** - Asks for confirmation before changes
- **Dry Run Mode** - Preview changes without applying
- **Selective Restore** - Choose which files to restore

---

## Troubleshooting

### Backup Not Found

```bash
# Check if backups exist
ls ~/.dotfiles_backup_* 2>/dev/null || echo "No backups found"

# Check backup directory permissions
ls -la ~ | grep dotfiles_backup
```

### Restore Failed

```bash
# Check file permissions
ls -la ~/.dotfiles_backup_*/

# Try manual restore
cp -v ~/.dotfiles_backup_*/<file>.backup ~/<file>
```

### Corrupted Backup

```bash
# Verify backup
./scripts/recover.sh --verify ~/.dotfiles_backup_20250123_143022

# If corrupted, use an older backup
./scripts/recover.sh --list
./scripts/recover.sh --backup ~/.dotfiles_backup_<older_date>
```

---

## See Also

- [INSTALLATION_OPTIONS.md](INSTALLATION_OPTIONS.md) - Conflict resolution during installation
- [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - General troubleshooting
- [GETTING_STARTED.md](GETTING_STARTED.md) - Installation guide

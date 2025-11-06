# .zprofile - This file is sourced only for login shells
# Use this file for commands and settings that should run on login,
# but not every time a new shell is opened.
#
# The standard load order is: .zshenv → .zprofile → .zshrc
# .zprofile is loaded only in login shells, not for every new terminal.

# Homebrew setup
# Check for both Apple Silicon and Intel locations
if [ -x "/opt/homebrew/bin/brew" ]; then
  # Apple Silicon Mac
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
elif command -v brew >/dev/null 2>&1; then
  # If brew is in PATH but not in the standard locations
  eval "$(brew shellenv)"
fi

# Python Environment Setup
# Configure pyenv if installed
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# SSH Agent for Dev Containers
# This sets up SSH agent for development containers and remote sessions
if [ -z "$SSH_AUTH_SOCK" ] || ! [ -e "$SSH_AUTH_SOCK" ]; then
   # Ensure .ssh directory exists
   if ! [ -d "$HOME/.ssh" ]; then
       mkdir -p "$HOME/.ssh"
       chmod 700 "$HOME/.ssh"
   fi

   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> "$HOME/.ssh/ssh-agent"
   fi

   # Only try to load agent if the file exists
   if [ -f "$HOME/.ssh/ssh-agent" ]; then
       eval `cat "$HOME/.ssh/ssh-agent"` > /dev/null
       # Only add keys if we have any
       if ls "$HOME/.ssh"/id_* 1> /dev/null 2>&1; then
           ssh-add > /dev/null 2>&1
       fi
   fi
fi

# NPM Global Packages Path
# Add npm global packages to PATH if the directory exists
if [ -d "$HOME/.npm-global" ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Load local overrides
if [ -f "$HOME/.zprofile.local" ]; then
    source "$HOME/.zprofile.local"
fi
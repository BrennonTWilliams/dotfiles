# ==============================================================================
# zsh-abbr Abbreviations Loader
# ==============================================================================
# This file is sourced when DOTFILES_ABBR_MODE is "abbr" (the default)
# Set DOTFILES_ABBR_MODE="alias" in ~/.zshenv.local to use traditional aliases

# Suppress "Added..." and "will now expand..." messages during shell startup
export ABBR_QUIET=1
export ABBR_QUIETER=1

# ==============================================================================
# Detect and Load zsh-abbr
# ==============================================================================

local abbr_path=""

# Check Homebrew paths (macOS Apple Silicon)
if [[ -f "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-abbr/zsh-abbr.zsh"
# Check Homebrew paths (macOS Intel)
elif [[ -f "/usr/local/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="/usr/local/share/zsh-abbr/zsh-abbr.zsh"
# Check Linuxbrew path
elif [[ -f "/home/linuxbrew/.linuxbrew/share/zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="/home/linuxbrew/.linuxbrew/share/zsh-abbr/zsh-abbr.zsh"
# Check manual installation
elif [[ -f "${ZDOTDIR:-$HOME}/.zsh-abbr/zsh-abbr.zsh" ]]; then
    abbr_path="${ZDOTDIR:-$HOME}/.zsh-abbr/zsh-abbr.zsh"
fi

# Exit gracefully if zsh-abbr not found
if [[ -z "$abbr_path" ]]; then
    echo "[dotfiles] zsh-abbr not found. Install with: brew install olets/tap/zsh-abbr"
    echo "[dotfiles] Falling back to traditional aliases"
    return 0
fi

# Give this shell a private zsh-job-queue dir. zsh-abbr's bundled job queue
# otherwise funnels every shell's startup through one shared dir
# ($TMPDIR/zsh-job-queue/zsh-abbr) and stalls 30s behind any job left by a
# shell killed mid-startup (e.g. tmux-resurrect replacing panes). The dir
# is keyed by PID and removed after init (zf_rm: builtin, no fork).
zmodload -F zsh/files b:zf_rm
JOB_QUEUE_TMPDIR="${${TMPDIR:-/tmp}%/}/zsh-job-queue-$$"
zf_rm -rf -- "$JOB_QUEUE_TMPDIR"
autoload -Uz add-zsh-hook
_dotfiles_abbr_queue_cleanup() { zf_rm -rf -- "$JOB_QUEUE_TMPDIR" }
add-zsh-hook zshexit _dotfiles_abbr_queue_cleanup

# Load zsh-abbr
source "$abbr_path"

# zsh-abbr 6.x runs `job-queue pop` -- an `rm` fork -- after every `abbr`
# call, even `abbr -S` calls that never queued a job (empty job id). With
# ~160 abbreviations that is ~0.3s of startup. Skip only that no-op case.
if (( $+functions[job-queue__zsh-abbr] )); then
    functions[_dotfiles_job_queue_orig]=$functions[job-queue__zsh-abbr]
    job-queue__zsh-abbr() {
        [[ $1 == pop && -z $3 ]] && return 0
        _dotfiles_job_queue_orig "$@"
    }
fi
zf_rm -rf -- "$JOB_QUEUE_TMPDIR"

# ==============================================================================
# Load Abbreviation Category Files
# ==============================================================================

local abbr_dir="${0:A:h}"

for file in "$abbr_dir"/*.zsh; do
    # Skip this init file
    [[ "${file:t}" == "_init.zsh" ]] && continue
    # Source category file
    [[ -f "$file" ]] && source "$file"
done

unset abbr_path abbr_dir

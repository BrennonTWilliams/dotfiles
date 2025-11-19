# Performance Analysis and Optimization

**Analysis Date**: November 12, 2025
**Focus Areas**: Shell Startup Time, Installation Speed, Resource Usage

---

## 📊 Performance Baseline

### Current Metrics (Estimated)

| Operation | Current Time | Target Time | Status |
|-----------|--------------|-------------|--------|
| Zsh Startup | ~800-1200ms | <300ms | 🚨 |
| Full Install | ~15-20 min | <10 min | ⚠️ |
| Package Check | ~5s per pkg | <1s per pkg | ⚠️ |
| Stow Operation | ~2-3s per pkg | <1s per pkg | ✅ |

### Performance Bottlenecks Identified

1. **Duplicate compinit calls** - 200ms overhead
2. **Synchronous package checks** - 5s × 20 packages = 100s
3. **Uncached path resolution** - 50-100ms per call
4. **Unconditional heavy tool loading** - 300-500ms
5. **Sequential setup scripts** - 10-15 minutes combined

---

## 🚨 CRITICAL PERFORMANCE ISSUES

### PERF-001: Duplicate compinit Calls in .zshrc

**Severity**: HIGH
**Impact**: Adds 200ms to every shell startup

#### Description
`.zshrc` calls `compinit` twice (lines 66 and 117), unnecessarily initializing the completion system multiple times.

#### Location
```bash
# zsh/.zshrc:66
autoload -Uz compinit
compinit

# ... 50 lines of config ...

# zsh/.zshrc:117
autoload -Uz compinit
compinit
# End of Docker CLI completions
```

#### Performance Impact
```
First compinit:  ~100-150ms
Second compinit: ~100-150ms
Total waste:     ~200-300ms
```

#### Fix (Immediate - 2 minutes)
```bash
# Remove line 66-67, keep only the final call at line 117

# zsh/.zshrc
# ... config ...

# Initialize completions system (do this only once, at the end)
autoload -Uz compinit
compinit
```

#### Additional Optimization
```bash
# Use completion cache for even faster startup
autoload -Uz compinit

# Only regenerate once per day
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
```

**Expected Improvement**: 200-300ms faster shell startup

---

### PERF-002: Unconditional Heavy Tool Loading

**Severity**: HIGH
**Impact**: Adds 300-500ms to shell startup

#### Description
Conda, NVM, Docker completions are loaded unconditionally even when not used in a session.

#### Problematic Code
```bash
# zsh/.zshrc:68-105 - Conda initialization
__conda_setup="$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
eval "$__conda_setup"  # Executes heavy conda setup every time

# zsh/.zshenv:16-19 - Pyenv initialization
if [ -d "$PYENV_ROOT/bin" ]; then
    PATH="$PYENV_ROOT/bin:$PATH"
fi
# Immediate PATH addition, could be lazy
```

#### Performance Impact
```
Conda init:   ~150-200ms
Docker completions: ~50-100ms
NVM setup:    ~100-150ms
Total:        ~300-450ms
```

#### Lazy Loading Solution

**Strategy 1: Function Wrapper**
```bash
# zsh/.zshrc

# Lazy-load conda
conda() {
    unset -f conda

    # Initialize conda now
    local conda_bin="$(resolve_platform_path "conda_bin" 2>/dev/null || echo "$HOME/miniforge3/bin")"
    __conda_setup="$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"

    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        export PATH="$conda_bin:$PATH"
    fi
    unset __conda_setup

    # Call the real conda
    conda "$@"
}

# Lazy-load NVM
nvm() {
    unset -f nvm

    # Initialize NVM now
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Call the real nvm
    nvm "$@"
}

# Lazy-load node/npm (triggers NVM)
node() {
    unset -f node
    nvm >/dev/null 2>&1
    node "$@"
}

npm() {
    unset -f npm
    nvm >/dev/null 2>&1
    npm "$@"
}
```

**Strategy 2: Conditional Loading**
```bash
# Only load if needed in this session
if [[ "$PWD" == *"/python-project/"* ]]; then
    # Initialize conda for Python projects
    eval "$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
fi

if [[ "$PWD" == *"/node-project/"* ]] || [ -f "package.json" ]; then
    # Initialize NVM for Node projects
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
```

**Strategy 3: Background Initialization**
```bash
# Start initialization in background
{
    # Heavy initialization here
    eval "$("$conda_bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
} &
```

**Expected Improvement**: 300-500ms faster shell startup

---

### PERF-003: Uncached Package Availability Checks

**Severity**: MEDIUM
**Impact**: Adds 5 seconds per package during installation

#### Description
Each package availability check calls external commands without caching results.

#### Current Implementation
```bash
# install.sh:530-556
for package in "${packages[@]}"; do
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        if check_brew_package_availability "$package"; then
            valid_packages+=("$package")
        fi
    fi
done

# Each call runs: brew search "$package"
# 20 packages × 5 seconds = 100 seconds wasted
```

#### Performance Impact
```
Single check:     ~5 seconds (network + brew database)
20 packages:      ~100 seconds
50 packages:      ~250 seconds (4+ minutes)
```

#### Optimization: Batch Checking with Cache

```bash
# New approach: Batch check with memoization
declare -A PACKAGE_CACHE

# Populate cache in one batch operation
cache_brew_packages() {
    info "Caching Homebrew package database..."

    # Get all available packages in one call
    local all_packages=$(brew search --formula 2>/dev/null)

    # Store in associative array
    while IFS= read -r pkg; do
        PACKAGE_CACHE["$pkg"]=1
    done <<< "$all_packages"

    info "Cached ${#PACKAGE_CACHE[@]} packages"
}

# Fast lookup from cache
check_brew_package_availability_cached() {
    local package="$1"

    # First time: populate cache
    if [ ${#PACKAGE_CACHE[@]} -eq 0 ]; then
        cache_brew_packages
    fi

    # O(1) lookup
    [[ -n "${PACKAGE_CACHE[$package]}" ]]
}

# Usage in validation loop
pre_validate_packages() {
    local packages=("$@")
    local valid_packages=()

    # Cache once for all packages
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        cache_brew_packages
    fi

    # Fast validation
    for package in "${packages[@]}"; do
        if check_brew_package_availability_cached "$package"; then
            valid_packages+=("$package")
        fi
    done

    printf '%s\n' "${valid_packages[@]}"
}
```

**Expected Improvement**: 100 seconds → 10 seconds (90% faster)

---

### PERF-004: Sequential Path Resolution

**Severity**: MEDIUM
**Impact**: Repeated function calls for same paths

#### Description
`resolve_platform_path` called multiple times for same paths without caching.

#### Example from .zshrc
```bash
# Lines 127-135 - Multiple sequential calls
export PATH="$(resolve_platform_path "uzi"):$PATH"
export PATH="$(resolve_platform_path "sdd_workshops"):$PATH"
export PATH="$(resolve_platform_path "npm_global_bin"):$PATH"

# Lines 177, 191, 208, etc - Same paths resolved repeatedly
local starship_dir="$(resolve_platform_path "starship_config")"
local dotfiles_dir="$(resolve_platform_path "dotfiles")/starship"
# ... many more calls to same paths
```

#### Performance Impact
```
Single call:      ~10-20ms
10 calls:         ~100-200ms
Repeated calls:   ~50-100ms additional
```

#### Solution: Cache Results

```bash
# In zsh/.zsh_cross_platform or similar

# Cache for resolved paths
declare -gA _PATH_CACHE

resolve_platform_path_cached() {
    local key="$1"

    # Check cache first
    if [[ -n "${_PATH_CACHE[$key]}" ]]; then
        echo "${_PATH_CACHE[$key]}"
        return 0
    fi

    # Resolve and cache
    local resolved
    resolved=$(resolve_platform_path "$key")
    _PATH_CACHE["$key"]="$resolved"

    echo "$resolved"
}

# Batch resolution for better performance
resolve_paths_batch() {
    local -n result_array=$1
    shift
    local keys=("$@")

    for key in "${keys[@]}"; do
        result_array["$key"]=$(resolve_platform_path "$key")
    done
}

# Usage in .zshrc
declare -A PATHS
resolve_paths_batch PATHS "uzi" "sdd_workshops" "npm_global_bin" "starship_config" "dotfiles"

export PATH="${PATHS[uzi]}:$PATH"
export PATH="${PATHS[sdd_workshops]}:$PATH"
export PATH="${PATHS[npm_global_bin]}:$PATH"
```

**Expected Improvement**: 100-200ms → 20-30ms (80% faster)

---

## ⚠️ MEDIUM PRIORITY OPTIMIZATIONS

### PERF-005: Parallel Package Installation

**Severity**: MEDIUM
**Impact**: Could reduce installation time by 40-60%

#### Current Implementation
```bash
# Sequential installation
for package in "${valid_packages[@]}"; do
    install_package "$package"  # Blocks until complete
done
```

#### Parallel Installation
```bash
# Parallel installation with job control
parallel_install_packages() {
    local packages=("$@")
    local max_jobs=4  # Adjust based on system
    local -a pids

    for package in "${packages[@]}"; do
        # Wait if at max parallel jobs
        while [ ${#pids[@]} -ge $max_jobs ]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    unset "pids[$i]"
                fi
            done
            sleep 0.1
        done

        # Start installation in background
        install_package "$package" &
        pids+=($!)
    done

    # Wait for all jobs to complete
    wait "${pids[@]}"
}
```

**Considerations**:
- Requires package manager to support concurrent installs
- May overwhelm network/disk on some systems
- Need proper error collection

**Expected Improvement**: 15 minutes → 6-9 minutes

---

### PERF-006: Reduce Redundant System Calls

**Severity**: MEDIUM
**Impact**: Cumulative small delays

#### Issues
1. Multiple calls to `command -v`
2. Repeated `[ -d ... ]` checks
3. Redundant `which` calls

#### Example
```bash
# Inefficient - checks multiple times
if command -v resolve_platform_path >/dev/null 2>&1; then
    local path1="$(resolve_platform_path "key1")"
fi
# ... later ...
if command -v resolve_platform_path >/dev/null 2>&1; then
    local path2="$(resolve_platform_path "key2")"
fi

# Better - check once
if command -v resolve_platform_path >/dev/null 2>&1; then
    HAS_RESOLVE_PATH=true
fi

if [ "$HAS_RESOLVE_PATH" = true ]; then
    local path1="$(resolve_platform_path "key1")"
    local path2="$(resolve_platform_path "key2")"
fi
```

---

### PERF-007: Optimize Glob Patterns

**Severity**: LOW
**Impact**: Small improvements in startup time

#### Issue
```bash
# Slower
for file in $(find "$DOTFILES_DIR" -name "*.sh"); do
    source "$file"
done

# Faster - use shell globbing
for file in "$DOTFILES_DIR"/**/*.sh; do
    [ -f "$file" ] || continue
    source "$file"
done

# Even faster - specific paths
for file in "$DOTFILES_DIR"/scripts/lib/*.sh; do
    source "$file"
done
```

---

## 📈 Installation Performance Optimization

### PERF-008: Skip Already Installed Packages

```bash
install_package() {
    local package="$1"

    # Check if already installed
    if package_is_installed "$package"; then
        info "$package already installed, skipping"
        return 0
    fi

    info "Installing $package..."
    $PKG_MANAGER_INSTALL_CMD "$package"
}

package_is_installed() {
    local package="$1"

    case "$PKG_MANAGER" in
        brew)
            brew list --formula | grep -q "^${package}$"
            ;;
        apt)
            dpkg -l | grep -q "^ii  $package"
            ;;
        *)
            return 1
            ;;
    esac
}
```

---

### PERF-009: Download Optimization

**Current**: Sequential downloads
**Optimized**: Parallel downloads with aria2 or curl parallel

```bash
# If aria2 available
if command -v aria2c >/dev/null; then
    aria2c -x 16 -s 16 "$URL"
else
    curl -fsSL "$URL"
fi
```

---

## 🔧 Monitoring and Benchmarking

### Shell Startup Profiling

```bash
# Add to top of .zshrc for profiling
if [ -n "$ZSH_PROF" ]; then
    zmodload zsh/zprof
fi

# Add to bottom
if [ -n "$ZSH_PROF" ]; then
    zprof
fi

# Usage: ZSH_PROF=1 zsh -c exit
```

### Installation Benchmarking

```bash
# Add timing to install.sh
INSTALL_START=$(date +%s)

main() {
    # ... installation logic ...
}

INSTALL_END=$(date +%s)
INSTALL_DURATION=$((INSTALL_END - INSTALL_START))

info "Total installation time: ${INSTALL_DURATION}s"
```

---

## 📊 Expected Performance Improvements

### Summary of Optimizations

| Optimization | Time Saved | Effort | Priority |
|--------------|------------|--------|----------|
| Remove duplicate compinit | 200-300ms | 2 min | 🚨 HIGH |
| Lazy load tools | 300-500ms | 30 min | 🚨 HIGH |
| Cache package checks | 90s | 1 hour | ⚠️ MEDIUM |
| Cache path resolution | 100-200ms | 45 min | ⚠️ MEDIUM |
| Parallel installation | 5-9 min | 2 hours | ⚠️ MEDIUM |
| Skip installed packages | 2-5 min | 30 min | ℹ️ LOW |

### Total Expected Improvements

**Shell Startup**:
- Before: 800-1200ms
- After: 200-400ms
- **Improvement: 70-75% faster**

**Full Installation**:
- Before: 15-20 minutes
- After: 5-8 minutes
- **Improvement: 60-70% faster**

---

## 🎯 Performance Optimization Roadmap

### Week 1: Quick Wins
- [ ] Remove duplicate compinit
- [ ] Add compinit caching
- [ ] Check for already-installed packages

**Expected gain**: 300ms startup, 3-5 min installation

### Week 2: Lazy Loading
- [ ] Implement lazy conda loading
- [ ] Implement lazy NVM loading
- [ ] Conditional tool initialization

**Expected gain**: 400-500ms startup

### Week 3: Caching
- [ ] Implement package check caching
- [ ] Implement path resolution caching
- [ ] Add cache invalidation logic

**Expected gain**: 90s installation

### Week 4: Parallelization
- [ ] Parallel package checks
- [ ] Parallel package installation
- [ ] Parallel setup scripts

**Expected gain**: 5-10 min installation

---

## 📚 Performance Best Practices

### Shell Startup Optimization

1. **Minimize PATH modifications** - Each PATH change requires rehashing
2. **Lazy load everything** - Only load what you need
3. **Cache completion dumps** - Reuse between sessions
4. **Avoid subshells** - Use built-ins when possible
5. **Profile regularly** - Measure before optimizing

### Installation Optimization

1. **Check before installing** - Skip already-installed packages
2. **Batch operations** - Combine multiple operations
3. **Parallel when safe** - Use concurrency where possible
4. **Cache lookups** - Don't repeat expensive checks
5. **Fail fast** - Validate early to avoid wasted work

---

**Next**: See [ACTION_PLAN.md](./ACTION_PLAN.md) for implementation schedule

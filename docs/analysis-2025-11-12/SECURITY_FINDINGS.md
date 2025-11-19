# Security Findings and Vulnerabilities

**Analysis Date**: November 12, 2025
**Severity Levels**: 🚨 Critical | ⚠️ High | ⚡ Medium | ℹ️ Low

---

## 🚨 CRITICAL SEVERITY

### SEC-001: Unsafe Remote Script Execution

**Severity**: 🚨 CRITICAL
**CVSS Score**: 9.1 (Critical)
**CWE**: CWE-494 (Download of Code Without Integrity Check)

#### Description
Multiple installation scripts pipe remote content directly to shell interpreters without integrity verification, creating a critical supply chain attack vector.

#### Affected Files
1. `scripts/setup-ohmyzsh.sh:18`
2. `scripts/setup-nvm.sh:19`
3. `scripts/setup-terminal.sh:79`

#### Vulnerable Code
```bash
# scripts/setup-ohmyzsh.sh:18
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# scripts/setup-nvm.sh:19
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

# scripts/setup-terminal.sh:79
RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Attack Vectors
1. **Man-in-the-Middle (MITM)**: Network attacker intercepts HTTP traffic
2. **DNS Poisoning**: Attacker redirects to malicious server
3. **Repository Compromise**: Upstream repository is compromised
4. **CDN Compromise**: Content delivery network serves malicious content

#### Impact
- Complete system compromise
- Arbitrary code execution with user privileges
- Credential theft
- Malware installation
- Data exfiltration

#### Remediation

**Recommended Solution**:
```bash
#!/usr/bin/env bash
# Secure installation with checksum verification

install_ohmyzsh_secure() {
    local install_script="/tmp/ohmyzsh-install-$$.sh"
    local expected_sha256="EXPECTED_CHECKSUM_HERE"  # Get from official source
    local url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

    info "Downloading Oh My Zsh installer..."
    if ! curl -fsSL "$url" -o "$install_script"; then
        error "Failed to download installer"
        return 1
    fi

    info "Verifying checksum..."
    if ! echo "$expected_sha256 $install_script" | sha256sum --check --status; then
        error "Checksum verification failed - possible MITM attack"
        rm -f "$install_script"
        return 1
    fi

    info "Checksum verified, running installer..."
    bash "$install_script" --unattended
    local exit_code=$?

    rm -f "$install_script"
    return $exit_code
}
```

**Alternative Solution** (with GPG verification):
```bash
install_nvm_secure() {
    local install_script="/tmp/nvm-install-$$.sh"
    local sig_file="/tmp/nvm-install-$$.sh.sig"
    local url="https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh"

    # Download installer and signature
    curl -fsSL "$url" -o "$install_script"
    curl -fsSL "$url.sig" -o "$sig_file"

    # Import public key and verify signature
    gpg --import nvm-maintainer-key.asc
    if ! gpg --verify "$sig_file" "$install_script"; then
        error "GPG verification failed"
        rm -f "$install_script" "$sig_file"
        return 1
    fi

    bash "$install_script"
    rm -f "$install_script" "$sig_file"
}
```

**Minimal Solution** (if checksums unavailable):
```bash
# At minimum, inspect before execution
curl -fsSL "$url" -o /tmp/install.sh
less /tmp/install.sh  # Manual inspection
read -p "Execute this script? (yes/no): " confirm
[[ "$confirm" == "yes" ]] && bash /tmp/install.sh
rm /tmp/install.sh
```

#### Timeline
- **Detection**: November 12, 2025
- **Recommended Fix Date**: Within 48 hours
- **Priority**: P0 (Critical)

---

### SEC-002: Command Injection via Unvalidated eval

**Severity**: 🚨 CRITICAL
**CVSS Score**: 8.8 (High)
**CWE**: CWE-78 (OS Command Injection)

#### Description
Test scripts use `eval` on external input without sanitization, enabling arbitrary command execution.

#### Affected Files
1. `tests/test_ghostty_shell_integration.sh:54`
2. `tests/test_installation_integration.sh:107`
3. `tests/test_installation_integration.sh:120`
4. `tests/test_shell_integration.sh:75`

#### Vulnerable Code
```bash
# tests/test_ghostty_shell_integration.sh:54
if eval "$test_command"; then
    log_success "Test passed"
fi

# tests/test_installation_integration.sh:107
eval "$command"

# tests/test_installation_integration.sh:120
eval "$command"
```

#### Attack Vector
```bash
# Malicious test case injection
test_command="rm -rf / # malicious payload"
eval "$test_command"  # Executes destructive command
```

#### Impact
- Arbitrary command execution
- File system modification/deletion
- Privilege escalation (if run with sudo)
- Test suite compromise

#### Remediation

**Option 1: Remove eval (Preferred)**
```bash
# Before
eval "$test_command"

# After - Direct execution with explicit error handling
if bash -c "$test_command"; then
    log_success "Test passed"
else
    log_failure "Test failed"
fi
```

**Option 2: Input Validation**
```bash
validate_command() {
    local cmd="$1"

    # Whitelist allowed commands
    local allowed_pattern='^(test|grep|cat|echo|ls|pwd|which|command)\s'

    if [[ ! "$cmd" =~ $allowed_pattern ]]; then
        error "Command not in whitelist: $cmd"
        return 1
    fi

    # Check for dangerous characters
    if [[ "$cmd" =~ [;\|\&\$\(\)\`] ]]; then
        error "Dangerous characters detected in command"
        return 1
    fi

    return 0
}

# Usage
if validate_command "$test_command"; then
    eval "$test_command"
else
    error "Invalid or unsafe command"
fi
```

**Option 3: Function-based Testing**
```bash
# Replace eval with explicit function calls
run_test() {
    local test_name="$1"

    case "$test_name" in
        "shell_integration")
            test_shell_integration
            ;;
        "ghostty_config")
            test_ghostty_config
            ;;
        *)
            error "Unknown test: $test_name"
            return 1
            ;;
    esac
}

# Usage
run_test "$test_name"
```

#### Timeline
- **Detection**: November 12, 2025
- **Recommended Fix Date**: Within 72 hours
- **Priority**: P0 (Critical - but isolated to test suite)

---

## ⚠️ HIGH SEVERITY

### SEC-003: Unquoted Variable Expansion

**Severity**: ⚠️ HIGH
**CVSS Score**: 7.3 (High)
**CWE**: CWE-78 (OS Command Injection), CWE-22 (Path Traversal)

#### Description
Widespread unquoted variable expansion enables word splitting, glob expansion, and path traversal attacks.

#### Affected Files
Found in 10+ scripts including:
- `install.sh` (multiple instances)
- `scripts/setup-packages.sh`
- `scripts/setup-terminal.sh`
- Test scripts

#### Vulnerable Patterns
```bash
# Word splitting vulnerability
for pkg in $packages; do  # Should be: "${packages[@]}"
    install_package $pkg   # Should be: "$pkg"
done

# Glob expansion vulnerability
cp $source $dest  # Should be: "$source" "$dest"

# Path traversal vulnerability
cd $user_provided_path  # Should be: "$user_provided_path"
```

#### Attack Examples

**Example 1: Word Splitting**
```bash
# Attacker provides malicious package name
package="vim; rm -rf /tmp/*"
install_package $package  # Executes: install_package vim ; rm -rf /tmp/*
```

**Example 2: Glob Expansion**
```bash
# Attacker creates files: "-rf" and "/home/user"
files="*"
rm $files  # Expands to: rm -rf /home/user
```

**Example 3: Path Traversal**
```bash
# User provides malicious path
backup_dir="../../etc"
cp config.sh $backup_dir/  # Overwrites system files
```

#### Impact
- Command injection
- Unintended file operations
- Path traversal attacks
- Data corruption/loss

#### Remediation

**Rule 1: Always Quote Variables**
```bash
# Before (vulnerable)
cp $source $dest
echo $message
cd $directory

# After (secure)
cp "$source" "$dest"
echo "$message"
cd "$directory"
```

**Rule 2: Quote Arrays Properly**
```bash
# Before (vulnerable)
for item in $array; do
    process $item
done

# After (secure)
for item in "${array[@]}"; do
    process "$item"
done
```

**Rule 3: Validate Input**
```bash
validate_path() {
    local path="$1"

    # Check for path traversal
    if [[ "$path" =~ \.\. ]]; then
        error "Path traversal detected: $path"
        return 1
    fi

    # Ensure path is within expected directory
    local real_path=$(realpath "$path" 2>/dev/null)
    local safe_base=$(realpath "$HOME/.dotfiles")

    if [[ ! "$real_path" =~ ^"$safe_base" ]]; then
        error "Path outside safe directory: $path"
        return 1
    fi

    return 0
}
```

#### Automated Fix Script
```bash
#!/bin/bash
# Fix unquoted variables in shell scripts

find . -name "*.sh" -type f -exec sed -i.bak \
    -e 's/\$\([A-Z_a-z][A-Z_a-z0-9]*\)/"$\1"/g' \
    -e 's/""\$/"$/g' \
    {} +

# Manual review required after automated fixes
```

#### Timeline
- **Detection**: November 12, 2025
- **Recommended Fix Date**: Within 1 week
- **Priority**: P1 (High)

---

### SEC-004: Insufficient Input Validation in Package Installation

**Severity**: ⚠️ HIGH
**CVSS Score**: 6.8 (Medium-High)
**CWE**: CWE-20 (Improper Input Validation)

#### Description
Package names from external sources (files, user input) are not validated before being passed to package managers.

#### Affected Files
- `install.sh:600-606` (package installation loop)
- `scripts/setup-packages.sh:128-130`

#### Vulnerable Code
```bash
# install.sh:600-606
for package in "${valid_packages[@]}"; do
    if install_package "$package"; then  # No validation of package content
        installed=$((installed + 1))
    fi
done
```

#### Attack Vector
```bash
# Malicious packages-macos.txt
git
curl
$(whoami > /tmp/pwned)  # Command injection
vim; rm -rf /tmp/*      # Command chaining
```

#### Remediation
```bash
validate_package_name() {
    local package="$1"

    # Only allow alphanumeric, dash, underscore
    if [[ ! "$package" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        warn "Invalid package name: $package"
        return 1
    fi

    # Check length
    if [ ${#package} -gt 100 ]; then
        warn "Package name too long: $package"
        return 1
    fi

    return 0
}

# Usage in install_package
install_package() {
    local package="$1"

    if ! validate_package_name "$package"; then
        error "Invalid package name rejected: $package"
        return 1
    fi

    # Proceed with installation...
}
```

---

## ⚡ MEDIUM SEVERITY

### SEC-005: Insecure Temporary File Creation

**Severity**: ⚡ MEDIUM
**CVSS Score**: 5.3 (Medium)
**CWE**: CWE-377 (Insecure Temporary File)

#### Description
Several scripts create temporary files without using `mktemp`, enabling race condition attacks.

#### Affected Patterns
```bash
# Predictable temporary file
/tmp/install.sh
/tmp/test_backup_$(basename "$file")
```

#### Remediation
```bash
# Before (vulnerable)
local temp_file="/tmp/install.sh"
curl "$url" > "$temp_file"

# After (secure)
local temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT
curl "$url" > "$temp_file"
```

---

### SEC-006: Missing File Permission Checks

**Severity**: ⚡ MEDIUM
**CVSS Score**: 4.7 (Medium)
**CWE**: CWE-732 (Incorrect Permission Assignment)

#### Description
Scripts don't verify file permissions before execution, potentially executing world-writable scripts.

#### Remediation
```bash
check_file_safety() {
    local file="$1"

    # Check ownership
    if [ "$(stat -c %u "$file")" != "$UID" ]; then
        error "File not owned by current user: $file"
        return 1
    fi

    # Check permissions (reject if writable by others)
    local perms=$(stat -c %a "$file")
    if [ $((perms & 002)) -ne 0 ]; then
        error "File is world-writable: $file"
        return 1
    fi

    return 0
}
```

---

## ℹ️ LOW SEVERITY

### SEC-007: Sensitive Information in Repository

**Severity**: ℹ️ LOW
**CVSS Score**: 3.1 (Low)
**CWE**: CWE-312 (Cleartext Storage of Sensitive Information)

#### Description
Analysis found references to passwords, tokens, and credentials in documentation and test files. While no actual secrets were found, the patterns suggest need for secret scanning.

#### Affected Files
- 23 files containing keywords: PASSWORD, SECRET, TOKEN, API_KEY, CREDENTIAL
- Mostly in documentation and test examples

#### Remediation
1. Implement pre-commit hook with secret scanning
2. Add `.gitignore` patterns for common secret files
3. Document proper secret management practices

```bash
# .git/hooks/pre-commit
#!/bin/bash
# Secret scanning with gitleaks or detect-secrets

if command -v gitleaks >/dev/null 2>&1; then
    gitleaks protect --staged --verbose
fi
```

---

## 🛡️ Security Best Practices

### Recommended Security Checklist

- [ ] All remote scripts verified with checksums
- [ ] All variables properly quoted
- [ ] Input validation on user-provided data
- [ ] Temporary files created with mktemp
- [ ] File permissions checked before execution
- [ ] Error handling prevents information leakage
- [ ] Shellcheck passes without warnings
- [ ] Secret scanning in CI/CD
- [ ] Regular security audits scheduled

### Tools to Integrate

1. **shellcheck** - Static analysis for shell scripts
2. **gitleaks** - Secret scanning
3. **bandit** - Security linting (for any Python scripts)
4. **trivy** - Vulnerability scanning
5. **pre-commit** - Automated pre-commit checks

---

## 📚 References

- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [CWE-78: OS Command Injection](https://cwe.mitre.org/data/definitions/78.html)
- [Bash Best Practices for Security](https://bertvv.github.io/cheat-sheets/Bash.html)
- [Shell Script Security](https://www.shellcheck.net/wiki/)

---

**Next Steps**: See [ACTION_PLAN.md](./ACTION_PLAN.md) for remediation priorities

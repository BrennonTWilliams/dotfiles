# Test Suite

Comprehensive test suite for validating dotfiles installation, configuration, and integration.

## Quick Start

### Run All Tests

```bash
cd ~/.dotfiles/tests
./run_all_tests.sh
```

### Run a Specific Test

```bash
./test_integration.sh
```

### Quick Validation

```bash
./quick_package_validation.sh
```

## Test Inventory

### Test Runner

| File | Purpose |
|------|---------|
| `run_all_tests.sh` | Master test runner - executes all test suites and generates reports |

### Integration Tests

Tests that validate end-to-end functionality and component interaction.

| File | Purpose |
|------|---------|
| `test_integration.sh` | End-to-end integration testing |
| `test_basic_integration.sh` | Basic integration validation |
| `test_installation_integration.sh` | Installation process integration |
| `test_component_interaction.sh` | Component interaction testing |
| `test_shell_integration.sh` | Shell configuration integration |
| `test_user_workflows.sh` | User workflow validation |

### Platform-Specific Tests

Tests for specific operating systems.

| File | Purpose |
|------|---------|
| `test_macos_integration.sh` | macOS-specific integration tests |
| `test_linux_integration.sh` | Linux-specific integration tests |
| `test_cross_platform.sh` | Cross-platform compatibility validation |

### Configuration Tests

Tests for specific configuration modules.

| File | Purpose |
|------|---------|
| `test_ghostty_config_validation.sh` | Ghostty configuration validation |
| `test_ghostty_shell_integration.sh` | Ghostty shell integration |

### Package Tests

Tests for package management and validation.

| File | Purpose |
|------|---------|
| `test_package_validation.sh` | Package installation validation |
| `test_package_manager_validation.sh` | Package manager functionality |
| `quick_package_validation.sh` | Quick package check (fast validation) |

### Safety Tests

| File | Purpose |
|------|---------|
| `test_installation_safe.sh` | Safe installation testing (non-destructive) |

## Test Categories

### By Execution Time

**Quick Tests (< 1 minute):**
- `quick_package_validation.sh`
- `test_basic_integration.sh`
- `test_ghostty_config_validation.sh`

**Standard Tests (1-5 minutes):**
- `test_integration.sh`
- `test_shell_integration.sh`
- `test_package_validation.sh`
- `test_component_interaction.sh`

**Full Suite (5+ minutes):**
- `run_all_tests.sh`

### By Platform

**macOS Only:**
- `test_macos_integration.sh`

**Linux Only:**
- `test_linux_integration.sh`

**Cross-Platform:**
- All other tests

## Running Tests

### Complete Test Suite

```bash
# Run all tests with full reporting
./run_all_tests.sh
```

This will:
1. Run system health check
2. Execute all test modules
3. Generate comprehensive report
4. Create summary file

### Individual Test Suites

```bash
# Integration tests
./test_integration.sh

# Shell integration
./test_shell_integration.sh

# Package validation
./test_package_validation.sh
```

### Quick Validation

For a fast check that core packages are available:

```bash
./quick_package_validation.sh
```

### Platform-Specific Tests

```bash
# macOS
./test_macos_integration.sh

# Linux
./test_linux_integration.sh
```

## Test Output

### Console Output

Tests display results with color-coded status:
- Green: Passed
- Yellow: Warning
- Red: Failed

### Reports

The test runner generates reports in `test_results/`:

```
test_results/
  integration_report_YYYYMMDD_HHMMSS.md  # Detailed report
  latest_summary.txt                     # Quick summary
  test_*.log                             # Individual test logs
```

### Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Writing Tests

### Test Structure

Each test file follows this pattern:

```bash
#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0

# Test function
test_something() {
    local test_name="Something should work"

    if [[ condition ]]; then
        echo -e "${GREEN}PASS${NC}: $test_name"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC}: $test_name"
        ((FAILED++))
    fi
}

# Run tests
test_something

# Summary
echo "Passed: $PASSED"
echo "Failed: $FAILED"

# Exit with appropriate code
[[ $FAILED -eq 0 ]] && exit 0 || exit 1
```

### Best Practices

1. **Idempotent tests** - Tests should not modify system state permanently
2. **Clear naming** - Test names should describe what is being validated
3. **Isolated tests** - Each test should be independent
4. **Fast feedback** - Quick tests should run first
5. **Platform awareness** - Check OS before running platform-specific tests

## CI/CD Integration

### GitHub Actions

The tests can be integrated into CI/CD pipelines. Example workflow:

```yaml
name: Test Dotfiles
on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macos-latest, ubuntu-latest]

    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        run: |
          cd tests
          ./run_all_tests.sh
```

### Local CI Testing

```bash
# Run the same tests CI would run
./run_all_tests.sh
```

## Troubleshooting

### Tests failing immediately

1. Check script permissions:
   ```bash
   chmod +x tests/*.sh
   ```

2. Verify shebang:
   ```bash
   head -1 tests/run_all_tests.sh
   # Should be: #!/bin/bash
   ```

### Platform-specific test failures

1. Verify you're running the correct test for your OS
2. Check that required tools are installed
3. Review test log for specific error messages

### Missing dependencies

If tests fail due to missing tools:

```bash
# Check what's missing
./quick_package_validation.sh

# Install missing packages
# macOS: brew install <package>
# Linux: apt install <package>
```

### Viewing detailed logs

```bash
# Find the most recent log
ls -lt test_results/*.log | head -5

# View log contents
cat test_results/test_integration_YYYYMMDD_HHMMSS.log
```

## Maintenance

### Regular Testing Schedule

- **After changes**: Run relevant test suites
- **Weekly**: Run `quick_package_validation.sh`
- **Monthly**: Run full `run_all_tests.sh`
- **Before releases**: Complete test suite

### Cleaning Up

```bash
# Remove old test results (keeps last 5)
cd test_results
ls -t *.log | tail -n +6 | xargs rm -f
ls -t integration_report_*.md | tail -n +6 | xargs rm -f
```

## Related Documentation

- [TESTING.md](../docs/TESTING.md) - Additional testing documentation
- [CONTRIBUTING.md](../CONTRIBUTING.md) - How to contribute tests
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - General troubleshooting

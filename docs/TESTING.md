# Testing Guide for macOS Dotfiles

This comprehensive testing guide covers all aspects of the macOS dotfiles testing infrastructure, including how to run tests, validate packages, and ensure system integrity.

## 📋 Overview

The macOS dotfiles system includes a robust testing infrastructure designed to validate:
- Package syntax and availability
- Shell configuration integration
- macOS-specific functionality
- Architecture compatibility (Apple Silicon vs Intel)
- Regression testing for previous fixes
- Security and permissions

## 🧪 Test Suites

### Core Test Suites

| Test Suite | Purpose | Command |
|------------|---------|---------|
| **Full Integration Tests** | Complete end-to-end system validation | `./tests/run_all_tests.sh` |
| **Shell Integration** | Shell configuration and PATH validation | `./tests/test_shell_integration.sh` |
| **Component Interaction** | Cross-component compatibility testing | `./tests/test_component_interaction.sh` |
| **User Workflows** | Real-world usage scenario testing | `./tests/test_user_workflows.sh` |
| **macOS-Specific Tests** | macOS features and regression testing | `./tests/test_macos_integration.sh` |
| **Package Validation** | Package syntax and availability checking | `./tests/test_package_validation.sh` |

## 🚀 Quick Start

### Run All Tests

```bash
# Run complete test suite
./tests/run_all_tests.sh

# View results
cat test_results/latest_summary.txt
```

### Run Individual Test Categories

```bash
# Test macOS-specific features
./tests/test_macos_integration.sh

# Validate packages only
./tests/test_package_validation.sh

# Test shell configuration
./tests/test_shell_integration.sh
```

## 📦 Package Validation

The package validation system ensures all packages in `packages-macos.txt` are correctly configured and available.

### Running Package Validation

```bash
# Full package validation
./tests/test_package_validation.sh

# Quick syntax check
bash -n tests/test_package_validation.sh
```

### What Package Validation Checks

1. **Syntax Validation**
   - Package name format correctness
   - Comment formatting and placement
   - Inline comment handling

2. **Platform Appropriateness**
   - macOS-specific packages only
   - No Linux packages in macOS configuration
   - Architecture-specific package validation

3. **Homebrew Availability**
   - Package existence in Homebrew repository
   - Special tap requirements (e.g., sketchybar)
   - Formula vs. cask availability

4. **Duplicate Detection**
   - No duplicate package entries
   - Conflict identification

5. **Documentation Quality**
   - Comment coverage for alternatives
   - Section header formatting
   - Special requirement documentation

### Package Validation Results

```
✅ PASSED: Package syntax validation for macos
✅ PASSED: Platform appropriateness validation for macos
✅ PASSED: Duplicate package validation for macos
✅ PASSED: Documentation quality validation for macos
✅ PASSED: Homebrew package existence validation
```

## 🔧 macOS-Specific Testing

The macOS integration tests validate features specific to macOS systems.

### Key macOS Test Areas

1. **Wave 1 Regression Testing**
   - `.zshenv` PATH configuration
   - Homebrew path prioritization
   - Claude Code PATH integration
   - Architecture detection

2. **macOS-Specific Features**
   - Airport command function with deprecation warnings
   - Finder integration aliases
   - Clipboard management
   - Apple Silicon optimizations

3. **Shell Configuration**
   - PATH ordering and prioritization
   - Terminal application integration
   - iTerm2 compatibility

4. **Architecture Compatibility**
   - Apple Silicon vs Intel Mac detection
   - Homebrew path configuration
   - Rosetta 2 compatibility

5. **Package Installation**
   - Homebrew integration testing
   - Package availability validation
   - Installation script testing

6. **Security and Permissions**
   - File permission validation
   - Sensitive information exposure checks

### Running macOS Tests

```bash
# Run all macOS-specific tests
./tests/test_macos_integration.sh

# Test specific areas
./tests/test_macos_integration.sh --help  # View available options
```

## 📊 Test Results and Reports

### Understanding Test Output

```
=== macOS-Specific Integration Test Results ===
Total Tests: 7
Passed: 7
Failed: 0
Skipped: 0

✅ ALL MACOS TESTS PASSED
macOS-specific features are working correctly.
```

### Report Locations

- **Integration Reports**: `test_results/integration_report_YYYYMMDD_HHMMSS.md`
- **Package Validation Reports**: `test_results/package_validation_report_YYYYMMDD_HHMMSS.md`
- **Quick Summary**: `test_results/latest_summary.txt`
- **Test Logs**: `test_results/*.log`

### Report Contents

Integration reports include:
- System health assessment
- Component interaction validation
- User experience flow testing
- Performance considerations
- Security assessment
- Production readiness evaluation

## 🛠️ Testing for Contributors

### Before Submitting Changes

1. **Run Full Test Suite**
   ```bash
   ./tests/run_all_tests.sh
   ```

2. **Validate Package Changes**
   ```bash
   # If you modified packages-macos.txt
   ./tests/test_package_validation.sh
   ```

3. **Test macOS-Specific Changes**
   ```bash
   # If you modified macOS configurations
   ./tests/test_macos_integration.sh
   ```

4. **Manual Verification**
   - Test installation on clean system
   - Verify shell startup
   - Test key aliases and functions

### Package Modification Guidelines

When adding or modifying packages:

1. **Package Name Format**
   ```
   package-name                    # Good
   package-name    # Comment       # Good
   package-name #inline-comment   # Good
   package-name-with-number3      # Verify if intentional
   ```

2. **Documentation Requirements**
   ```bash
   # macOS-specific alternative to Linux package
   package-name                    # Brief description

   # Special handling required
   special-package    # Requires: brew tap user/repo
   ```

3. **Architecture Considerations**
   - Ensure packages work on both Apple Silicon and Intel Macs
   - Document any architecture-specific requirements
   - Use Homebrew universal formulae when possible

### Configuration Modification Guidelines

When modifying shell configurations:

1. **PATH Management**
   - Use `.zshenv` for PATH settings that need to be available to all shells
   - Prioritize user paths over system paths
   - Use `brew shellenv` for Homebrew integration

2. **macOS-Specific Features**
   - Include deprecation warnings for deprecated macOS commands
   - Provide modern alternatives where applicable
   - Test on multiple macOS versions when possible

3. **Testing Requirements**
   - All new aliases/functions should be tested
   - Include error handling for edge cases
   - Document dependencies and requirements

## 🔍 Continuous Integration

### GitHub Actions Integration

The testing infrastructure is designed to work with CI/CD systems:

```yaml
# Example GitHub Actions workflow
- name: Run macOS Tests
  run: ./tests/run_all_tests.sh

- name: Validate Packages
  run: ./tests/test_package_validation.sh
```

### CI Test Categories

1. **Syntax Validation** - Fast, always run
2. **Package Validation** - Medium speed, Homebrew required
3. **Integration Tests** - Slower, full system testing
4. **macOS-Specific Tests** - Platform-dependent

### Exit Codes

- `0` - All tests passed
- `1` - Some tests failed (check logs for details)

## 🚨 Troubleshooting

### Common Issues

1. **Test Failures Due to Missing Homebrew**
   ```bash
   # Install Homebrew
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Permission Issues**
   ```bash
   # Ensure test scripts are executable
   chmod +x tests/test_*.sh
   ```

3. **Environment Issues**
   ```bash
   # Clean test environment
   rm -rf test_results/
   ```

4. **Package Validation Failures**
   - Check package names for typos
   - Verify Homebrew taps are available
   - Update Homebrew: `brew update`

### Debug Mode

For detailed debugging:

```bash
# Run with verbose output
bash -x ./tests/test_macos_integration.sh

# Preserve test environment for inspection
export KEEP_TEST_ENV=1
./tests/test_macos_integration.sh
```

### Log Analysis

```bash
# View latest test results
cat test_results/latest_summary.txt

# Analyze specific test failures
grep "FAILED:" test_results/*.log

# View detailed integration report
ls -la test_results/integration_report_*.md | tail -1
```

## 📈 Performance Testing

### Test Performance Metrics

- **Package Validation**: ~30 seconds
- **macOS Integration Tests**: ~15 seconds
- **Full Test Suite**: ~2-3 minutes

### Optimization Tips

1. **Run Specific Tests** - Don't always run the full suite
2. **Use Test Caching** - Some tests can reuse previous results
3. **Parallel Execution** - Independent tests can run in parallel

## 🔄 Maintenance

### Regular Maintenance Tasks

1. **Monthly**: Run quick validation tests
2. **Quarterly**: Full integration test suite
3. **Annually**: Complete system review and updates

### Test Updates

- Update test expectations when macOS versions change
- Add new macOS-specific features to test coverage
- Update package validation rules as Homebrew evolves

## 📞 Support

For testing-related issues:

1. Check the test logs in `test_results/`
2. Review this documentation
3. Run individual test suites to isolate issues
4. Check GitHub issues for known problems

---

**Note**: This testing infrastructure is designed to be comprehensive yet maintainable. Contributors should focus on testing the specific areas they modify rather than trying to understand the entire system at once.
# Contributing to Dotfiles

Thank you for your interest in contributing to this dotfiles project! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Documentation](#documentation)
- [Code Standards](#code-standards)
- [Submitting Changes](#submitting-changes)
- [Pull Request Process](#pull-request-process)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

- **Git**: Version control system
- **GitHub Account**: For submitting pull requests
- **SSH Key configured**: This is a private repository, requires SSH access
- **Shell Environment**: Zsh or Bash (recommended)
- **Text Editor**: Your preferred editor with shell script support

### Initial Setup

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/dotfiles.git
   cd dotfiles
   ```

2. **Add Upstream Remote**
   ```bash
   git remote add upstream git@github.com:BrennonTWilliams/dotfiles.git
   ```

3. **Set Up Development Environment**
   ```bash
   # Install development dependencies (if any)
   ./install.sh --development

   # Set up pre-commit hooks (if configured)
   ./scripts/setup-dev.sh
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### Branch Naming Convention

- `feature/feature-name` - New features
- `fix/issue-description` - Bug fixes
- `docs/documentation-update` - Documentation changes
- `refactor/code-cleanup` - Code refactoring
- `test/add-test-coverage` - Test improvements

### 2. Make Your Changes

#### Configuration Changes
- Follow existing file structure and naming conventions
- Add comments for complex configurations
- Test on multiple platforms if applicable

#### Script Changes
- Follow shell script best practices
- Include error handling
- Add usage documentation

#### Documentation Changes
- Follow existing markdown style
- Update table of contents if needed
- Test all code examples

### 3. Test Your Changes

```bash
# Run the test suite
./tests/test_all.sh

# Test specific functionality
./tests/test_macos_integration.sh
./tests/test_installation.sh

# Manual testing
./install.sh --dry-run
```

## Testing

### Test Coverage Requirements

- **New Features**: Must include tests
- **Bug Fixes**: Must include regression tests
- **Documentation**: Verify all examples work
- **Configuration Changes**: Test on target platforms

### Running Tests

```bash
# Run all tests
./tests/test_all.sh

# Run specific test categories
./tests/test_installation.sh
./tests/test_configuration.sh
./tests/test_platform_compatibility.sh

# Run with debug output
DEBUG=1 ./tests/test_all.sh

# Run tests and keep environment for debugging
KEEP_TEST_ENV=1 ./tests/test_all.sh
```

### Test Standards

- All tests must pass on supported platforms
- New configurations must be testable
- Include edge case testing
- Document test scenarios clearly

## Documentation

### Documentation Standards

- **README.md**: Project overview and quick start
- **CHANGELOG.md**: Version history and changes
- **Feature Documentation**: In appropriate section files
- **Code Comments**: For complex configurations
- **Commit Messages**: Clear and descriptive

### Writing Documentation

```markdown
# Section Header (Level 1)

## Subsection (Level 2)

### Details (Level 3)

- Use bullet points for lists
- `Inline code` for commands and file names
- ```bash for code blocks
- Include examples and use cases
```

### Updating Documentation

1. Update relevant sections when adding features
2. Add new documentation for major changes
3. Update CHANGELOG.md for user-facing changes
4. Verify all links and references work

## Code Standards

### Shell Script Standards

```bash
#!/bin/bash
# Use bash for scripts
set -euo pipefail  # Strict error handling

# Function naming: snake_case
function install_package() {
    local package="$1"
    # Function implementation
}

# Variable naming: snake_case
local install_directory="$HOME/.dotfiles"

# Error handling
if [[ ! -d "$install_directory" ]]; then
    echo "Error: Directory not found: $install_directory" >&2
    exit 1
fi
```

### Configuration File Standards

- **Comments**: Explain complex configurations
- **Organization**: Logical grouping of related settings
- **Platform Detection**: Use conditional logic for platform-specific settings
- **Overrides**: Support local customization files

### Git Commit Standards

```
type(scope): brief description

Detailed explanation (optional)

- Bullet points for changes
- Reference issue numbers: #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Examples:**
```
feat(macos): add Apple Silicon optimization
fix(installation): resolve package detection issue
docs(readme): update installation instructions
```

## Submitting Changes

### Before Submitting

1. **Test Thoroughly**
   ```bash
   ./tests/test_all.sh
   ```

2. **Check Documentation**
   - README.md is up to date
   - CHANGELOG.md includes changes
   - All examples tested

3. **Verify Code Quality**
   - No syntax errors
   - Follow naming conventions
   - Include error handling

4. **Clean Git History**
   ```bash
   # Rebase and squash commits if needed
   git rebase -i HEAD~n
   ```

### Pull Request Checklist

- [ ] Tests pass on all supported platforms
- [ ] Documentation is updated
- [ ] Code follows project standards
- [ ] CHANGELOG.md includes changes
- [ ] Commit messages are clear
- [ ] No merge conflicts
- [ ] Ready for review

## Pull Request Process

### 1. Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
# Use descriptive title and fill out template
```

### 2. PR Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass on macOS
- [ ] Tests pass on Linux
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
```

### 3. Review Process

- **Automated Checks**: CI/CD pipeline runs tests
- **Peer Review**: At least one maintainer review
- **Testing Review**: Verify test coverage
- **Documentation Review**: Ensure documentation quality

### 4. Merge Process

- Maintainers review and approve PRs
- Squash and merge for clean history
- Update version numbers if needed
- Create release tags for major changes

## Community Guidelines

### Code of Conduct

- **Respectful Communication**: Be kind and professional
- **Constructive Feedback**: Provide helpful, specific feedback
- **Inclusive Environment**: Welcome contributors of all experience levels
- **Focus on Improvement**: Help improve the project for everyone

### Getting Help

1. **Check Documentation**: README, TROUBLESHOOTING.md
2. **Search Issues**: Look for existing solutions
3. **Create Issue**: Provide detailed information
4. **Join Discussions**: Engage in project discussions

### Reporting Issues

When reporting bugs or requesting features:

1. **Use Issue Templates**: Follow provided templates
2. **Provide Environment Info**: OS, shell version, etc.
3. **Include Reproduction Steps**: Clear steps to reproduce issues
4. **Add Context**: Explain your use case and goals

## Development Tips

### Platform Testing

```bash
# Test on multiple platforms
./tests/test_platform_compatibility.sh

# Check platform-specific behavior
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific code
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific code
fi
```

### Debugging

```bash
# Enable debug mode
set -x  # Enable debug tracing
./install.sh --debug

# Test specific components
./tests/test_component.sh --verbose

# Keep test environment for debugging
KEEP_TEST_ENV=1 ./tests/test_all.sh
```

### Performance Considerations

- Use lazy loading for heavy initialization
- Optimize PATH management
- Minimize startup time for shell configurations
- Consider resource usage for background services

## Recognition

### Contributors

All contributors are recognized in:
- README.md contributors section
- GitHub contributor statistics
- CHANGELOG.md for significant contributions

### Types of Contributions

- **Code**: Features, bug fixes, optimizations
- **Documentation**: Guides, examples, improvements
- **Testing**: Test cases, bug reports
- **Community**: Support, discussions, feedback

## Questions?

- **Issues**: [GitHub Issues](https://github.com/BrennonTWilliams/dotfiles/issues)
- **Discussions**: [GitHub Discussions](https://github.com/BrennonTWilliams/dotfiles/discussions)
- **Documentation**: Check existing docs first

---

Thank you for contributing to this project! Your contributions help make these dotfiles better for everyone.
# Contributing to PowerShell Applications

First off, thank you for considering contributing to PowerShell Applications! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project and everyone participating in it is governed by basic principles of respect and professionalism. Be kind, be respectful, and be collaborative.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

- Use a clear and descriptive title
- Describe the exact steps to reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed and what you expected
- Include screenshots if applicable
- Note your environment (OS, PowerShell version, etc.)

### 💡 Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the suggested enhancement
- Explain why this enhancement would be useful
- List any examples of how it would be used

### 📝 Code Contributions

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (see [Commit Guidelines](#commit-guidelines))
6. Push to your branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

## Development Setup

### Prerequisites

- **PowerShell 5.1** or higher (PowerShell 7+ recommended)
- **Git** for version control
- **Pester** for testing (PSScripts): `Install-Module -Name Pester -Force`
- **PSScriptAnalyzer** for linting: `Install-Module -Name PSScriptAnalyzer -Force`

### Getting Started

```powershell
# Clone your fork
git clone https://github.com/YOUR-USERNAME/Powershell-Applications.git
cd Powershell-Applications

# Add upstream remote
git remote add upstream https://github.com/bridley5189/Powershell-Applications.git

# Create a feature branch
git checkout -b feature/my-new-feature
```

## Coding Standards

### PowerShell Style Guide

1. **Naming Conventions**
   - Use PascalCase for function names: `Get-MyFunction`
   - Use PascalCase for parameter names: `$MyParameter`
   - Use descriptive names, avoid abbreviations

2. **Comments**
   - Add comment-based help for all functions
   - Use `#` for inline comments
   - Explain complex logic

3. **Formatting**
   - Indent with 4 spaces (no tabs)
   - Use K&R brace style (opening brace on same line)
   - Keep lines under 120 characters when possible

4. **Error Handling**
   - Use try/catch blocks for error-prone operations
   - Provide meaningful error messages
   - Use appropriate exit codes (0 = success, 1+ = error)

### Example Function

```powershell
<#
.SYNOPSIS
Brief description of function.

.DESCRIPTION
Detailed description of what the function does.

.PARAMETER Name
Description of parameter.

.EXAMPLE
Get-MyFunction -Name "Example"
Description of what this example does.
#>
function Get-MyFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    try {
        # Implementation here
        Write-Output "Processing $Name"
    }
    catch {
        Write-Error "Failed to process: $_"
        exit 1
    }
}
```

## Commit Guidelines

Use conventional commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(log-reader): add filter by timestamp
fix(ps-demo): resolve execution permission issue
docs(readme): update installation instructions
test(psscripts): add tests for Windows Update detection
```

## Pull Request Process

1. **Update Documentation**: Ensure README files are updated if needed
2. **Add Tests**: For PSScripts, add Pester tests for new functionality
3. **Run PSScriptAnalyzer**: Ensure your code passes linting
4. **Update CHANGELOG**: Document your changes (if applicable)
5. **Request Review**: Tag maintainers for review

### PR Checklist

- [ ] Code follows the style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated (for PSScripts)
- [ ] All tests pass
- [ ] No merge conflicts

## Testing

### PSScripts

```powershell
# Run all tests
cd PSScripts
Invoke-Pester ./tests/

# Run with coverage
Invoke-Pester ./tests/ -CodeCoverage ./scripts/**/*.ps1
```

### Manual Testing

Before submitting:

1. Test on a clean environment
2. Verify all features work as expected
3. Check for error handling
4. Test with different PowerShell versions if possible

## Questions?

Feel free to open an issue for questions or join discussions in existing issues.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🚀

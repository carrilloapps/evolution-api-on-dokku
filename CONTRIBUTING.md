# Contributing to Evolution API on Dokku

First off, thank you for considering contributing to Evolution API on Dokku! It's people like you that make this project better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if applicable**
- **Include your environment details** (OS, Dokku version, Evolution API version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the proposed enhancement**
- **Explain why this enhancement would be useful**
- **List any alternative solutions you've considered**

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

#### Pull Request Guidelines

- Fill in the required template
- Include screenshots/GIFs if applicable
- Update documentation if needed
- Ensure all tests pass
- Follow the code style guidelines
- Link any relevant issues

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/carrilloapps/evolution-api-on-dokku.git
   cd evolution-api-on-dokku
   ```

2. Set up your Dokku server following the [README](README.md)

3. Test your changes locally before pushing

## Style Guidelines

### Dockerfile

- Use official base images
- Keep layers minimal
- Comment complex operations
- Use multi-stage builds when appropriate

### Documentation

- Use clear, concise language
- Include code examples
- Keep formatting consistent
- Test all commands before documenting

### Configuration Files

- Use clear, descriptive keys
- Add comments for complex configurations
- Maintain alphabetical order when possible

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Performance improvements
- **test**: Adding or correcting tests
- **chore**: Changes to build process or auxiliary tools

### Examples

```
feat(dockerfile): update Evolution API to v2.3.7

- Update base image to atendai/evolution-api:v2.3.7
- Add new environment variables for latest features
- Update health check configuration
```

```
fix(readme): correct PostgreSQL backup command for Windows

- Add PowerShell-specific date formatting
- Update command syntax for cross-platform compatibility
```

```
docs(contributing): add commit message guidelines

Add section explaining conventional commits format
and provide examples for common scenarios.
```

## Questions?

Feel free to open an issue with the `question` label if you need help or clarification.

Thank you for contributing! 🎉

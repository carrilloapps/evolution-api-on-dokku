# AGENTS.md

This file provides guidance for AI assistants working with this project.

## Project Overview

**Project Name**: Evolution API on Dokku  
**Type**: Deployment Configuration  
**Primary Technology**: Docker, Dokku, Node.js, TypeScript  
**Purpose**: Deploy and manage Evolution API (WhatsApp REST API) on Dokku PaaS

## Project Structure

```
evolution-api-on-dokku/
├── README.md                    # Main documentation (simplified, overview only)
├── Dockerfile                   # Docker container configuration
├── app.json                     # Dokku app configuration
├── LICENSE                      # MIT License (PRIVATE by default)
├── CODE_OF_CONDUCT.md          # Community guidelines
├── CONTRIBUTING.md             # Contribution guidelines
├── AGENTS.md                   # This file - AI assistant guidance
├── .github/                    # GitHub specific files (templates, workflows)
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── BRANCH_PROTECTION.md    # Branch protection guide
│   ├── CODEOWNERS              # Code ownership
│   ├── FUNDING.yml             # Sponsorship configuration
│   ├── SECURITY.md             # Security policy
│   ├── dependabot.yml          # Dependency updates
│   └── workflows/              # CI/CD workflows
│       ├── link-check.yml      # Markdown link validation (ONLY workflow)
│       └── markdown-link-check-config.json
└── docs/                       # Complete documentation
    ├── AGENTS.md               # Documentation directory guidance
    ├── installation.md         # Detailed installation guide
    ├── system-requirements.md  # Hardware/software requirements
    ├── configuration.md        # Environment variables and settings
    ├── useful-commands.md      # Command reference
    ├── performance.md          # Performance optimization
    └── changelog.md            # Version history
```

## What This Project Does

This project provides:

1. **Deployment Configuration**: Ready-to-use Dokku deployment for Evolution API
2. **Documentation**: Comprehensive guides for installation, configuration, and optimization
3. **Best Practices**: Optimized settings for different team sizes and use cases
4. **Cross-Platform Support**: Instructions for Linux, macOS, and Windows

## Technology Stack

### Core Technologies

- **Evolution API**: WhatsApp REST API (v2.3.7)
- **Dokku**: Docker-powered PaaS
- **PostgreSQL**: Primary database (v18.1)
- **Redis**: Optional caching layer (for 50+ users)
- **Docker**: Container runtime
- **Nginx**: Reverse proxy (managed by Dokku)
- **Let's Encrypt**: SSL/TLS certificates

### Languages

- **Documentation**: Markdown
- **Configuration**: JSON, Dockerfile, Shell scripts
- **Evolution API**: TypeScript/Node.js (upstream project)

## Development Guidelines

### Documentation Standards

1. **Main README.md**:
   - Keep concise and focused on quick start
   - Maximum 200 lines
   - Link to detailed documentation in `/docs`
   - Include table of contents
   - Show minimal installation example

2. **Documentation in `/docs`**:
   - Detailed, comprehensive guides
   - Use clear headings and table of contents
   - Provide examples for all platforms (Linux, macOS, Windows)
   - Include troubleshooting sections
   - Add "Next Steps" links at the end

3. **Code Examples**:
   - Provide both Linux/macOS and Windows versions
   - Use comments to explain complex commands
   - Include expected output when relevant
   - Always include error handling

### File Naming Conventions

- Documentation files: `kebab-case.md`
- Configuration files: Follow respective conventions (e.g., `Dockerfile`, `app.json`)
- Scripts: `kebab-case.sh` or `kebab-case.ps1`

### Writing Style

- **Natural language**: Spanish (es_CO) for instructions to human users
- **Code, variables, files**: English (en_US)
- **Comments in code**: English (en_US)
- **Be concise**: Direct and clear explanations
- **Be practical**: Always provide working examples
- **Be inclusive**: Support all platforms (Linux, macOS, Windows)

## Common Tasks

### Adding New Documentation

1. Create file in `/docs` with descriptive kebab-case name
2. Add comprehensive table of contents
3. Include examples for all platforms
4. Link from main README.md if relevant
5. Add cross-references to related documentation
6. Update `/docs/AGENTS.md` if needed

### Updating Installation Instructions

1. Update `/docs/installation.md` with detailed steps
2. Update quick start in main README.md (keep minimal)
3. Test on multiple platforms
4. Document any breaking changes in `/docs/changelog.md`

### Adding Configuration Options

1. Document in `/docs/configuration.md`
2. Provide examples and default values
3. Explain performance implications
4. Add to quick reference if commonly used

### Performance Optimizations

1. Document in `/docs/performance.md`
2. Provide before/after metrics when possible
3. Explain trade-offs
4. Include monitoring scripts

## Key Principles

### Design Principles

1. **Simplicity First**: Default configuration should work for 1-10 users with minimal resources
2. **Scalability**: Easy to scale up as team grows
3. **Cross-Platform**: All instructions work on Linux, macOS, and Windows
4. **Documentation**: Comprehensive, clear, and always up-to-date
5. **Best Practices**: Follow Dokku, Docker, and PostgreSQL best practices

### Configuration Principles

1. **Minimal by Default**: 256MB RAM, 0.5 CPU for cost optimization
2. **Easy Scaling**: Clear guidelines for different team sizes
3. **Optional Features**: Redis, webhooks, etc. are optional and documented
4. **Security First**: HTTPS by default, strong authentication

### Documentation Principles

1. **Main README**: Quick start only, link to detailed docs
2. **Detailed Docs**: In `/docs`, comprehensive and searchable
3. **Examples**: Working code for all platforms
4. **Troubleshooting**: Common issues and solutions
5. **Next Steps**: Always link to related documentation

## CI/CD and Quality Assurance

### GitHub Actions Workflows

This project uses a **minimalist CI/CD approach** focused on what matters:

**Active Workflow:**
- **link-check.yml**: Validates all markdown links in documentation
  - Runs on: push, pull_request, schedule (weekly), workflow_dispatch
  - Configuration: `.github/workflows/markdown-link-check-config.json`
  - Purpose: Ensures all documentation links are working and not broken
  - Tested with: `act -j link-check` (✅ passes)

**Removed Workflows:**
- ~~markdown-lint.yml~~ (Removed: Too strict, 280+ formatting errors, not critical for documentation)
- ~~.markdownlint.json~~ (Removed: Configuration no longer needed)

### Why Only Link Check?

For a documentation project like this:
1. **Link validation is critical** - Broken links frustrate users
2. **Markdown formatting is subjective** - Strict linting creates unnecessary friction
3. **Maintainability matters** - Simple CI/CD is easier to maintain
4. **Focus on content** - Documentation should prioritize clarity over formatting rules

### Testing Workflows Locally

Use [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# List available workflows
act --list

# Run link check workflow
act -j link-check
```

**Windows (PowerShell):**
```powershell
# Install act via Chocolatey
choco install act-cli

# Test link check
act -j link-check
```

### Branch Protection

Refer to [.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md) for recommended settings.

**Required status check:**
- `Markdown Link Check` - Must pass before merging to master/develop

## Environment and Deployment

### Supported Platforms

- **Server**: Linux (Ubuntu, Debian, CentOS)
- **Client**: Linux, macOS, Windows (PowerShell, Git Bash)
- **Dokku**: Version 0.30.0+
- **PostgreSQL**: Version 18.1
- **Redis**: Optional, latest version

### System Requirements

See [docs/system-requirements.md](docs/system-requirements.md) for detailed requirements.

**Quick Reference**:
- Minimal: 256MB RAM, 0.3 CPU, 2GB storage
- Small: 512MB RAM, 1 CPU, 5GB storage
- Medium: 1GB RAM, 2 CPU, 10GB storage
- Large: 2GB+ RAM, 4+ CPU, 20GB+ storage

## Testing and Validation

### Before Committing Changes

1. **Test Documentation**:
   - Verify all links work (run `act -j link-check`)
   - Check markdown formatting (visual review, no automated linting)
   - Test code examples on target platform
   - Verify cross-references

2. **Test GitHub Actions Workflows**:
   - Run `act -j link-check` to test locally
   - Ensure all documentation links are valid
   - Fix any broken links before committing

3. **Test Configuration**:
   - Test in minimal environment (256MB RAM)
   - Test scaling to larger environments
   - Verify all environment variables work
   - Check database migrations

3. **Validate Commands**:
   - Test on Linux/macOS
   - Test on Windows (PowerShell)
   - Verify error handling
   - Check expected output

## Troubleshooting Guide

### Common Issues

1. **Documentation is too long**:
   - Move detailed content to `/docs`
   - Keep main README.md concise
   - Link to detailed documentation

2. **Platform-specific issues**:
   - Always provide examples for all platforms
   - Test on Linux, macOS, and Windows
   - Document platform-specific quirks

3. **Configuration confusion**:
   - Use clear variable names
   - Provide default values
   - Explain implications of changes

## Working with AI Assistants

### What to Do

- ✅ Always check existing documentation before creating new files
- ✅ Keep main README.md concise (< 200 lines)
- ✅ Provide examples for all platforms
- ✅ Update AGENTS.md when structure changes
- ✅ Test all code examples
- ✅ Link related documentation
- ✅ Use consistent formatting

### What Not to Do

- ❌ Don't duplicate content between README.md and `/docs`
- ❌ Don't create files that already exist
- ❌ Don't provide only Linux examples (include Windows/macOS)
- ❌ Don't forget to update changelog when making changes
- ❌ Don't create overly complex configurations
- ❌ Don't ignore cross-platform compatibility

## Resources

### External Documentation

- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Dokku Documentation](https://dokku.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

### Internal Documentation

- [Installation Guide](docs/installation.md)
- [System Requirements](docs/system-requirements.md)
- [Configuration](docs/configuration.md)
- [Useful Commands](docs/useful-commands.md)
- [Performance & Optimization](docs/performance.md)
- [Changelog](docs/changelog.md)

## Questions?

If you're an AI assistant and need clarification:

1. Check existing documentation in `/docs`
2. Review this AGENTS.md file
3. Look at similar projects for patterns
4. Follow the guidelines in the main instructions file
5. When in doubt, ask for clarification rather than guessing

## Version Information

- **Last Updated**: 2026-01-01
- **Evolution API Version**: 2.3.7
- **Dokku Compatibility**: 0.30.0+
- **PostgreSQL Version**: 18.1

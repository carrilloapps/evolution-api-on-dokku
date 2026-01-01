# AGENTS.md - Documentation Directory

This file provides guidance for AI assistants working with the documentation in this directory.

## Purpose

This `/docs` directory contains **comprehensive, detailed documentation** for deploying and managing Evolution API on Dokku. Unlike the main README.md (which is concise and focused on quick start), these documents provide in-depth guides, references, and best practices.

## Directory Structure

```
docs/
├── AGENTS.md                   # This file - Documentation guidance
├── installation.md             # Complete installation guide
├── system-requirements.md      # Hardware and software requirements
├── configuration.md            # Environment variables and settings
├── useful-commands.md          # Command reference
├── performance.md              # Performance optimization
└── changelog.md                # Version history
```

## Documentation Files

### installation.md

**Purpose**: Comprehensive step-by-step installation guide  
**Audience**: Users deploying Evolution API for the first time  
**Content**:
- Prerequisites and requirements
- Step-by-step installation process
- PostgreSQL setup and configuration
- Storage configuration
- Domain and SSL setup
- Deployment methods
- Post-installation verification
- Troubleshooting

**Guidelines**:
- Provide complete commands with explanations
- Include examples for Linux, macOS, and Windows
- Show expected output
- Include troubleshooting for common issues
- Link to related documentation

### system-requirements.md

**Purpose**: Hardware and software requirements for different deployment sizes  
**Audience**: Users planning their infrastructure  
**Content**:
- Software requirements (Dokku, PostgreSQL, etc.)
- Hardware requirements by team size
- Network requirements
- Cost estimates by cloud provider
- Storage considerations
- Resource adjustment commands

**Guidelines**:
- Use tables for clear comparison
- Provide cost estimates (approximate)
- Include scaling recommendations
- Link to cloud provider documentation
- Explain trade-offs

### configuration.md

**Purpose**: Detailed configuration options and environment variables  
**Audience**: Users customizing their deployment  
**Content**:
- Required environment variables
- Optional configuration options
- Database configuration
- Authentication setup
- Storage configuration
- Domain and port configuration
- Advanced configuration
- Best practices

**Guidelines**:
- Document all environment variables
- Provide default values
- Explain performance implications
- Include security considerations
- Show configuration examples
- Link to official documentation

### useful-commands.md

**Purpose**: Reference guide for common management tasks  
**Audience**: Users managing their deployment  
**Content**:
- Application management commands
- Logging and monitoring
- Database management
- Storage management
- Resource management
- Updates and deployment
- Troubleshooting commands

**Guidelines**:
- Organize by category
- Provide complete, tested commands
- Include both Linux/macOS and Windows versions
- Show expected output when relevant
- Include quick reference section
- Add emergency commands

### performance.md

**Purpose**: Performance optimization and scaling strategies  
**Audience**: Users optimizing their deployment  
**Content**:
- Performance overview by team size
- Resource optimization
- Database optimization
- Redis caching setup
- Storage optimization
- Network optimization
- Monitoring and alerting
- Scaling strategies
- Benchmarking

**Guidelines**:
- Provide measurable metrics
- Include before/after comparisons
- Explain trade-offs
- Provide automation scripts
- Include monitoring setup
- Document scaling strategies
- Show benchmark commands

### changelog.md

**Purpose**: Version history and update information  
**Audience**: All users  
**Content**:
- Current Evolution API version
- Feature list
- Bug fixes
- Breaking changes
- Migration notes
- Deployment updates
- Roadmap

**Guidelines**:
- Use semantic versioning
- Clearly mark breaking changes
- Provide migration instructions
- Link to official releases
- Document deployment configuration changes
- Keep chronological order

## Documentation Standards

### Structure

All documentation files should follow this structure:

```markdown
# Title

Brief description of what this document covers.

## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)
- [Section 3](#section-3)

## Section 1

Content...

## Section 2

Content...

## Next Steps

- [Related Doc 1](doc1.md)
- [Related Doc 2](doc2.md)

## References

- [External Link 1](url)
- [External Link 2](url)
```

### Writing Style

1. **Be comprehensive**: Cover all aspects in detail
2. **Be practical**: Always provide working examples
3. **Be clear**: Use simple language, avoid jargon
4. **Be organized**: Use clear headings and structure
5. **Be inclusive**: Provide examples for all platforms

### Code Examples

**Always provide platform-specific examples:**

```markdown
**Linux/macOS:**
```bash
dokku command evo
```

**Windows (PowerShell):**
```powershell
ssh your-server "command evo"
```
```

### Cross-References

Always link to related documentation:

```markdown
## Next Steps

- [Installation Guide](installation.md) - If they need installation help
- [Configuration](configuration.md) - For detailed configuration options
- [Performance](performance.md) - For optimization tips
```

## Content Guidelines

### What Belongs Here

✅ Detailed, comprehensive guides  
✅ Complete command references  
✅ Troubleshooting procedures  
✅ Performance optimization strategies  
✅ Configuration options and explanations  
✅ Best practices and recommendations  
✅ Examples for all platforms

### What Doesn't Belong Here

❌ Quick start guides (belongs in main README.md)  
❌ Project overview (belongs in main README.md)  
❌ Contribution guidelines (belongs in CONTRIBUTING.md)  
❌ License information (belongs in LICENSE)  
❌ Code of conduct (belongs in CODE_OF_CONDUCT.md)

## Working with Documentation

### Adding New Documentation

1. **Determine necessity**: Is this content too detailed for README.md?
2. **Choose appropriate file**: Add to existing file or create new one?
3. **Follow structure**: Use standard headings and table of contents
4. **Provide examples**: Include code examples for all platforms
5. **Add cross-references**: Link to related documentation
6. **Update main README**: Add link if relevant
7. **Update this file**: Document new file if created

### Updating Existing Documentation

1. **Review current content**: Understand existing structure
2. **Maintain consistency**: Follow existing style and format
3. **Update cross-references**: Ensure all links still work
4. **Test examples**: Verify all code examples work
5. **Update changelog**: Document significant changes

### Reviewing Documentation

Before committing changes, verify:

1. ✅ Table of contents is accurate
2. ✅ All internal links work
3. ✅ All external links work
4. ✅ Code examples are tested
5. ✅ Platform-specific examples provided
6. ✅ Cross-references are current
7. ✅ Markdown formatting is correct
8. ✅ Spelling and grammar checked

## Platform-Specific Guidance

### Linux/macOS Examples

```bash
# Direct Dokku commands
dokku command evo

# Shell variables
API_KEY=$(openssl rand -hex 16)

# Date formatting
backup-$(date +%Y%m%d)
```

### Windows PowerShell Examples

```powershell
# Remote Dokku commands via SSH
ssh your-server "command evo"

# PowerShell variables
$API_KEY = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

# Date formatting
$date = Get-Date -Format "yyyyMMdd"
```

### Cross-Platform Examples

When a command works the same on all platforms:

```bash
# This works on Linux, macOS, and Windows (Git Bash)
git clone repository.git
cd repository
git push origin master
```

## Maintenance

### Regular Updates

Documentation should be updated when:

- Evolution API version changes
- Dokku version requirements change
- New features are added
- Configuration options change
- Best practices evolve
- Common issues are discovered

### Quality Checks

Perform these checks quarterly:

1. **Link validation**: Check all internal and external links
2. **Version verification**: Ensure version numbers are current
3. **Example testing**: Test all code examples
4. **Screenshot updates**: Update any screenshots if UI changed
5. **Cross-reference check**: Verify all links between docs work

## Common Patterns

### Command Documentation

```markdown
### Command Name

Description of what the command does.

**Linux/macOS:**
```bash
dokku command evo options
```

**Windows (PowerShell):**
```powershell
ssh your-server "command evo options"
```

**Expected output:**
```
Example output here
```
```

### Configuration Documentation

```markdown
### Variable Name

| Property | Value |
|----------|-------|
| **Variable** | `VARIABLE_NAME` |
| **Type** | String/Boolean/Number |
| **Default** | `default_value` |
| **Required** | Yes/No |

**Description**: What this variable does.

**Example:**
```bash
dokku config:set evo VARIABLE_NAME="value"
```

**Impact**: Performance/Security/Storage implications.
```

### Troubleshooting Documentation

```markdown
### Issue Name

**Symptoms:**
- Symptom 1
- Symptom 2

**Diagnosis:**
```bash
# Commands to diagnose issue
dokku command evo
```

**Solution:**
```bash
# Commands to fix issue
dokku fix evo
```

**Verification:**
```bash
# Commands to verify fix
dokku verify evo
```
```

## AI Assistant Guidelines

### When Working with Documentation

1. **Always check existing files first**: Don't duplicate content
2. **Maintain consistency**: Follow existing patterns
3. **Test all examples**: Ensure commands work as documented
4. **Update cross-references**: Keep links current
5. **Provide complete examples**: Include all platforms
6. **Consider the audience**: Write for users, not developers
7. **Keep it practical**: Focus on real-world usage

### What to Do

✅ Add detailed explanations to existing files  
✅ Create comprehensive examples  
✅ Link related documentation  
✅ Update changelog when making significant changes  
✅ Provide troubleshooting guidance  
✅ Include performance implications  
✅ Test all commands before documenting

### What Not to Do

❌ Don't move content from here to main README.md  
❌ Don't create new files without good reason  
❌ Don't provide only Linux examples  
❌ Don't leave broken links  
❌ Don't skip table of contents  
❌ Don't forget to update this file if structure changes  
❌ Don't ignore platform-specific considerations

## Questions?

If you're an AI assistant working with documentation and need clarification:

1. Check this AGENTS.md file
2. Review existing documentation for patterns
3. Check the main AGENTS.md in root directory
4. Follow the general instructions guidelines
5. When in doubt, maintain consistency with existing docs

## Version Information

- **Last Updated**: 2026-01-01
- **Documentation Version**: 1.0
- **Evolution API Version**: 2.3.7

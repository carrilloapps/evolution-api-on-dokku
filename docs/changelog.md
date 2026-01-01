# Changelog

This document tracks the changes and updates to the Evolution API deployment on Dokku.

## Evolution API Version

Current deployment uses **Evolution API v2.3.7**

## Version 2.3.7 - Current

### Features

#### WhatsApp Business Meta Templates
- ✅ Create, update and delete WhatsApp Business templates
- ✅ Full template management API
- ✅ Support for interactive templates

#### Enhanced Webhook Events
- ✅ Track message sync progress with `isLatest` flag
- ✅ Progress percentage in webhook events
- ✅ Better event filtering and routing

#### N8N Integration
- ✅ Support for quoted messages in chatbot integration
- ✅ Improved message context handling
- ✅ Enhanced workflow automation support

#### WebSocket Improvements
- ✅ Wildcard host support for flexible connections
- ✅ Better connection management
- ✅ Improved real-time event delivery

#### Pix Payment Support
- ✅ Handle interactive Pix button messages
- ✅ Payment confirmation tracking
- ✅ Brazilian payment integration support

### Bug Fixes

#### Baileys Library
- 🐛 Fixed authentication issues
- 🐛 Resolved reconnection problems
- 🐛 Improved session stability

#### Chatwoot Integration
- 🐛 Improved contact management
- 🐛 Better message handling
- 🐛 Enhanced synchronization

#### Proxy Support
- 🐛 Fixed compatibility with Node.js 18+
- 🐛 Resolved Undici proxy issues
- 🐛 Better proxy configuration handling

#### Database Optimizations
- 🐛 Better contact deduplication
- 🐛 Improved chat deduplication
- 🐛 Optimized database queries

### Breaking Changes

None in this version.

### Migration Notes

No special migration steps required for upgrading to v2.3.7.

### Links

- [Evolution API Releases](https://github.com/EvolutionAPI/evolution-api/releases)
- [Official Documentation](https://doc.evolution-api.com/)

---

## Deployment Updates

### 2026-01-01

#### Documentation Reorganization
- 📚 Moved all documentation to `/docs` directory
- 📚 Created comprehensive guides:
  - [Installation Guide](installation.md)
  - [System Requirements](system-requirements.md)
  - [Configuration](configuration.md)
  - [Useful Commands](useful-commands.md)
  - [Performance & Optimization](performance.md)
- 📚 Simplified main README.md with quick start
- 📚 Added AGENTS.md files for AI assistant guidance

#### Project Structure
- ✅ Improved organization with clear documentation hierarchy
- ✅ Added comprehensive examples for all platforms (Linux, macOS, Windows)
- ✅ Created troubleshooting guides
- ✅ Added performance benchmarking guidelines

---

## Previous Versions

### Version 2.3.x - Previous Releases

For information about previous releases, visit the [Evolution API Releases](https://github.com/EvolutionAPI/evolution-api/releases) page.

---

## Roadmap

### Planned Features

The following features are planned for future releases:

- 🔄 **Multi-instance management UI** - Web interface for managing multiple WhatsApp instances
- 🔄 **Advanced analytics** - Usage statistics and reporting
- 🔄 **Auto-scaling** - Automatic resource adjustment based on load
- 🔄 **Backup automation** - Scheduled backups with cloud storage integration
- 🔄 **Monitoring dashboard** - Real-time performance monitoring

### Upcoming Evolution API Features

Follow the [Evolution API GitHub](https://github.com/EvolutionAPI/evolution-api) for upcoming features.

---

## Support

For issues, questions, or feature requests:

- **Evolution API Issues**: [GitHub Issues](https://github.com/EvolutionAPI/evolution-api/issues)
- **Dokku Documentation**: [Dokku Docs](https://dokku.com/docs/)
- **Community Support**: [Evolution API Discord](https://evolution-api.com/discord)

---

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](../CONTRIBUTING.md) for details.

---

## License

This deployment configuration is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

Evolution API is licensed under its own license. See the [Evolution API Repository](https://github.com/EvolutionAPI/evolution-api) for details.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.3] - 2025-05-20

### Fixed
- Fixed PostgreSQL healthcheck command to specify database name
- Improved RabbitMQ healthcheck with better start delay and retry parameters
- Updated service dependencies to ensure proper initialization order

### Changed
- Updated Evolution API image to latest version
- Improved documentation and translated to English
- Enhanced security recommendations

## [2.2.2] - 2025-04-15

### Added
- Added webhook support for real-time notifications
- Implemented connection pooling for improved database performance

### Fixed
- Resolved issues with WebSocket connections hanging after prolonged use
- Fixed memory leak in Redis connection handling

## [2.2.1] - 2025-03-10

### Changed
- Updated Redis to latest version
- Improved performance of message queue processing
- Enhanced error handling and logging

### Security
- Updated dependencies to address security vulnerabilities
- Implemented improved API key validation

## [2.2.0] - 2025-02-01

### Added
- Integration with RabbitMQ for message queueing
- Support for message events through RabbitMQ
- Enhanced monitoring capabilities

### Changed
- Migrated to PostgreSQL 16 for improved performance
- Updated container orchestration for better reliability

## [2.1.0] - 2025-01-05

### Added
- Redis integration for caching and improved performance
- Multi-device support for WhatsApp connections
- Extended API for group management

### Fixed
- Resolved connection stability issues
- Fixed media handling for large files

## [2.0.0] - 2024-12-10

### Added
- Complete rewrite of the core API
- PostgreSQL database support
- Docker-based deployment
- Improved error handling and reporting

### Changed
- New architecture for better scalability
- Enhanced security features
- Comprehensive documentation

## [1.0.0] - 2024-11-01

### Added
- Initial release
- Basic WhatsApp API functionality
- Support for text messages, media, and group chats
- Basic authentication system

# Change Log
All notable changes to this project will be documented in this file. This change log follows the conventions of [keepachangelog.com](http://keepachangelog.com/).

## [Unreleased]

## [0.0.4] - 2016-07-24
### Added
- Added CHANGELOG.md

### Updated
- Parameterize `timeout` for mqtt TCP connection, so it's not hardcoded

## [0.0.3] - 2016-06-16
### Added
- Add Docker support for development environment.

### Changed
- Parameterize server connetion details for testing.
- Upgrade Elixir to 1.2.5

### Fixed
- Fixes all the Elixir warning in the new version.

## [0.2.0] - 2015-08-30
### Added
- Beginnings of MQTT spec tests

### Fixed
- Add possibility to make Publish packets without id
- Decode/Encode Publish packets without id when qos 0
- Assert Publish packets work on connection if qos 0
- Allow publish call on client without id when qos 0
- Send back PubAck on receiving Publish packets qos 1

## [0.0.1] - 2015-04-19
### Added
- First version of the project made public

[Unreleased]: https://github.com/suvash/hulaaki/compare/v0.0.4...HEAD
[0.0.4]: https://github.com/suvash/hulaaki/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/suvash/hulaaki/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/suvash/hulaaki/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/suvash/hulaaki/compare/078ccb7569ff97bb36a78faf43e048ae24478453...v0.0.1

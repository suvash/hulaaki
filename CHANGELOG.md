# Change Log
All notable changes to this project will be documented in this file. This change log follows the conventions of [keepachangelog.com](http://keepachangelog.com/).

## [Unreleased]
### Updated
- Default `timeout` for mqtt TCP connection increased to 10 seconds.
- Added qos `case` matching for qos 2 to return `:noop`, to get rid of warnings.

## [0.1.1] - 2017-12-09
### Fixed
- Stop the connection properly when a client is stopped
- Support Elixir 1.5.2
- Fix `Makefile`, `Dockerfile`, `docker-compose.yml` and `README.md` for better development environment workflow.
- Fix `extras` params in docs for `mix.exs`, so that docs are generated properly in `hex.pm`

## [0.1.0] - 2017-08-12
### Added
- Added link to CHANGELOG in the README
- Add instructions on using Makefile for running tests.
- Handle `gen_tcp` connection failures instead of crashing
- Add automatic ping to server (based on keep alive) and expect ping response with callbacks
- Handle packet ids internally (for control packets with variable header)
- Adds TLS/SSL support for the library
- Implement chunked message receiving so as to parse packets sent together

### Fixed
- Replaces all occurences of 65_536 to 65_535 (max limit for 2 bytes)

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

## [0.0.2] - 2015-08-30
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

[Unreleased]: https://github.com/suvash/hulaaki/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/suvash/hulaaki/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/suvash/hulaaki/compare/v0.0.4...v0.1.0
[0.0.4]: https://github.com/suvash/hulaaki/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/suvash/hulaaki/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/suvash/hulaaki/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/suvash/hulaaki/compare/078ccb7569ff97bb36a78faf43e048ae24478453...v0.0.1

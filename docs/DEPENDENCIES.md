# Phase 1 Dependency Inventory

Validated on 2026-07-22 from the resolved lock files and installed toolchain. The lock files are the authoritative complete transitive inventories; this document explains direct dependencies and deliberately avoids adding packages for later product modules.

## Toolchain

| Component | Installed version | Purpose |
| --- | --- | --- |
| Flutter | 3.41.9 stable | Mobile, tablet, and web client toolchain |
| Dart | 3.11.5 | Flutter language and analyzer |
| PHP | 8.5.0 | Laravel API runtime |
| Laravel Framework | 13.21.1 | Versioned REST API and server-side business boundary |
| Composer | 2.8.12 | PHP dependency management |
| PHPUnit | 12.5.31 | API automated tests |
| Laravel Pint | 1.29.3 | PHP formatting validation |

## Flutter direct dependencies

| Package | Resolved version | Reason |
| --- | --- | --- |
| `flutter_riverpod` | 3.3.2 | Explicit, testable application and session state |
| `go_router` | 17.3.0 | Declarative navigation and authentication/context guards |
| `dio` | 5.10.0 | HTTP client, interceptors, request IDs, and typed transport errors |
| `drift` | 2.34.2 | Typed SQLite schema, transactions, and reactive offline queries |
| `drift_flutter` | 0.3.1 | Flutter-native Drift database opening |
| `flutter_secure_storage` | 10.3.1 | Platform-protected access and renewal credential storage |
| `connectivity_plus` | 7.3.0 | Network availability hints; never treated as proof of API reachability |
| `uuid` | 4.6.0 | Client-generated UUIDv7 identifiers and request/idempotency identifiers |
| `intl` | 0.20.3 | Locale-aware date/time presentation |
| `freezed_annotation` | 3.1.0 | Immutable typed model annotations |
| `json_annotation` | 4.12.0 | JSON mapping annotations |
| `cupertino_icons` | 1.0.9 | Standard iOS icon glyphs retained from Flutter foundation |

Development-only packages are `build_runner` 2.15.1, `drift_dev` 2.34.0, `freezed` 3.2.5, and `json_serializable` 6.14.0 for generated typed code; `flutter_lints` 6.0.0 and the SDK `flutter_test` package enforce quality. `pubspec.lock` records all transitives exactly.

## Laravel direct dependencies

| Package | Resolved version | Reason |
| --- | --- | --- |
| `laravel/framework` | 13.21.1 | API routing, validation, ORM, migrations, queue, rate limiting, and testing foundation |
| `laravel/tinker` | 3.0.2 | Local framework REPL for controlled diagnostics |
| `laravel/pail` | 1.2.7 | Local log inspection supplied by the Laravel skeleton |
| `laravel/pao` | 1.1.2 | Compact test-tool output supplied by the Laravel skeleton |
| `fakerphp/faker` | 1.24.1 | Test factories and environment-controlled development seeds |
| `mockery/mockery` | 1.6.12 | Test doubles |
| `nunomaduro/collision` | 8.9.5 | Readable CLI test failures |
| `phpunit/phpunit` | 12.5.31 | Automated unit and feature testing |
| `laravel/pint` | 1.29.3 | Deterministic PHP formatting checks |

No authentication package was added: Phase 1 uses hashed, opaque, server-side sessions so access expiry, rotating renewal credentials, revocation, and organization/farm context remain explicit. `composer.lock` records all transitives exactly.

## Deliberate exclusions

No analytics, background-sync scheduler, push notification, biometric, mapping, AI, IoT, payment, reporting, or later product-module dependency is installed in Phase 1. A production SQLite encryption choice is intentionally deferred until mobile release threat modeling; the current managed Windows validation uses the operating-system SQLite library.

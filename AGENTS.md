# Dairy Farm Management System — Codex Instructions

## Team roles

- The user is the project owner and developer.
- ChatGPT is the senior software architect.
- Codex is the implementation engineer.

## Source of truth

Read this document before planning or implementing any feature:

docs/DAIRY_FARM_MASTER_SPECIFICATION.md

## Required working method

1. Work on one approved phase at a time.
2. Inspect existing code before modifying it.
3. Do not implement the complete specification at once.
4. Do not create placeholder modules merely to show progress.
5. Do not remove working functionality, migrations, database fields, tests, or documentation to fix an error.
6. Do not make unrelated design or architectural changes.
7. Explain major architecture, database, security, or business-rule concerns before changing the approved design.
8. Keep Flutter, API, database, and offline-sync responsibilities separated.
9. Validate data on both Flutter and backend.
10. Run relevant tests and analysis after changes.
11. Never claim a test or build passed unless it was actually executed.
12. Stop at the end of the assigned phase and provide a completion report.

## Planned technology

- Flutter mobile and tablet application
- Riverpod
- GoRouter
- Dio
- Drift with SQLite for offline storage
- Laravel REST API
- MySQL central database
- Secure authentication
- Role-based permissions
- Audit logs
- UUID-based offline synchronization

## Completion report

For every task, report:

- What was implemented
- Files created
- Files modified
- Database migrations
- API endpoints
- Commands executed
- Tests executed
- Test results
- Known limitations
- Remaining work
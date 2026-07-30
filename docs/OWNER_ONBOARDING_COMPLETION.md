# Owner Onboarding and Family Access Completion

Date: 2026-07-29
Branch: `codex/owner-onboarding`

## Implemented

- Public owner signup that creates one private tenant and one named farm.
- Direct post-signup and later login into the owner's single farm.
- Reusable, owner-controlled family invitation link.
- Multiple persistent family accounts with separate logins.
- Immediate session revocation when the primary owner removes a family account.
- Owner-controlled restoration of removed family accounts.
- Editable name, email, phone number, and private profile picture.
- Responsive Flutter login, owner signup, family signup, profile, and family
  management screens.
- Permission-aware navigation and single-farm context simplification.
- Audit events for signup, invitation changes, membership changes, and profile
  changes.
- OpenAPI documentation for all 15 new operations.

## Database migration

`2026_07_29_000300_add_owner_onboarding_and_profiles.php` adds:

- `users.phone_number`
- `users.profile_photo_path`
- `organization_memberships.membership_type`
- `organization_memberships.invited_by_membership_id`
- `farm_invite_links`

The migration was executed by a fresh seeded migration against the isolated
MySQL `dairycare_test` database. No development database was reset.

## Security and isolation evidence

- The invitation secret is hashed for validation and encrypted for retrieval.
- Old invitation tokens stop working after disable or regeneration.
- Only `primary_owner` memberships can manage invitations and family access.
- Removed members' sessions are revoked immediately.
- Cross-organization membership identifiers are concealed as not found.
- Family profiles and photos remain tenant scoped.
- New self-service roles cannot create or archive farms.
- Signup is rate-limited and active family accounts are bounded.

## Validation

Backend:

- Pint apply and check: passed.
- PHP syntax: 181 files checked, 0 failures.
- MySQL 8 fresh migration and seed: passed.
- MySQL suite: 74 passed, 760 assertions.
- SQLite portability suite: 66 passed, 638 assertions, 8 MySQL-only tests
  skipped.
- Composer validation: passed.
- Composer audit: no security advisories.
- Laravel/OpenAPI parity: 67 operations in each, 0 missing, 0 extra.
- Redocly lint and bundle: passed; 22 non-blocking recommended warnings remain.

Flutter:

- Dart format: 88 files, 0 changes.
- Flutter analyze: no issues.
- Flutter tests: 71 passed.
- Release web build: passed; WebAssembly dry run passed.
- Android debug APK build: passed.

## Known limitations

- Invitation delivery uses copy/paste; no email or SMS service is integrated.
- A native production invitation needs an approved public web/universal-link
  base URL.
- Email verification, password reset, MFA, ownership transfer, custom
  membership roles, employee accounts, and more than one farm per
  self-service owner are not implemented.
- No production deployment or signing was performed.

## Remaining work

Stop after this phase. Begin another product capability only after the project
owner approves its exact scope.

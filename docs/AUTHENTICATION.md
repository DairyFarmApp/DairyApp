# Authentication and Session Model

Login accepts email/password plus optional device UUID/name. Responses contain a short-lived opaque access token, rotating renewal credential, expiry values, current user, memberships, accessible farms, permissions, and active context.

## Token storage and expiry

Tokens use a UUIDv7 session lookup identifier plus a 256-bit random secret. `api_sessions` stores only SHA-256 access/current-renewal hashes; `api_session_renewal_tokens` stores only renewal hashes and consumption timestamps. Raw credentials are returned once and belong only in Flutter Secure Storage. Access expires after 15 minutes and renewal after 30 days by default; both are enforced server-side and configurable through the documented environment variables. Comparison uses `hash_equals`.

## Rotation, reuse, and revocation

Renewal locks the session row and revalidates the presented hash inside that lock. The current renewal hash is marked consumed before both secrets rotate. Consequently, concurrent requests cannot both successfully rotate the same credential. If a consumed credential is presented, the API returns the same generic `401`, revokes the session family, sets `renewal_reuse_detected_at`, and atomically records `auth.renewal_reuse_detected`. The newly returned token from a racing first request is therefore also invalid once reuse is detected.

Phase 1.2 verifies this policy with two independent PHP/Laravel processes and separate MySQL connections released simultaneously. Exactly one request initially rotates, the stale contender triggers family revocation, both replacement credentials become unusable, one safe reuse audit exists, and no raw credential appears in token tables, audit JSON, or Laravel logs.

Logout and individual-session revocation immediately revoke both access and renewal use through the shared session row. Disabling a user or changing a password revokes all existing sessions. The current rule intentionally signs out every device after a password change; a future password-management endpoint must audit that action and may issue a new session only after successful reauthentication.

## Login protection

- Per normalized identity: 10 attempts per minute across IP addresses.
- Per IP address: 30 attempts per minute.
- Account counter window: 15 minutes.
- Temporary lock: five failed attempts cause a five-minute lock.
- Requests during an active lock do not extend it.
- An expired lock resets before the next attempt; a successful login clears counters and lock state.
- All failures use `INVALID_CREDENTIALS` and create a safe audit event.

Administrative recovery currently requires an authorized operator to reactivate the user or clear `failed_login_count`, `last_failed_login_at`, and `locked_until` through a controlled console/database procedure. No unaudited administrative HTTP endpoint is exposed in Phase 1.1.

Every session has at most one active organization and farm. Organization/farm switching revalidates membership/access, clears incompatible farm context, rotates credentials, and records an audit event. Audit redaction covers password, token, credential, authorization, cookie, API/private-key, and reset-code key variants recursively.

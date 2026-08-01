# Owner Onboarding and Family Access

## Account model

DairyCare uses one simple self-service account model:

1. A farm owner creates an account with their name, farm name, email, optional
   phone number, and password.
2. The API creates one private organization and its first farm with that name.
3. The owner is signed in directly to that farm as its `primary_owner`.
4. The owner can create a reusable family invitation link.
5. Any trusted relative who receives the link can create a separate
   `family_admin` login in the same organization, initially opened on the
   invited farm.

The organization remains the server-side tenant boundary, but it is not an
extra concept the owner has to configure. The owner and trusted family admins
may add more farms inside that same organization. Their owner role includes
`farms.create` but deliberately excludes `farms.archive` so a farm cannot be
removed through the ordinary self-service workflow.

The Flutter **Farm** menu shows the selected farm profile and provides **Add
farm** when the account has permission. Creating a farm saves it through the
API, refreshes the session, and selects the new farm. Once an organization has
more than one farm, **Switch farm** is available from the account menu. The
hierarchy is:

`Farm -> Sheds -> Animals -> Milk production`

Sheds are created from the **Sheds** menu and belong to the selected farm.
Every newly registered animal must be assigned to one farm and one of its
sheds. Post-registration location changes continue to use the audited
animal-movement workflow.

## Primary owner

The person who creates the farm is its permanent primary owner. The primary
owner can:

- use every implemented farm-management workflow;
- create and switch between farms inside their organization;
- edit their own name, email, phone number, and profile picture;
- create, copy, disable, or regenerate the family invitation link;
- see active and removed family accounts;
- remove a family account immediately;
- restore a previously removed family account.

A family member cannot remove the primary owner, take ownership, regenerate
the invitation, or manage other family memberships. Those controls remain
with the primary owner even though family members can manage normal farm data.

## Reusable family invitation

The invitation behaves like a private WhatsApp group link:

- it is reusable and can create more than one family account;
- it does not expire automatically;
- it joins every accepted account to the correct organization and opens the
  linked farm first;
- the owner can disable it at any time;
- regenerating it invalidates the previous link immediately;
- disabling the link does not remove family accounts that already joined.

The server stores a SHA-256 hash for verification and an application-encrypted
copy for the owner to retrieve. The raw secret is never stored in plaintext.
Signup is rate-limited, and the configured default maximum is 25 active family
accounts per organization (`AUTH_MAXIMUM_FAMILY_ACCOUNTS`).

The current Flutter client copies a web signup URL when running in a browser.
Native mobile production builds will need an approved public web/universal-link
base URL before links can open the app directly outside the browser.

## Family account lifecycle

Each family member has their own email, password, profile, and API sessions.
An account is persistent; using the invitation does not create temporary or
single-use access.

When the primary owner removes a family account:

- its membership status becomes `removed`;
- all active sessions for that farm membership are revoked immediately;
- the old access token can no longer call the API;
- the account disappears from active family access;
- its historical audit and domain records remain intact.

Restoring the membership re-enables login. It does not restore an old session;
the family member must sign in again.

## Profile security

Authenticated owners and family members can edit:

- display name;
- email address;
- phone number;
- JPG, JPEG, PNG, or WebP profile picture up to 5 MB.

Changing an email address requires the current password. Photos are stored in
private Laravel storage and are returned only through authenticated,
tenant-scoped endpoints. Passwords require at least 10 characters containing
letters and numbers.

## API operations

Public onboarding:

- `POST /api/v1/auth/owner-signup`
- `POST /api/v1/auth/family-invite/inspect`
- `POST /api/v1/auth/family-signup`

Authenticated profile:

- `GET /api/v1/auth/profile`
- `PATCH /api/v1/auth/profile`
- `GET /api/v1/auth/profile/photo`
- `POST /api/v1/auth/profile/photo`
- `DELETE /api/v1/auth/profile/photo`
- `GET /api/v1/profile-photos/{user}`

Primary-owner family management:

- `GET /api/v1/family-invite`
- `POST /api/v1/family-invite`
- `DELETE /api/v1/family-invite`
- `GET /api/v1/family-members`
- `DELETE /api/v1/family-members/{membership}`
- `POST /api/v1/family-members/{membership}/restore`

Farm management:

- `GET /api/v1/farms`
- `POST /api/v1/farms`
- `GET /api/v1/farms/{farm}`
- `PATCH /api/v1/farms/{farm}`
- `POST /api/v1/auth/switch-farm`

The complete request and response contract is in `apps/api/openapi.yaml`.

## Explicit limitations

This controlled phase does not add employee login accounts, custom role
editing, email delivery, password reset, email verification, MFA, ownership
transfer, farm archival, or production universal/deep links. Those require
separately approved security and product work.

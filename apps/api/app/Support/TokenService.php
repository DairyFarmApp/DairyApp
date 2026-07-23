<?php

namespace App\Support;

use App\Models\ApiSession;
use App\Models\ApiSessionRenewalToken;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class TokenService
{
    public function issue(User $user, Request $request, ?string $organizationId = null, ?string $farmId = null): array
    {
        return DB::transaction(function () use ($user, $request, $organizationId, $farmId): array {
            $sessionId = (string) Str::uuid7();
            $accessSecret = $this->secret();
            $renewalSecret = $this->secret();
            $renewalExpiry = now()->addDays((int) config('dairycare.auth.renewal_ttl_days', 30));
            $session = ApiSession::create([
                'id' => $sessionId,
                'user_id' => $user->id,
                'organization_id' => $organizationId,
                'farm_id' => $farmId,
                'access_token_hash' => hash('sha256', $accessSecret),
                'renewal_token_hash' => hash('sha256', $renewalSecret),
                'access_expires_at' => now()->addMinutes((int) config('dairycare.auth.access_ttl_minutes', 15)),
                'renewal_expires_at' => $renewalExpiry,
                'device_name' => $request->string('device_name')->limit(120)->toString() ?: null,
                'device_id' => $request->input('device_id'),
                'ip_address' => $request->ip(),
                'user_agent' => Str::limit((string) $request->userAgent(), 1000, ''),
            ]);
            $this->recordRenewalToken($session, $renewalSecret, $renewalExpiry);

            return $this->tokenPayload($session, $accessSecret, $renewalSecret);
        });
    }

    public function rotate(ApiSession $session): array
    {
        return DB::transaction(function () use ($session): array {
            $locked = ApiSession::query()->with('user')->lockForUpdate()->findOrFail($session->id);
            abort_if($locked->revoked_at || $locked->renewal_expires_at->isPast() || ! $locked->user->is_active, 401);

            return $this->rotateLocked($locked);
        });
    }

    /**
     * @return array{status: 'rotated', tokens: array}|array{status: 'reused', session: ApiSession}|array{status: 'invalid'}
     */
    public function renew(string $credential): array
    {
        [$id, $secret] = $this->parse($credential);
        if ($id === null || $secret === null) {
            return ['status' => 'invalid'];
        }
        $candidateHash = hash('sha256', $secret);

        return DB::transaction(function () use ($id, $candidateHash): array {
            $session = ApiSession::query()->with('user')->lockForUpdate()->find($id);
            if (! $session) {
                return ['status' => 'invalid'];
            }

            $isCurrent = hash_equals($session->renewal_token_hash, $candidateHash);
            if ($isCurrent && ! $session->revoked_at && ! $session->renewal_expires_at->isPast() && $session->user->is_active) {
                return ['status' => 'rotated', 'tokens' => $this->rotateLocked($session)];
            }

            $consumed = ApiSessionRenewalToken::query()
                ->where('api_session_id', $session->id)
                ->where('token_hash', $candidateHash)
                ->whereNotNull('consumed_at')
                ->exists();
            if ($consumed) {
                $session->forceFill([
                    'revoked_at' => $session->revoked_at ?? now(),
                    'renewal_reuse_detected_at' => $session->renewal_reuse_detected_at ?? now(),
                ])->save();

                return ['status' => 'reused', 'session' => $session];
            }

            if (! $session->user->is_active && ! $session->revoked_at) {
                $session->forceFill(['revoked_at' => now()])->save();
            }

            return ['status' => 'invalid'];
        });
    }

    public function find(string $token): ?ApiSession
    {
        [$id, $secret] = $this->parse($token);
        if ($id === null || $secret === null) {
            return null;
        }
        $session = ApiSession::query()->with('user')->find($id);
        if (! $session || $session->revoked_at || $session->access_expires_at->isPast()) {
            return null;
        }
        if (! hash_equals($session->access_token_hash, hash('sha256', $secret))) {
            return null;
        }

        return $session;
    }

    /**
     * @return array{0: ?string, 1: ?string}
     */
    private function parse(string $token): array
    {
        [$id, $secret] = array_pad(explode('.', $token, 2), 2, null);
        if (! is_string($id) || ! Str::isUuid($id) || ! is_string($secret)) {
            return [null, null];
        }

        return [$id, $secret];
    }

    private function rotateLocked(ApiSession $session): array
    {
        $accessSecret = $this->secret();
        $renewalSecret = $this->secret();
        $renewalExpiry = now()->addDays((int) config('dairycare.auth.renewal_ttl_days', 30));
        ApiSessionRenewalToken::query()
            ->where('api_session_id', $session->id)
            ->where('token_hash', $session->renewal_token_hash)
            ->whereNull('consumed_at')
            ->update(['consumed_at' => now(), 'updated_at' => now()]);
        $session->forceFill([
            'access_token_hash' => hash('sha256', $accessSecret),
            'renewal_token_hash' => hash('sha256', $renewalSecret),
            'access_expires_at' => now()->addMinutes((int) config('dairycare.auth.access_ttl_minutes', 15)),
            'renewal_expires_at' => $renewalExpiry,
            'last_used_at' => now(),
        ])->save();
        $this->recordRenewalToken($session, $renewalSecret, $renewalExpiry);

        return $this->tokenPayload($session, $accessSecret, $renewalSecret);
    }

    private function recordRenewalToken(ApiSession $session, string $secret, mixed $expiresAt): void
    {
        ApiSessionRenewalToken::create([
            'api_session_id' => $session->id,
            'token_hash' => hash('sha256', $secret),
            'expires_at' => $expiresAt,
        ]);
    }

    private function tokenPayload(ApiSession $session, string $accessSecret, string $renewalSecret): array
    {
        return [
            'access_token' => $session->id.'.'.$accessSecret,
            'renewal_credential' => $session->id.'.'.$renewalSecret,
            'access_expires_at' => $session->access_expires_at->toISOString(),
            'renewal_expires_at' => $session->renewal_expires_at->toISOString(),
            'session' => $session,
        ];
    }

    private function secret(): string
    {
        return rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
    }
}

<?php

namespace App\Support;

use App\Models\AuditLog;
use Illuminate\Http\Request;

final class AuditService
{
    private const REDACTED = '[REDACTED]';

    public function record(Request $request, string $action, ?string $entityType = null, ?string $entityId = null, ?array $old = null, ?array $new = null): AuditLog
    {
        $session = $request->attributes->get('api_session');

        return AuditLog::create([
            'organization_id' => $session?->organization_id,
            'user_id' => $request->user()?->id,
            'action' => $action,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'old_values' => $this->redact($old),
            'new_values' => $this->redact($new),
            'request_id' => $request->attributes->get('request_id'),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);
    }

    public function redact(?array $values): ?array
    {
        if ($values === null) {
            return null;
        }
        foreach ($values as $key => &$value) {
            if ($this->isSensitiveKey((string) $key)) {
                $value = self::REDACTED;
            } elseif (is_array($value)) {
                $value = $this->redact($value);
            }
        }

        return $values;
    }

    private function isSensitiveKey(string $key): bool
    {
        $normalized = strtolower(str_replace(['-', '.', ' '], '_', $key));

        return preg_match('/(?:password|passphrase|secret|token|credential|authorization|cookie|api_?key|private_?key|reset_?code)/', $normalized) === 1;
    }
}

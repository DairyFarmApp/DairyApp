<?php

namespace App\Support;

use App\Models\IdempotencyRecord;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

final class IdempotencyService
{
    public function execute(Request $request, callable $operation): JsonResponse
    {
        $key = $request->header('Idempotency-Key');
        if (! is_string($key) || trim($key) === '') {
            return $operation();
        }
        if (strlen($key) > 160) {
            return ApiResponse::error($request, 'INVALID_IDEMPOTENCY_KEY', 'The idempotency key is too long.', 400);
        }
        $session = $request->attributes->get('api_session');
        $fingerprint = hash('sha256', json_encode($this->canonicalize($request->all()), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION));
        $scope = hash('sha256', implode('|', [$session->organization_id, $session->user_id, $session->device_id ?? '-', $request->path(), $request->method(), $key]));

        return DB::transaction(function () use ($request, $operation, $key, $fingerprint, $scope, $session): JsonResponse {
            $now = now();
            $id = (string) Str::uuid7();
            $inserted = DB::table('idempotency_records')->insertOrIgnore([
                'id' => $id,
                'organization_id' => $session->organization_id,
                'user_id' => $session->user_id,
                'device_id' => $session->device_id,
                'scope_key' => $scope,
                'endpoint' => $request->path(),
                'method' => $request->method(),
                'idempotency_key' => $key,
                'request_fingerprint' => $fingerprint,
                'status' => 'processing',
                'created_at' => $now,
                'updated_at' => $now,
            ]);
            if ($inserted === 0) {
                $existing = IdempotencyRecord::query()->where('scope_key', $scope)->lockForUpdate()->firstOrFail();

                return $this->existingResponse($request, $existing, $fingerprint);
            }

            $record = IdempotencyRecord::query()->findOrFail($id);
            $response = $operation();
            $record->forceFill(['status' => 'completed', 'response_status' => $response->getStatusCode(), 'response_body' => json_decode($response->getContent(), true), 'completed_at' => now()])->save();

            return $response;
        });
    }

    private function existingResponse(Request $request, IdempotencyRecord $existing, string $fingerprint): JsonResponse
    {
        if (! hash_equals($existing->request_fingerprint, $fingerprint)) {
            return ApiResponse::error($request, 'IDEMPOTENCY_KEY_REUSED', 'The idempotency key was already used with a different payload.', 409);
        }
        if ($existing->status === 'completed') {
            return response()->json($existing->response_body, $existing->response_status);
        }

        return ApiResponse::error($request, 'IDEMPOTENCY_IN_PROGRESS', 'The original request is still being processed.', 409);
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }
        if (array_is_list($value)) {
            return array_map(fn (mixed $item): mixed => $this->canonicalize($item), $value);
        }
        ksort($value, SORT_STRING);

        return array_map(fn (mixed $item): mixed => $this->canonicalize($item), $value);
    }
}

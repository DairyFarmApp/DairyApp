<?php

namespace Tests\Feature;

use App\Models\ApiSession;
use App\Models\ApiSessionRenewalToken;
use App\Models\AuditLog;
use App\Models\Farm;
use App\Models\IdempotencyRecord;
use App\Models\Organization;
use App\Models\User;
use App\Support\IdempotencyService;
use Illuminate\Foundation\Testing\RefreshDatabaseState;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use RuntimeException;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class MySqlConcurrencyTest extends TestCase
{
    use CreatesFoundationData;

    protected function setUp(): void
    {
        parent::setUp();

        if (DB::connection()->getDriverName() !== 'mysql') {
            $this->markTestSkipped('This test requires the Phase 1.2 MySQL validation database.');
        }

        Artisan::call('migrate:fresh', ['--force' => true]);
    }

    protected function tearDown(): void
    {
        RefreshDatabaseState::$migrated = false;
        DB::disconnect();

        parent::tearDown();
    }

    public function test_concurrent_renewal_serializes_rotation_and_revokes_the_reused_family(): void
    {
        $this->foundation();
        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'owner@example.test',
            'password' => 'Correct-Horse-2026',
        ])->assertOk();
        $credential = $login->json('data.renewal_credential');

        $results = $this->runConcurrently([
            $this->requestPayload('/api/v1/auth/renew', ['renewal_credential' => $credential]),
            $this->requestPayload('/api/v1/auth/renew', ['renewal_credential' => $credential]),
        ]);

        $this->assertSame([200, 401], collect($results)->pluck('status')->sort()->values()->all());
        $successful = collect($results)->firstWhere('status', 200);
        $rejected = collect($results)->firstWhere('status', 401);
        $this->assertSame('INVALID_RENEWAL_CREDENTIAL', $rejected['error_code']);

        $session = ApiSession::query()->firstOrFail();
        $this->assertNotNull($session->revoked_at);
        $this->assertNotNull($session->renewal_reuse_detected_at);
        $this->assertSame(2, ApiSessionRenewalToken::query()->count());
        $this->assertSame(1, ApiSessionRenewalToken::query()->whereNotNull('consumed_at')->count());
        $this->assertSame(1, AuditLog::query()->where('action', 'auth.session_renewed')->count());
        $this->assertSame(1, AuditLog::query()->where('action', 'auth.renewal_reuse_detected')->count());

        $this->getJson('/api/v1/auth/me', $this->bearer($successful['data']['access_token']))->assertUnauthorized();
        $this->postJson('/api/v1/auth/renew', [
            'renewal_credential' => $successful['data']['renewal_credential'],
        ])->assertUnauthorized();

        foreach ([
            $credential,
            $successful['data']['access_token'],
            $successful['data']['renewal_credential'],
        ] as $rawCredential) {
            $this->assertDatabaseMissing('api_sessions', ['access_token_hash' => $rawCredential]);
            $this->assertDatabaseMissing('api_sessions', ['renewal_token_hash' => $rawCredential]);
            $this->assertDatabaseMissing('api_session_renewal_tokens', ['token_hash' => $rawCredential]);
            $this->assertStringNotContainsString($rawCredential, AuditLog::query()->get()->toJson());
            foreach (glob(storage_path('logs/*.log')) ?: [] as $log) {
                $this->assertStringNotContainsString($rawCredential, (string) file_get_contents($log));
            }
        }
    }

    public function test_concurrent_identical_creates_commit_once_and_replay_the_committed_result(): void
    {
        $this->foundation(['farms.view', 'farms.create']);
        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'owner@example.test',
            'password' => 'Correct-Horse-2026',
            'device_id' => '018f0000-0000-7000-8000-000000000099',
        ])->assertOk();
        $token = $login->json('data.access_token');
        $key = 'mysql-concurrent-create';
        $headers = ['Authorization' => 'Bearer '.$token, 'Idempotency-Key' => $key];

        $results = $this->runConcurrently([
            $this->requestPayload('/api/v1/farms', [
                'name' => 'Concurrent Farm',
                'code' => 'MYSQL-CONCURRENT',
                'timezone' => 'UTC',
            ], $headers),
            $this->requestPayload('/api/v1/farms', [
                'timezone' => 'UTC',
                'code' => 'MYSQL-CONCURRENT',
                'name' => 'Concurrent Farm',
            ], $headers),
        ]);

        $this->assertSame([201, 201], collect($results)->pluck('status')->sort()->values()->all());
        $this->assertCount(1, collect($results)->pluck('data.id')->unique());
        $this->assertSame(1, Farm::query()->where('code', 'MYSQL-CONCURRENT')->count());
        $record = IdempotencyRecord::query()->where('idempotency_key', $key)->firstOrFail();
        $this->assertSame('completed', $record->status);
        $this->assertNotNull($record->completed_at);

        $retry = $this->postJson('/api/v1/farms', [
            'timezone' => 'UTC',
            'name' => 'Concurrent Farm',
            'code' => 'MYSQL-CONCURRENT',
        ], $this->bearer($token) + ['Idempotency-Key' => $key])->assertCreated();
        $this->assertSame($results[0]['data']['id'], $retry->json('data.id'));

        $this->postJson('/api/v1/farms', [
            'name' => 'Different Farm',
            'code' => 'DIFFERENT',
            'timezone' => 'UTC',
        ], $this->bearer($token) + ['Idempotency-Key' => $key])
            ->assertConflict()
            ->assertJsonPath('error.code', 'IDEMPOTENCY_KEY_REUSED');
    }

    public function test_failed_idempotent_transaction_leaves_no_record_or_domain_write(): void
    {
        $data = $this->foundation(['farms.create']);
        $this->loginToken();
        $session = ApiSession::query()->firstOrFail();
        $request = Request::create('/api/v1/farms', 'POST', [
            'name' => 'Rolled Back Farm',
            'code' => 'ROLLBACK',
            'timezone' => 'UTC',
        ]);
        $request->headers->set('Idempotency-Key', 'mysql-failed-operation');
        $request->attributes->set('api_session', $session);

        try {
            app(IdempotencyService::class)->execute($request, function () use ($data): never {
                Farm::query()->create([
                    'organization_id' => $data['organization']->id,
                    'name' => 'Rolled Back Farm',
                    'code' => 'ROLLBACK',
                    'timezone' => 'UTC',
                ]);
                throw new RuntimeException('Deliberate transaction rollback.');
            });
            $this->fail('The deliberate failure did not escape the idempotency transaction.');
        } catch (RuntimeException $exception) {
            $this->assertSame('Deliberate transaction rollback.', $exception->getMessage());
        }

        $this->assertDatabaseMissing('farms', ['code' => 'ROLLBACK']);
        $this->assertDatabaseMissing('idempotency_records', ['idempotency_key' => 'mysql-failed-operation']);
    }

    public function test_idempotency_scope_separates_organization_user_device_method_and_endpoint(): void
    {
        $data = $this->foundation();
        $otherOrganization = Organization::query()->create(['name' => 'Other Organization']);
        $otherUser = User::query()->create([
            'name' => 'Other User',
            'email' => 'other@example.test',
            'password' => Hash::make('Correct-Horse-2026'),
            'is_active' => true,
        ]);
        $service = app(IdempotencyService::class);
        $combinations = [
            [$data['organization']->id, $data['user']->id, '018f0000-0000-7000-8000-000000000001', '/api/v1/farms', 'POST'],
            [$otherOrganization->id, $data['user']->id, '018f0000-0000-7000-8000-000000000001', '/api/v1/farms', 'POST'],
            [$data['organization']->id, $otherUser->id, '018f0000-0000-7000-8000-000000000001', '/api/v1/farms', 'POST'],
            [$data['organization']->id, $data['user']->id, '018f0000-0000-7000-8000-000000000002', '/api/v1/farms', 'POST'],
            [$data['organization']->id, $data['user']->id, '018f0000-0000-7000-8000-000000000001', '/api/v1/sheds', 'POST'],
            [$data['organization']->id, $data['user']->id, '018f0000-0000-7000-8000-000000000001', '/api/v1/farms', 'PATCH'],
        ];

        foreach ($combinations as [$organizationId, $userId, $deviceId, $path, $method]) {
            $request = Request::create($path, $method, ['value' => 'same']);
            $request->headers->set('Idempotency-Key', 'same-scope-key');
            $request->attributes->set('api_session', (object) [
                'organization_id' => $organizationId,
                'user_id' => $userId,
                'device_id' => $deviceId,
            ]);
            $service->execute($request, fn () => response()->json(['data' => ['ok' => true]], 201));
        }

        $records = IdempotencyRecord::query()->where('idempotency_key', 'same-scope-key')->get();
        $this->assertCount(count($combinations), $records);
        $this->assertCount(count($combinations), $records->pluck('scope_key')->unique());
    }

    public function test_concurrent_animal_creates_generate_unique_organization_numbers(): void
    {
        $data = $this->foundation(['animals.view', 'animals.create']);
        $references = $this->animalRegistryReferences($data);
        $token = $this->loginToken();
        $payload = [
            'species_id' => $references['species']->id,
            'breed_id' => $references['breed']->id,
            'sex' => 'female',
            'life_stage' => 'adult',
            'date_of_birth' => '2022-01-01',
            'current_farm_id' => $data['farm']->id,
            'current_shed_id' => $data['shed']->id,
            'current_animal_group_id' => $references['group']->id,
            'origin' => 'born_on_farm',
        ];

        $results = $this->runConcurrently([
            $this->requestPayload('/api/v1/animals', $payload, $this->bearer($token) + ['Idempotency-Key' => 'animal-sequence-a']),
            $this->requestPayload('/api/v1/animals', $payload, $this->bearer($token) + ['Idempotency-Key' => 'animal-sequence-b']),
        ]);

        $this->assertSame([201, 201], collect($results)->pluck('status')->sort()->values()->all());
        $numbers = collect($results)->pluck('data.animal_number')->sort()->values()->all();
        $this->assertSame(['AN-000001', 'AN-000002'], $numbers);
        $this->assertCount(2, collect($results)->pluck('data.id')->unique());
        $this->assertDatabaseCount('animals', 2);
        $this->assertDatabaseHas('organization_sequences', [
            'organization_id' => $data['organization']->id,
            'sequence_key' => 'animal_number',
            'next_value' => 3,
        ]);
    }

    /**
     * @param  array<int, array<string, mixed>>  $payloads
     * @return array<int, array<string, mixed>>
     */
    private function runConcurrently(array $payloads): array
    {
        $worker = base_path('tests/Support/mysql_http_worker.php');
        $processes = [];

        foreach ($payloads as $payload) {
            $pipes = [];
            $process = proc_open(
                [PHP_BINARY, $worker],
                [
                    0 => ['pipe', 'r'],
                    1 => ['pipe', 'w'],
                    2 => ['pipe', 'w'],
                ],
                $pipes,
                base_path(),
            );
            $this->assertIsResource($process);
            fwrite($pipes[0], json_encode($payload, JSON_THROW_ON_ERROR)."\n");
            fflush($pipes[0]);
            $processes[] = compact('process', 'pipes');
        }

        foreach ($processes as $item) {
            $this->assertSame('READY', trim((string) fgets($item['pipes'][1])));
        }
        foreach ($processes as $item) {
            fwrite($item['pipes'][0], "GO\n");
            fclose($item['pipes'][0]);
        }

        $results = [];
        foreach ($processes as $item) {
            $output = trim((string) stream_get_contents($item['pipes'][1]));
            $errors = trim((string) stream_get_contents($item['pipes'][2]));
            fclose($item['pipes'][1]);
            fclose($item['pipes'][2]);
            $exitCode = proc_close($item['process']);
            $this->assertSame(0, $exitCode, $errors);
            $this->assertSame('', $errors);
            $results[] = json_decode($output, true, flags: JSON_THROW_ON_ERROR);
        }

        return $results;
    }

    /**
     * @param  array<string, mixed>  $body
     * @param  array<string, string>  $headers
     * @return array<string, mixed>
     */
    private function requestPayload(string $path, array $body, array $headers = []): array
    {
        return [
            'method' => 'POST',
            'path' => $path,
            'headers' => $headers,
            'body' => $body,
        ];
    }
}

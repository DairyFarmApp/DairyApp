<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

require dirname(__DIR__, 2).'/vendor/autoload.php';

$app = require dirname(__DIR__, 2).'/bootstrap/app.php';
$kernel = $app->make(Kernel::class);
$kernel->bootstrap();

try {
    $payload = json_decode((string) fgets(STDIN), true, flags: JSON_THROW_ON_ERROR);
    fwrite(STDOUT, "READY\n");
    fflush(STDOUT);

    if (trim((string) fgets(STDIN)) !== 'GO') {
        throw new RuntimeException('The concurrency worker did not receive its start signal.');
    }

    $server = [
        'CONTENT_TYPE' => 'application/json',
        'HTTP_ACCEPT' => 'application/json',
        'REMOTE_ADDR' => '127.0.0.1',
    ];
    foreach ($payload['headers'] ?? [] as $name => $value) {
        $server['HTTP_'.strtoupper(str_replace('-', '_', $name))] = $value;
    }

    $request = Request::create(
        $payload['path'],
        $payload['method'],
        server: $server,
        content: json_encode($payload['body'] ?? [], JSON_THROW_ON_ERROR),
    );
    $response = $kernel->handle($request);
    $decoded = json_decode($response->getContent(), true, flags: JSON_THROW_ON_ERROR);
    fwrite(STDOUT, json_encode([
        'status' => $response->getStatusCode(),
        'data' => $decoded['data'] ?? null,
        'error_code' => $decoded['error']['code'] ?? null,
    ], JSON_THROW_ON_ERROR)."\n");
    $kernel->terminate($request, $response);
} catch (Throwable $exception) {
    fwrite(STDERR, $exception::class."\n");
    exit(1);
}

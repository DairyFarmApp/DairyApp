<?php

namespace Tests\Unit;

use Illuminate\Support\Str;
use PHPUnit\Framework\TestCase;
use Ramsey\Uuid\Uuid;

class UuidTest extends TestCase
{
    public function test_laravel_generates_uuid_version_seven(): void
    {
        $uuid = (string) Str::uuid7();
        $this->assertTrue(Str::isUuid($uuid));
        $this->assertSame(7, Uuid::fromString($uuid)->getVersion());
    }
}

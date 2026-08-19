<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Concerns\CreatesFoundationData;
use Tests\TestCase;

class VisitorTest extends TestCase
{
    use CreatesFoundationData, RefreshDatabase;

    public function test_visitors_are_validated_saved_listed_and_soft_deleted(): void
    {
        $this->foundation(['visitors.view', 'visitors.manage']);
        $headers = $this->bearer($this->loginToken());

        $this->postJson('/api/v1/visitors', [], $headers)->assertUnprocessable();
        $created = $this->postJson('/api/v1/visitors', [
            'visitor_name' => 'Dr Ahmad Khan',
            'visited_at' => '2026-08-17T10:30:00Z',
            'purpose' => 'Routine herd inspection',
        ], $headers)->assertCreated()->assertJsonPath('data.visitor_name', 'Dr Ahmad Khan');

        $this->getJson('/api/v1/visitors', $headers)->assertOk()
            ->assertJsonPath('data.visitors.0.purpose', 'Routine herd inspection');
        $this->deleteJson('/api/v1/visitors/'.$created->json('data.id'), [], $headers)
            ->assertOk()->assertJsonPath('data.deleted', true);
        $this->assertSoftDeleted('visitor_records', ['id' => $created->json('data.id')]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'visitor.created']);
        $this->assertDatabaseHas('audit_logs', ['action' => 'visitor.deleted']);
    }
}

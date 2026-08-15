<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('delivery_manifest_stops', function (Blueprint $t): void {
            $t->string('proof_storage_path', 1000)->nullable()->after('acknowledged_by');
            $t->string('proof_original_name', 255)->nullable()->after('proof_storage_path');
            $t->string('proof_mime_type', 100)->nullable()->after('proof_original_name');
        });
        Schema::create('milk_sale_returns', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('milk_sale_id');
            $t->uuid('delivery_manifest_stop_id')->unique();
            $t->string('return_number', 60);
            $t->decimal('returned_quantity', 14, 3)->default(0);
            $t->decimal('rejected_quantity', 14, 3)->default(0);
            $t->decimal('restocked_quantity', 14, 3)->default(0);
            $t->decimal('disposed_quantity', 14, 3)->default(0);
            $t->decimal('credit_amount', 16, 2)->default(0);
            $t->string('reason', 500);
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique(['organization_id', 'return_number']);
            $t->index(['organization_id', 'farm_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('milk_sale_returns');
        Schema::table('delivery_manifest_stops', function (Blueprint $t): void {
            $t->dropColumn(['proof_storage_path', 'proof_original_name', 'proof_mime_type']);
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organization_sequences', function (Blueprint $table): void {
            $table->foreignUuid('organization_id')->constrained()->cascadeOnDelete();
            $table->string('sequence_key', 80);
            $table->unsignedBigInteger('next_value')->default(1);
            $table->timestamps();
            $table->primary(['organization_id', 'sequence_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organization_sequences');
    }
};

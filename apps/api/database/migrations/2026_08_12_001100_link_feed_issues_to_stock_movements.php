<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('stock_movements', function (Blueprint $t) {
            $t->string('reference_type', 80)->nullable()->after('reason');
            $t->uuid('reference_id')->nullable()->after('reference_type');
            $t->index(['reference_type', 'reference_id'], 'stock_movement_reference_idx');
        });
        Schema::table('daily_feed_issues', function (Blueprint $t) {
            $t->boolean('inventory_posted')->default(false)->after('returned_quantity');
            $t->decimal('inventory_net_quantity', 18, 3)->default(0)->after('inventory_posted');
        });
    }

    public function down(): void
    {
        Schema::table('daily_feed_issues', fn (Blueprint $t) => $t->dropColumn(['inventory_posted', 'inventory_net_quantity']));
        Schema::table('stock_movements', function (Blueprint $t) {
            $t->dropIndex('stock_movement_reference_idx');
            $t->dropColumn(['reference_type', 'reference_id']);
        });
    }
};

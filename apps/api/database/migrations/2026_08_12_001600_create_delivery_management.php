<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('delivery_routes', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->string('code', 40);
            $t->string('name', 160);
            $t->text('description')->nullable();
            $t->boolean('is_active')->default(true);
            $t->unsignedBigInteger('version')->default(1);
            $t->timestamps();
            $t->softDeletes();
            $t->unique(['organization_id', 'code']);
        });
        Schema::create('delivery_route_stops', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('delivery_route_id');
            $t->uuid('customer_id');
            $t->unsignedSmallInteger('stop_order');
            $t->string('delivery_address', 500)->nullable();
            $t->time('planned_time')->nullable();
            $t->text('notes')->nullable();
            $t->timestamps();
            $t->unique(['delivery_route_id', 'customer_id']);
            $t->unique(['delivery_route_id', 'stop_order']);
        });
        Schema::create('delivery_vehicles', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->string('code', 40);
            $t->string('registration_number', 80);
            $t->string('description', 160)->nullable();
            $t->decimal('capacity_litres', 14, 3);
            $t->boolean('is_active')->default(true);
            $t->timestamps();
            $t->softDeletes();
            $t->unique(['organization_id', 'registration_number']);
        });
        Schema::create('delivery_drivers', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->string('code', 40);
            $t->string('name', 160);
            $t->string('phone', 40)->nullable();
            $t->string('license_number', 100)->nullable();
            $t->boolean('is_active')->default(true);
            $t->timestamps();
            $t->softDeletes();
        });
        Schema::create('delivery_manifests', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('organization_id');
            $t->uuid('farm_id');
            $t->uuid('delivery_route_id');
            $t->uuid('delivery_vehicle_id');
            $t->uuid('delivery_driver_id');
            $t->string('delivery_number', 60);
            $t->date('delivery_date');
            $t->string('status', 30)->default('scheduled');
            $t->decimal('planned_quantity', 14, 3);
            $t->decimal('loaded_quantity', 14, 3)->default(0);
            $t->decimal('delivered_quantity', 14, 3)->default(0);
            $t->decimal('returned_quantity', 14, 3)->default(0);
            $t->decimal('rejected_quantity', 14, 3)->default(0);
            $t->text('notes')->nullable();
            $t->uuid('created_by');
            $t->timestamps();
            $t->unique(['organization_id', 'delivery_number']);
            $t->index(['organization_id', 'farm_id', 'delivery_date', 'status'], 'delivery_manifest_scope_idx');
        });
        Schema::create('delivery_manifest_stops', function (Blueprint $t): void {
            $t->uuid('id')->primary();
            $t->uuid('delivery_manifest_id');
            $t->uuid('delivery_route_stop_id');
            $t->uuid('milk_sale_id');
            $t->uuid('customer_id');
            $t->unsignedSmallInteger('stop_order');
            $t->decimal('planned_quantity', 14, 3);
            $t->decimal('delivered_quantity', 14, 3)->default(0);
            $t->decimal('returned_quantity', 14, 3)->default(0);
            $t->decimal('rejected_quantity', 14, 3)->default(0);
            $t->string('status', 30)->default('scheduled');
            $t->dateTime('delivered_at')->nullable();
            $t->string('acknowledged_by', 160)->nullable();
            $t->decimal('gps_latitude', 10, 7)->nullable();
            $t->decimal('gps_longitude', 10, 7)->nullable();
            $t->text('notes')->nullable();
            $t->timestamps();
            $t->unique('milk_sale_id');
        });
        $names = ['deliveries.view', 'deliveries.manage', 'deliveries.dispatch', 'deliveries.complete'];
        foreach ($names as $n) {
            DB::table('permissions')->updateOrInsert(['name' => $n], ['id' => (string) Str::uuid7(), 'created_at' => now(), 'updated_at' => now()]);
        }$ids = DB::table('permissions')->whereIn('name', $names)->pluck('id');
        foreach (DB::table('roles')->whereIn('slug', ['organization-owner', 'farm-manager'])->pluck('id') as $r) {
            foreach ($ids as $id) {
                DB::table('role_permissions')->updateOrInsert(['role_id' => $r, 'permission_id' => $id], ['created_at' => now(), 'updated_at' => now()]);
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('delivery_manifest_stops');
        Schema::dropIfExists('delivery_manifests');
        Schema::dropIfExists('delivery_drivers');
        Schema::dropIfExists('delivery_vehicles');
        Schema::dropIfExists('delivery_route_stops');
        Schema::dropIfExists('delivery_routes');
        DB::table('permissions')->whereIn('name',['deliveries.view', 'deliveries.manage', 'deliveries.dispatch', 'deliveries.complete'])->delete();
    }
};

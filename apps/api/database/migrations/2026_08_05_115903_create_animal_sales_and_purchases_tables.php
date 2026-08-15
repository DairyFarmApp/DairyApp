<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('animal_sales');
        Schema::dropIfExists('animal_purchases');

        Schema::create('animal_purchases', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('animal_id')->nullable();
            $table->string('purchase_number', 60);
            $table->date('purchase_date');
            $table->string('supplier', 180)->nullable();
            $table->decimal('purchase_price', 18, 2);
            $table->decimal('transportation_cost', 18, 2)->default(0);
            $table->decimal('veterinary_cost', 18, 2)->default(0);
            $table->decimal('total_cost', 18, 2);
            $table->string('reference', 160)->nullable();
            $table->text('notes')->nullable();
            $table->uuid('expense_record_id')->nullable();
            $table->uuid('created_by');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'farm_id', 'purchase_number'], 'purchase_farm_number_unique');
            $table->foreign(['farm_id', 'organization_id'], 'animal_purchases_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['animal_id', 'organization_id'], 'animal_purchases_animal_scope_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign('expense_record_id')->references('id')->on('expense_records')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('animal_sales', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('farm_id');
            $table->uuid('animal_id');
            $table->string('sale_number', 60);
            $table->date('sale_date');
            $table->string('buyer', 180)->nullable();
            $table->decimal('sale_price', 18, 2);
            $table->decimal('commission', 18, 2)->default(0);
            $table->decimal('transportation_cost', 18, 2)->default(0);
            $table->decimal('net_revenue', 18, 2);
            $table->string('reason', 160)->nullable();
            $table->string('reference', 160)->nullable();
            $table->text('notes')->nullable();
            $table->uuid('income_record_id')->nullable();
            $table->uuid('created_by');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['organization_id', 'farm_id', 'sale_number'], 'sale_farm_number_unique');
            $table->unique(['animal_id'], 'animal_sales_animal_unique');
            $table->foreign(['farm_id', 'organization_id'], 'animal_sales_farm_scope_fk')
                ->references(['id', 'organization_id'])->on('farms')->restrictOnDelete();
            $table->foreign(['animal_id', 'organization_id'], 'animal_sales_animal_scope_fk')
                ->references(['id', 'organization_id'])->on('animals')->restrictOnDelete();
            $table->foreign('income_record_id')->references('id')->on('income_records')->restrictOnDelete();
            $table->foreign('created_by')->references('id')->on('users')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_sales');
        Schema::dropIfExists('animal_purchases');
    }
};

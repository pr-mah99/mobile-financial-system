<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
      public function up(): void {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('recipient_id')->constrained('users')->onDelete('cascade');
            $table->decimal('amount', 15, 2);
            $table->enum('status', ['pending', 'completed', 'failed', 'cancelled'])->default('pending');
            $table->string('transaction_type', 50)->default('transfer');
            $table->text('description')->nullable();
            $table->string('reference_number', 100)->unique();
            $table->timestamps();

            // فهارس إضافية
            $table->index('sender_id', 'idx_sender_id');
            $table->index('recipient_id', 'idx_recipient_id');
            $table->index('status', 'idx_status');
            $table->index('created_at', 'idx_created_at');
            $table->index('reference_number', 'idx_reference_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};

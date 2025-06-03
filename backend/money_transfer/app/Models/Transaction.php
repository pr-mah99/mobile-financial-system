<?php
// app/Models/Transaction.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Transaction extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'sender_id',
        'recipient_id',
        'amount',
        'status',
        'transaction_type',
        'description',
        'reference_number',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'amount' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * حالات المعاملة المتاحة
     */
    const STATUS_PENDING = 'pending';
    const STATUS_COMPLETED = 'completed';
    const STATUS_FAILED = 'failed';
    const STATUS_CANCELLED = 'cancelled';

    /**
     * أنواع المعاملات المتاحة
     */
    const TYPE_TRANSFER = 'transfer';
    const TYPE_DEPOSIT = 'deposit';
    const TYPE_WITHDRAWAL = 'withdrawal';

    /**
     * Bootstrap the model
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($transaction) {
            if (empty($transaction->reference_number)) {
                $transaction->reference_number = self::generateReferenceNumber();
            }
        });
    }

    /**
     * المستخدم المرسل للمعاملة
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * المستخدم المستقبل للمعاملة
     */
    public function recipient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recipient_id');
    }

    /**
     * فحص إذا كانت المعاملة مكتملة
     */
    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    /**
     * فحص إذا كانت المعاملة معلقة
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * فحص إذا كانت المعاملة فاشلة
     */
    public function isFailed(): bool
    {
        return $this->status === self::STATUS_FAILED;
    }

    /**
     * تغيير حالة المعاملة إلى مكتملة
     */
    public function markAsCompleted(): bool
    {
        $this->status = self::STATUS_COMPLETED;
        return $this->save();
    }

    /**
     * تغيير حالة المعاملة إلى فاشلة
     */
    public function markAsFailed(): bool
    {
        $this->status = self::STATUS_FAILED;
        return $this->save();
    }

    /**
     * تغيير حالة المعاملة إلى ملغية
     */
    public function markAsCancelled(): bool
    {
        $this->status = self::STATUS_CANCELLED;
        return $this->save();
    }

    /**
     * إنشاء رقم مرجعي فريد للمعاملة
     */
    public static function generateReferenceNumber(): string
    {
        do {
            $reference = 'TXN' . date('Ymd') . strtoupper(Str::random(6));
        } while (self::where('reference_number', $reference)->exists());

        return $reference;
    }

    /**
     * البحث عن معاملة بالرقم المرجعي
     */
    public static function findByReference(string $reference): ?self
    {
        return self::where('reference_number', $reference)->first();
    }

    /**
     * الحصول على معاملات مستخدم معين
     */
    public static function getUserTransactions(int $userId)
    {
        return self::where('sender_id', $userId)
                  ->orWhere('recipient_id', $userId)
                  ->with(['sender', 'recipient'])
                  ->orderBy('created_at', 'desc');
    }

    /**
     * إنشاء معاملة تحويل جديدة
     */
    public static function createTransfer(
        int $senderId,
        int $recipientId,
        float $amount,
        string $description = null
    ): self {
        return self::create([
            'sender_id' => $senderId,
            'recipient_id' => $recipientId,
            'amount' => $amount,
            'status' => self::STATUS_PENDING,
            'transaction_type' => self::TYPE_TRANSFER,
            'description' => $description,
        ]);
    }

    /**
     * الحصول على تفاصيل المعاملة للعرض
     */
    public function getTransactionDetails(): array
    {
        return [
            'id' => $this->id,
            'reference_number' => $this->reference_number,
            'sender' => [
                'id' => $this->sender->id,
                'name' => $this->sender->name,
                'email' => $this->sender->email,
            ],
            'recipient' => [
                'id' => $this->recipient->id,
                'name' => $this->recipient->name,
                'email' => $this->recipient->email,
            ],
            'amount' => $this->amount,
            'status' => $this->status,
            'transaction_type' => $this->transaction_type,
            'description' => $this->description,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}

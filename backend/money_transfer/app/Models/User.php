<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'wallet_balance',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'wallet_balance' => 'decimal:2',
    ];

    /**
     * المعاملات المالية التي أرسلها المستخدم
     */
    public function sentTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'sender_id');
    }

    /**
     * المعاملات المالية التي استقبلها المستخدم
     */
    public function receivedTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'recipient_id');
    }

    /**
     * جميع المعاملات المالية (المرسلة والمستقبلة)
     */
    public function allTransactions()
    {
        return Transaction::where('sender_id', $this->id)
                         ->orWhere('recipient_id', $this->id)
                         ->orderBy('created_at', 'desc');
    }

    /**
     * فحص إذا كان المستخدم لديه رصيد كافي
     */
    public function hasBalance(float $amount): bool
    {
        return $this->wallet_balance >= $amount;
    }

    /**
     * إضافة مبلغ إلى رصيد المحفظة
     */
    public function addBalance(float $amount): bool
    {
        $this->wallet_balance += $amount;
        return $this->save();
    }

    /**
     * خصم مبلغ من رصيد المحفظة
     */
    public function deductBalance(float $amount): bool
    {
        if ($this->hasBalance($amount)) {
            $this->wallet_balance -= $amount;
            return $this->save();
        }
        return false;
    }

    /**
     * الحصول على الرصيد المتاح
     */
    public function getAvailableBalance(): float
    {
        return (float) $this->wallet_balance;
    }

    /**
     * البحث عن مستخدم بالبريد الإلكتروني
     */
    public static function findByEmail(string $email): ?self
    {
        return self::where('email', $email)->first();
    }
}

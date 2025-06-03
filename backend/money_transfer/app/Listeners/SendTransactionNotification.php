<?php
namespace App\Listeners;

use App\Events\MoneyTransferred;
use App\Mail\MoneyTransferNotification;
// use Illuminate\Contracts\Queue\ShouldQueue;  // احذف هذا السطر
// use Illuminate\Queue\InteractsWithQueue;     // احذف هذا السطر
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class SendTransactionNotification // أزل implements ShouldQueue
{
    // use InteractsWithQueue;  // احذف هذا السطر

    public function __construct()
    {
        //
    }

    public function handle(MoneyTransferred $event): void
    {
        try {
            $transaction = $event->transaction;
            $transaction->load(['sender', 'recipient']);

            Log::info('بدء إرسال إشعارات الإيميل', [
                'transaction_id' => $transaction->id,
                'sender_email' => $transaction->sender->email,
                'recipient_email' => $transaction->recipient->email
            ]);

            // إرسال إشعار للمرسل
            Mail::to($transaction->sender->email)->send(
                new MoneyTransferNotification($transaction, 'sender')
            );

            Log::info('تم إرسال إيميل للمرسل');

            // إرسال إشعار للمستقبل
            Mail::to($transaction->recipient->email)->send(
                new MoneyTransferNotification($transaction, 'recipient')
            );

            Log::info('تم إرسال إيميل للمستقبل');

        } catch (\Exception $e) {
            Log::error('خطأ في إرسال الإيميل: ' . $e->getMessage(), [
                'transaction_id' => $event->transaction->id,
                'error' => $e->getTraceAsString()
            ]);
        }
    }
}

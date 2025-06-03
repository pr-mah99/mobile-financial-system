<?php
// app/Http/Controllers/Api/SendMoneyController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SendMoneyRequest;
use App\Models\Transaction;
use App\Models\User;
use App\Events\MoneyTransferred;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SendMoneyController extends Controller
{
    private const DAILY_TRANSFER_LIMIT = 5;

    /**
     * Send money to another user
     */
    public function sendMoney(SendMoneyRequest $request): JsonResponse
    {
        try {
            $sender = auth()->user();

            // التحقق من الحد اليومي
            $remainingTransfers = $this->getRemainingTransfers($sender->id);

            if ($remainingTransfers <= 0) {
                return $this->errorResponse(
                    'لقد تجاوزت الحد اليومي للتحويلات (' . self::DAILY_TRANSFER_LIMIT . ' تحويلات)',
                    429,
                    ['remaining_transfers' => 0]
                );
            }

            $recipient = User::findByEmail($request->recipient_email);

            // التحقق من الرصيد
            if (!$sender->hasBalance($request->amount)) {
                return $this->errorResponse('الرصيد غير كافي', 400);
            }

            // تنفيذ التحويل
            $transaction = $this->processTransfer($sender, $recipient, $request);

            event(new MoneyTransferred($transaction));

            return $this->successResponse('تم التحويل بنجاح', [
                'transaction_id' => $transaction->id,
                'reference_number' => $transaction->reference_number,
                'amount' => $transaction->amount,
                'remaining_transfers' => $remainingTransfers - 1
            ]);

        } catch (\Exception $e) {
            Log::error('Send Money Error: ' . $e->getMessage());
            return $this->errorResponse('حدث خطأ أثناء التحويل', 500);
        }
    }

    /**
     * Get transaction history for current user
     */
    public function getTransactionHistory(): JsonResponse
    {
        try {
            $user = auth()->user();
            $transactions = Transaction::getUserTransactions($user->id)->paginate(20);

            return $this->successResponse('تم جلب تاريخ المعاملات بنجاح', [
                'transactions' => $transactions->items(),
                'pagination' => [
                    'current_page' => $transactions->currentPage(),
                    'last_page' => $transactions->lastPage(),
                    'per_page' => $transactions->perPage(),
                    'total' => $transactions->total()
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Transaction History Error: ' . $e->getMessage());
            return $this->errorResponse('حدث خطأ أثناء جلب تاريخ المعاملات', 500);
        }
    }

    /**
     * Get transaction details by reference number
     */
    public function getTransactionDetails(string $referenceNumber): JsonResponse
    {
        try {
            $user = auth()->user();
            $transaction = Transaction::findByReference($referenceNumber);

            if (!$transaction) {
                return $this->errorResponse('المعاملة غير موجودة', 404);
            }

            if (!$this->userCanViewTransaction($user, $transaction)) {
                return $this->errorResponse('ليس لديك صلاحية لعرض هذه المعاملة', 403);
            }

            return $this->successResponse('تم جلب تفاصيل المعاملة بنجاح',
                $transaction->getTransactionDetails()
            );

        } catch (\Exception $e) {
            Log::error('Transaction Details Error: ' . $e->getMessage());
            return $this->errorResponse('حدث خطأ أثناء جلب تفاصيل المعاملة', 500);
        }
    }

    /**
     * Get current wallet balance
     */
    public function getWalletBalance(): JsonResponse
    {
        try {
            $user = auth()->user();

            return $this->successResponse('تم جلب رصيد المحفظة بنجاح', [
                'wallet_balance' => $user->getAvailableBalance(),
                'user_name' => $user->name,
                'user_email' => $user->email
            ]);

        } catch (\Exception $e) {
            Log::error('Wallet Balance Error: ' . $e->getMessage());
            return $this->errorResponse('حدث خطأ أثناء جلب رصيد المحفظة', 500);
        }
    }

    /**
     * Helper Methods
     */
    private function getRemainingTransfers(int $senderId): int
    {
        $todayTransfers = Transaction::where('sender_id', $senderId)
            ->whereDate('created_at', Carbon::today())
            ->count();

        return self::DAILY_TRANSFER_LIMIT - $todayTransfers;
    }

    private function processTransfer($sender, $recipient, $request)
    {
        return DB::transaction(function () use ($sender, $recipient, $request) {
            $transaction = Transaction::createTransfer(
                $sender->id,
                $recipient->id,
                $request->amount,
                $request->description
            );

            $sender->deductBalance($request->amount);
            $recipient->addBalance($request->amount);
            $transaction->markAsCompleted();

            return $transaction;
        });
    }

    private function userCanViewTransaction($user, $transaction): bool
    {
        return $transaction->sender_id === $user->id || $transaction->recipient_id === $user->id;
    }

    private function successResponse(string $message, array $data = []): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], 200);
    }

    private function errorResponse(string $message, int $code, array $data = []): JsonResponse
    {
        $response = [
            'success' => false,
            'message' => $message
        ];

        if (!empty($data)) {
            $response['data'] = $data;
        }

        return response()->json($response, $code);
    }
}

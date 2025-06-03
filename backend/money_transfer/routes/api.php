<?php
// routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SendMoneyController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// مسارات المصادقة العامة (غير محمية)
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// مسارات محمية بالمصادقة
Route::middleware('auth:sanctum')->group(function () {

     // اختبار مؤقت
    Route::get('/test-auth', function (Request $request) {
        Log::info('test-auth endpoint hit by user:', ['user' => $request->user()]);
        return response()->json(['msg' => 'Auth works', 'user' => $request->user()]);
    });

    // مسارات المصادقة المحمية
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/logout-all', [AuthController::class, 'logoutAll']);
        Route::get('/me', [AuthController::class, 'me']);
    });

    // مسارات التحويلات المالية (مع rate limiting)
    Route::middleware('throttle:10,1')->group(function () {
        Route::post('/send-money', [SendMoneyController::class, 'sendMoney']);
    });


    // مسارات المحفظة والمعاملات
    Route::prefix('wallet')->group(function () {
        Route::get('/balance', [SendMoneyController::class, 'getWalletBalance']);
        Route::get('/transactions', [SendMoneyController::class, 'getTransactionHistory']);
        Route::get('/transaction/{referenceNumber}', [SendMoneyController::class, 'getTransactionDetails']);
    });

    // مسار اختبار المصادقة
    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'المستخدم مصدق بنجاح',
            'data' => [
                'user' => $request->user()
            ]
        ]);
    });
});

// مسار عام للاختبار
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'API يعمل بشكل طبيعي',
        'timestamp' => now()->format('Y-m-d H:i:s'),
        'version' => '1.0.0'
    ]);
});

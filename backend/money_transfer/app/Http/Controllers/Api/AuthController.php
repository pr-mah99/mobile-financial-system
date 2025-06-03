<?php
// app/Http/Controllers/Api/AuthController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    /**
     * تسجيل مستخدم جديد
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'wallet_balance' => 100000.00, // رصيد ابتدائي للاختبار
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الحساب بنجاح',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'wallet_balance' => $user->wallet_balance,
                        'created_at' => $user->created_at->format('Y-m-d H:i:s')
                    ],
                    'token' => $token,
                    'token_type' => 'Bearer'
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Registration Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إنشاء الحساب',
                'error' => config('app.debug') ? $e->getMessage() : 'خطأ داخلي في الخادم'
            ], 500);
        }
    }

    /**
     * تسجيل دخول المستخدم
     */
    public function login(LoginRequest $request): JsonResponse
    {

        try {
            $credentials = $request->only('email', 'password');

            if (!Auth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات الاعتماد غير صحيحة',
                    'errors' => [
                        'email' => ['البريد الإلكتروني أو كلمة المرور غير صحيحة']
                    ]
                ], 401);
            }

            $user = Auth::user();

            // حذف الرموز المميزة القديمة
            $user->tokens()->delete();

            // إنشاء رمز مميز جديد
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'تم تسجيل الدخول بنجاح',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'wallet_balance' => $user->wallet_balance,
                        'created_at' => $user->created_at->format('Y-m-d H:i:s')
                    ],
                    'token' => $token,
                    'token_type' => 'Bearer'
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Login Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تسجيل الدخول',
                'error' => config('app.debug') ? $e->getMessage() : 'خطأ داخلي في الخادم'
            ], 500);
        }
    }

    /**
     * تسجيل خروج المستخدم
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            // حذف الرمز المميز الحالي فقط
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم تسجيل الخروج بنجاح'
            ], 200);

        } catch (\Exception $e) {
            Log::error('Logout Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تسجيل الخروج'
            ], 500);
        }
    }

    /**
     * تسجيل خروج من جميع الأجهزة
     */
    public function logoutAll(Request $request): JsonResponse
    {
        try {
            // حذف جميع الرموز المميزة للمستخدم
            $request->user()->tokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم تسجيل الخروج من جميع الأجهزة بنجاح'
            ], 200);

        } catch (\Exception $e) {
            Log::error('Logout All Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تسجيل الخروج'
            ], 500);
        }
    }

    /**
     * الحصول على بيانات المستخدم الحالي
     */
    public function me(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            return response()->json([
                'success' => true,
                'message' => 'تم جلب بيانات المستخدم بنجاح',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'wallet_balance' => $user->wallet_balance,
                        'email_verified_at' => $user->email_verified_at,
                        'created_at' => $user->created_at->format('Y-m-d H:i:s'),
                        'updated_at' => $user->updated_at->format('Y-m-d H:i:s')
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Get User Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب بيانات المستخدم'
            ], 500);
        }
    }
}

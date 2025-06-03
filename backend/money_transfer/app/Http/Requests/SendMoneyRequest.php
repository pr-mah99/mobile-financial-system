<?php
// app/Http/Requests/SendMoneyRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class SendMoneyRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'recipient_email' => [
                'required',
                'email',
                'max:255',
                'exists:users,email',
                'different_from_auth_email' // custom rule
            ],
            'amount' => [
                'required',
                'numeric',
                'min:0.01',
                'max:999999.99',
                'decimal:0,2' // Laravel's built-in decimal validation
            ],
            'description' => [
                'nullable',
                'string',
                'max:500'
            ]
        ];
    }

    /**
     * Get custom validation messages.
     */
    public function messages(): array
    {
        return [
            'recipient_email.required' => 'البريد الإلكتروني للمستقبل مطلوب',
            'recipient_email.email' => 'يجب أن يكون البريد الإلكتروني صحيحاً',
            'recipient_email.exists' => 'البريد الإلكتروني غير مسجل في النظام',
            'recipient_email.max' => 'البريد الإلكتروني طويل جداً',
            'recipient_email.different_from_auth_email' => 'لا يمكن إرسال الأموال لنفس الحساب',

            'amount.required' => 'المبلغ مطلوب',
            'amount.numeric' => 'المبلغ يجب أن يكون رقماً',
            'amount.min' => 'الحد الأدنى للتحويل هو 0.01',
            'amount.max' => 'الحد الأقصى للتحويل هو 900,000',
            'amount.decimal' => 'المبلغ يجب ألا يحتوي على أكثر من منزلتين عشريتين',

            'description.string' => 'الوصف يجب أن يكون نصاً',
            'description.max' => 'الوصف طويل جداً (الحد الأقصى 500 حرف)'
        ];
    }

    /**
     * Handle a failed validation attempt.
     */
    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422)
        );
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator)
    {
        // إضافة custom rule للتحقق من عدم إرسال الأموال للنفس
        $validator->addExtension('different_from_auth_email', function ($attribute, $value, $parameters, $validator) {
            return $value !== auth()->user()->email;
        });
    }
}

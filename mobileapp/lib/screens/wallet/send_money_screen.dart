// lib/screens/wallet/send_money_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/consts.dart';

class SendMoneyScreen extends StatefulWidget {
  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final LocalAuthentication localAuth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );

      final amount = double.parse(_amountController.text);
      final commission = 0.0; // العمولة صفر حالياً
      final totalAmount = amount + commission;
      final remainingBalance = walletProvider.balance - totalAmount;

      final formatterAmount = NumberFormat("#,##0.00", "ar");
      final formatterBalance = NumberFormat("#,##0", "ar");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.send, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'تأكيد الإرسال',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تفاصيل التحويل
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // من المرسل
                        _buildDetailRow(
                          'من:',
                          authProvider.user?.email ?? '',
                          Icons.person_outline,
                          AppColors.primary,
                        ),

                        Divider(height: 20),

                        // إلى المستلم
                        _buildDetailRow(
                          'إلى:',
                          _emailController.text.trim(),
                          Icons.person,
                          AppColors.success,
                        ),

                        if (_descriptionController.text.trim().isNotEmpty) ...[
                          Divider(height: 20),
                          _buildDetailRow(
                            'الوصف:',
                            _descriptionController.text.trim(),
                            Icons.description_outlined,
                            AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // تفاصيل المبالغ
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildAmountRow(
                          'مبلغ التحويل:',
                          '${formatterAmount.format(amount)} د.ع',
                          AppColors.textPrimary,
                          isBold: true,
                        ),

                        SizedBox(height: 12),

                        _buildAmountRow(
                          'العمولة:',
                          '${formatterAmount.format(commission)} د.ع',
                          AppColors.success,
                        ),

                        Divider(height: 20, thickness: 1),

                        _buildAmountRow(
                          'المبلغ الإجمالي:',
                          '${formatterAmount.format(totalAmount)} د.ع',
                          AppColors.primary,
                          isBold: true,
                          fontSize: 14,
                        ),

                        SizedBox(height: 16),

                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildAmountRow(
                            'الرصيد المتبقي:',
                            '${formatterBalance.format(remainingBalance)} د.ع',
                            AppColors.warning,
                            isBold: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // تحذير
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: AppColors.error,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تأكد من صحة البيانات. لا يمكن التراجع عن العملية بعد التأكيد.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // زر الإلغاء
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),

              // زر التأكيد
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) {
                  return ElevatedButton(
                    onPressed: walletProvider.isLoading
                        ? null
                        : () async {
                            if (biometricEnabled) {
                              final bool
                              didAuthenticate = await localAuth.authenticate(
                                localizedReason: 'يرجى التحقق من هويتك لتفعيل المصادقة البيومترية',

                              );

                              if (didAuthenticate) {
                                Navigator.of(
                                  context,
                                ).pop(); // إغلاق نافذة التأكيد
                                _sendMoney(); // تنفيذ عملية الإرسال
                              }
                            } else {
                              Navigator.of(
                                context,
                              ).pop(); // إغلاق نافذة التأكيد
                              _sendMoney(); // تنفيذ عملية الإرسال
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: walletProvider.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'تأكيد الإرسال',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    String amount,
    Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _sendMoney() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    final success = await walletProvider.sendMoney(
      authProvider.token!,
      _emailController.text.trim(),
      double.parse(_amountController.text),
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال الأموال بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error ?? 'فشل في إرسال الأموال'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إرسال أموال')),
      body: Consumer2<AuthProvider, WalletProvider>(
        builder: (context, authProvider, walletProvider, child) {
          final formattedBalance = NumberFormat(
            "#,##0",
            "ar",
          ).format(walletProvider.balance);
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // عرض الرصيد الحالي
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الرصيد المتاح',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${formattedBalance} د.ع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // حقل البريد الإلكتروني للمستلم
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'بريد المستلم الإلكتروني',
                      prefixIcon: Icon(Icons.person_outline),
                      helperText:
                          'أدخل البريد الإلكتروني للشخص المراد التحويل إليه',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال بريد المستلم الإلكتروني';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      if (value.trim() == authProvider.user?.email) {
                        return 'لا يمكنك إرسال أموال لنفسك';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  // حقل المبلغ
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'المبلغ (د.ع)',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      helperText: 'أدخل المبلغ المراد إرساله',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال المبلغ';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'يرجى إدخال مبلغ صحيح';
                      }
                      if (amount <= 0) {
                        return 'المبلغ يجب أن يكون أكبر من صفر';
                      }
                      if (amount > walletProvider.balance) {
                        return 'المبلغ أكبر من الرصيد المتاح';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  // حقل الوصف (اختياري)
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'وصف التحويل (اختياري)',
                      prefixIcon: Icon(Icons.description_outlined),
                      helperText: 'أضف وصفاً للتحويل إذا رغبت في ذلك',
                    ),
                  ),

                  SizedBox(height: 40),

                  // زر الإرسال (تم تغييره لفتح نافذة التأكيد)
                  ElevatedButton(
                    onPressed: walletProvider.isLoading
                        ? null
                        : _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: walletProvider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('إرسال الأموال', style: TextStyle(fontSize: 18)),
                  ),

                  SizedBox(height: 20),

                  // تحذير أمني
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تأكد من البيانات',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                              Text(
                                'تحقق من بريد المستلم والمبلغ قبل الإرسال. العمليات لا يمكن التراجع عنها.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

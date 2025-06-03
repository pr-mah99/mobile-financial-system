// lib/providers/wallet_provider.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // الحصول على رصيد المحفظة
  Future<void> getWalletBalance(String token) async {
    _isLoading = true;
    _error = null;
    // notifyListeners();

    try {
      _balance = await ApiService.getWalletBalance(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في جلب رصيد المحفظة';
      _isLoading = false;
      notifyListeners();
    }
  }

  // إرسال أموال
  Future<bool> sendMoney(
      String token,
      String recipientEmail,
      double amount,
      String? description,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.sendMoney(
        token,
        recipientEmail,
        amount,
        description,
      );

      if (response['success'] == true) {
        // تحديث الرصيد والمعاملات
        await getWalletBalance(token);
        await getTransactionHistory(token);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message']!=null? "${response['message']} ${response['errors']['amount']??''}" : 'فشل في إرسال الأموال';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'فشل في إرسال الأموال';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // الحصول على تاريخ المعاملات
  Future<void> getTransactionHistory(String token) async {
    try {
      _transactions = await ApiService.getTransactionHistory(token);
      notifyListeners();
    } catch (e) {
      _error = 'فشل في جلب تاريخ المعاملات';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
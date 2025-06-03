
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/transaction.dart';
import '../utils/consts.dart';

class ApiService {

  // تسجيل الدخول
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    // print('response.body=${response.body}');
    return jsonDecode(response.body);
  }

  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String passwordConfirmation,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return jsonDecode(response.body);
  }

  // تسجيل الخروج
  static Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  // الحصول على بيانات المستخدم
  static Future<User> getUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return User.fromJson(data['data']['user']);
  }

  // الحصول على رصيد المحفظة
  static Future<double> getWalletBalance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/balance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    // print('data=$data');
    return double.parse(data['data']['wallet_balance'].toString());
  }

  // إرسال أموال
  static Future<Map<String, dynamic>> sendMoney(
      String token,
      String recipientEmail,
      double amount,
      String? description,
      ) async {
    String url='$baseUrl/send-money';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'recipient_email': recipientEmail,
        'amount': amount,
        'description': description,
      }),
    );
    // print('token=${token}');
    // print('url=${url}');
    // print('response.body=${response.body}');
    // print('response.body=${jsonDecode(response.body)}');
    return jsonDecode(response.body);
  }

  // الحصول على تاريخ المعاملات
  static Future<List<Transaction>> getTransactionHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    final transactionsList = data['data']['transactions'] as List;
    return transactionsList.map((t) => Transaction.fromJson(t)).toList();
  }

  // الحصول على تفاصيل معاملة محددة
  static Future<Transaction> getTransactionDetails(
      String token,
      String referenceNumber,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/transaction/$referenceNumber'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return Transaction.fromJson(data['data']['transaction']);
  }
}
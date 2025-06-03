// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  final _storage = FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  // تحقق من وجود token محفوظ
  Future<void> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _storage.read(key: 'auth_token');
      if (_token != null) {
        _user = await ApiService.getUser(_token!);
      }
    } catch (e) {
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      if (response['success'] == true) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);

        await _storage.write(key: 'auth_token', value: _token);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // print('e=$e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تسجيل مستخدم جديد
  Future<bool> register(String name, String email, String password, String passwordConfirmation,) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );

      if (response['success'] == true) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);

        await _storage.write(key: 'auth_token', value: _token);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.logout(_token!);
      } catch (e) {
        // تجاهل الأخطاء عند تسجيل الخروج
      }
    }

    _user = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  // تحديث بيانات المستخدم
  Future<void> refreshUser() async {
    if (_token != null) {
      try {
        _user = await ApiService.getUser(_token!);
        notifyListeners();
      } catch (e) {
        // Handle error
      }
    }
  }
}

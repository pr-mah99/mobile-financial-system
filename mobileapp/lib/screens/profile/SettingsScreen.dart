// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../utils/consts.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // التحقق من المصادقة البيومترية قبل التفعيل
      try {
        final bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'يرجى التحقق من هويتك لتفعيل المصادقة البيومترية',
        );

        if (didAuthenticate) {
          await _saveBiometricSetting(true);
        }
      } catch (e) {
        print('e=$e');
        _showErrorDialog('فشل في التحقق من المصادقة البيومترية: $e');
      }
    } else {
      await _saveBiometricSetting(false);
    }
  }

  Future<void> _saveBiometricSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', enabled);
      setState(() {
        biometricEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled ? 'تم تفعيل المصادقة البيومترية' : 'تم إيقاف المصادقة البيومترية'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      _showErrorDialog('فشل في حفظ الإعدادات: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الأمان
            _buildSectionHeader('الأمان والخصوصية'),
            SizedBox(height: 10),
            _buildSecurityCard(),

            SizedBox(height: 30),

            // قسم الإشعارات
            _buildSectionHeader('الإشعارات'),
            SizedBox(height: 10),
            _buildNotificationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.fingerprint,
            title: 'المصادقة البيومترية',
            subtitle:  'تأمين التحويلات ببصمة الإصبع أو الوجه',
            trailing: Switch(
              value: biometricEnabled,
              onChanged:  _toggleBiometric,
              activeColor: AppColors.primary,
            ),
            isFirst: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
        /*  _buildSettingTile(
            icon: Icons.notifications,
            title: 'إشعارات التحويل',
            subtitle: 'تلقي إشعارات عند التحويل والاستقبال',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Handle notification toggle
              },
              activeColor: AppColors.primary,
            ),
            isFirst: true,
          ),*/
          _buildSettingTile(
            icon: Icons.email,
            title: 'إشعارات البريد الإلكتروني',
            subtitle: 'تلقي ملخص المعاملات عبر البريد',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Handle email notification toggle
              },
              activeColor: AppColors.primary,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(15) : Radius.zero,
          bottom: isLast ? Radius.circular(15) : Radius.zero,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
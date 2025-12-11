// lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<SettingsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      Navigator.pop(context); // Close loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(settings.passwordChanged), // ✅
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Back to profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? settings.passwordChangeFailed), // ✅
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.changePasswordTitle), // ✅
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.passwordSecurityInfo, // ✅
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Old Password
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.oldPassword, // ✅
                  hint: s.enterOldPassword, // ✅
                  controller: _oldPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.validateRequired(value, s.oldPassword),
                ),
              ),

              const SizedBox(height: 20),

              // New Password
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.newPassword, // ✅
                  hint: s.passwordMinimum, // ✅
                  controller: _newPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.validatePassword,
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Password
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.confirmNewPassword, // ✅
                  hint: s.enterNewPasswordAgain, // ✅
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Change Password Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    text: settings.changePasswordButton, // ✅
                    onPressed: _handleChangePassword,
                    isLoading: authProvider.isLoading,
                    icon: Icons.lock_reset,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Cancel Button
              CustomOutlineButton(
                text: settings.cancel, // ✅
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
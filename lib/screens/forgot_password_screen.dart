// lib/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });

      if (!mounted) return;

      final settings = context.read<SettingsProvider>();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.getText(
              'Link reset password telah dikirim ke email Anda',
              'Password reset link has been sent to your email',
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      final settings = context.read<SettingsProvider>();
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = settings.getText(
            'Email tidak terdaftar',
            'Email not registered',
          );
          break;
        case 'invalid-email':
          errorMessage = settings.getText(
            'Format email tidak valid',
            'Invalid email format',
          );
          break;
        case 'too-many-requests':
          errorMessage = settings.getText(
            'Terlalu banyak percobaan. Coba lagi nanti',
            'Too many attempts. Try again later',
          );
          break;
        default:
          errorMessage = settings.getText(
            'Gagal mengirim email reset: ${e.message}',
            'Failed to send reset email: ${e.message}',
          );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

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
        title: Text(
          settings.getText('Lupa Password', 'Forgot Password'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon/Illustration
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  settings.getText('Reset Password', 'Reset Password'),
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                const SizedBox(height: 12),

                // Description
                if (!_emailSent) ...[
                  Text(
                    settings.getText(
                      'Masukkan email Anda dan kami akan mengirimkan link untuk mereset password Anda.',
                      'Enter your email and we will send you a link to reset your password.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Email Field
                  Consumer<SettingsProvider>(
                    builder: (context, s, _) => CustomTextField(
                      label: s.email,
                      hint: s.enterEmail,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                      enabled: !_emailSent,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Reset Button
                  CustomButton(
                    text: settings.getText(
                      'Kirim Link Reset',
                      'Send Reset Link',
                    ),
                    onPressed: _handleResetPassword,
                    isLoading: _isLoading,
                    icon: Icons.email,
                  ),
                ] else ...[
                  // Success State
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          settings.getText(
                            'Email Terkirim!',
                            'Email Sent!',
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          settings.getText(
                            'Link reset password telah dikirim ke:',
                            'Password reset link has been sent to:',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _emailController.text.trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          settings.getText(
                            'Cek inbox atau folder spam Anda. Link akan kadaluarsa dalam 1 jam.',
                            'Check your inbox or spam folder. Link will expire in 1 hour.',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back to Login Button
                  CustomButton(
                    text: settings.getText(
                      'Kembali ke Login',
                      'Back to Login',
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back,
                  ),

                  const SizedBox(height: 16),

                  // Resend Button
                  CustomOutlineButton(
                    text: settings.getText(
                      'Kirim Ulang Email',
                      'Resend Email',
                    ),
                    onPressed: () {
                      setState(() => _emailSent = false);
                      _handleResetPassword();
                    },
                    icon: Icons.refresh,
                  ),
                ],

                const SizedBox(height: 24),

                // Info Box
                if (!_emailSent)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.accentBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            settings.getText(
                              'Pastikan email yang Anda masukkan adalah email yang terdaftar.',
                              'Make sure the email you enter is registered.',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
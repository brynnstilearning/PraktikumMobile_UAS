import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

// REGISTER SCREEN
// Screen untuk user mendaftar akun baru

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle Register
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.registerSuccess), // ✅
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? settings.registerFailed), // ✅
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
                // Logo/Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 40,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  settings.registerAccount, // ✅
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  settings.createAccountToContinue, // ✅
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 30),

                // Name Field - WRAP DENGAN Consumer
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => CustomTextField(
                    label: s.fullName, // ✅
                    hint: s.enterFullName, // ✅
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.validateName,
                  ),
                ),

                const SizedBox(height: 20),

                // Email Field - WRAP DENGAN Consumer
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => CustomTextField(
                    label: s.email, // ✅
                    hint: s.enterEmail, // ✅
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.validateEmail,
                  ),
                ),

                const SizedBox(height: 20),

                // Phone Number Field - WRAP DENGAN Consumer
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => CustomTextField(
                    label: s.phoneNumber, // ✅
                    hint: s.phoneExample, // ✅
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.validatePhoneNumber,
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field - WRAP DENGAN Consumer
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => CustomTextField(
                    label: s.password, // ✅
                    hint: s.passwordMinimum, // ✅
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outlined,
                    validator: Validators.validatePassword,
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Password Field - WRAP DENGAN Consumer
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => CustomTextField(
                    label: s.confirmPassword, // ✅
                    hint: s.enterPasswordAgain, // ✅
                    controller: _confirmPasswordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outlined,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: settings.register, // ✅
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      settings.alreadyHaveAccount, // ✅
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        settings.login, // ✅
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
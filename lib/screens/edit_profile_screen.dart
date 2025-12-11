// lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.getText('User tidak ditemukan', 'User not found')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final nameChanged = _nameController.text.trim() != currentUser.name;
      final phoneChanged = _phoneController.text.trim() != currentUser.phoneNumber;

      if (!nameChanged && !phoneChanged) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(settings.noChanges), // ✅
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await authProvider.updateProfile(
        name: nameChanged ? _nameController.text.trim() : null,
        phoneNumber: phoneChanged ? _phoneController.text.trim() : null,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(settings.profileUpdated), // ✅
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? settings.updateFailed), // ✅
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

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
        title: Text(settings.editProfileTitle), // ✅
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
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.accentBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.updateProfileInfo, // ✅
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

              // Name
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

              // Email - DISABLED (read-only)
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.email, // ✅
                  hint: s.enterEmail, // ✅
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                  validator: Validators.validateEmail,
                ),
              ),

              const SizedBox(height: 8),

              // Keterangan email tidak bisa diubah
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        settings.emailCannotChange, // ✅
                        style: const TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Phone Number
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

              const SizedBox(height: 30),

              // Save Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    text: settings.saveChanges, // ✅
                    onPressed: _handleSave,
                    isLoading: authProvider.isLoading,
                    icon: Icons.save,
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
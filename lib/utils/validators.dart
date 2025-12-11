// VALIDATORS
// Helper untuk validasi input form

class Validators {

  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    // Regex untuk validasi email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Password Validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }

  // Name Validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    
    return null;
  }

  // 👇 TAMBAHKAN VALIDATOR PHONE NUMBER
  // Phone Number Validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    // Remove spaces and dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if contains only numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    
    // Check length (Indonesia phone number: 10-13 digits)
    if (cleanNumber.length < 10 || cleanNumber.length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    
    // Check if starts with 0 or 62 (Indonesia)
    if (!cleanNumber.startsWith('0') && !cleanNumber.startsWith('62')) {
      return 'Nomor telepon harus diawali 0 atau 62';
    }
    
    return null;
  }

  // Confirm Password Validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak sama';
    }
    
    return null;
  }

  // Required Field Validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    return null;
  }
}
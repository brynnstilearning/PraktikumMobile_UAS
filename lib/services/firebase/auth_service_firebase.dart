// lib/services/firebase/auth_service_firebase.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_service_interface.dart';

class AuthServiceFirebase implements AuthServiceInterface {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  User? _currentUser;

  @override
  Future<void> init() async {
    // Load current user jika sudah login
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _loadCurrentUser(firebaseUser.uid);
    }
  }

  /// Load user data dari Firestore
  Future<void> _loadCurrentUser(String userId) async {
    try {
      print('📦 Loading user data: $userId');

      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        final firebaseUser = _auth.currentUser;

        _currentUser = User(
          id: userId,
          name: data['name'] ?? firebaseUser?.displayName ?? '',
          email: data['email'] ?? firebaseUser?.email ?? '',
          password: '', // Tidak perlu simpan password
          level: data['level'] ?? 1,
          points: data['points'] ?? 0,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        );

        print('✅ Current user loaded: ${_currentUser!.name}');
      } else {
        print('⚠️ User document not found, creating...');
        // Jika document tidak ada, buat baru (untuk backward compatibility)
        await _createUserDocument(userId);
        await _loadCurrentUser(userId); // Retry load
      }
    } catch (e) {
      print('❌ Error loading current user: $e');

      // Fallback: buat User dari Firebase Auth saja
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        _currentUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          password: '',
          level: 1,
          points: 0,
          createdAt: DateTime.now(),
        );
      }
    }
  }

  /// Create user document di Firestore
  Future<void> _createUserDocument(String userId) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection(_collection).doc(userId).set({
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
          'level': 1,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ User document created');
      }
    } catch (e) {
      print('❌ Error creating user document: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Logging in: $email');

      // Login dengan Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data dari Firestore
      await _loadCurrentUser(credential.user!.uid);

      print('✅ Login successful');

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': _currentUser,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code}');

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah';
          break;
        default:
          message = 'Login gagal: ${e.message}';
      }

      return {
        'success': false,
        'message': message,
        'user': null,
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'user': null,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) async {
    try {
      print('📝 Registering: $email with name: $name, phone: $phoneNumber');

      // Register dengan Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user!.uid;

      print('✅ Auth created with UID: $userId');

      // Update display name di Firebase Auth
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();

      print('✅ Display name updated: $name');

      // Simpan data user ke Firestore
      await _firestore.collection(_collection).doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber ?? '', // 👈 TAMBAHKAN INI
        'level': 1,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore document created');

      // Load user data
      await _loadCurrentUser(userId);

      print('✅ User data loaded: ${_currentUser?.name}');
      print('✅ Register successful');

      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user': _currentUser,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Register error: ${e.code}');

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'operation-not-allowed':
          message = 'Registrasi tidak diizinkan';
          break;
        default:
          message = 'Registrasi gagal: ${e.message}';
      }

      return {
        'success': false,
        'message': message,
        'user': null,
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'user': null,
      };
    }
  }


  @override
  Future<bool> logout() async {
    try {
      print('🚪 Logging out');

      await _auth.signOut();
      _currentUser = null;

      print('✅ Logout successful');
      return true;
    } catch (e) {
      print('❌ Logout error: $e');
      return false;
    }
  }

  @override
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  @override
  User? getCurrentUser() {
    return _currentUser;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) async {
    try {
      print('✏️ Updating profile: $userId');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updateData['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
      }

      // 👇 TAMBAHKAN UPDATE PHONE NUMBER
      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      // Update Firestore
      await _firestore.collection(_collection).doc(userId).update(updateData);

      // Reload current user
      await _loadCurrentUser(userId);

      print('✅ Profile updated');

      return {
        'success': true,
        'message': 'Profil berhasil diupdate',
      };
    } catch (e) {
      print('❌ Update profile error: $e');
      return {
        'success': false,
        'message': 'Gagal update profil: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔑 Changing password');

      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User tidak ditemukan',
        };
      }

      // Re-authenticate dengan password lama
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('✅ Password changed');

      return {
        'success': true,
        'message': 'Password berhasil diubah',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Change password error: ${e.code}');

      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Password lama salah';
          break;
        case 'weak-password':
          message = 'Password baru terlalu lemah';
          break;
        case 'requires-recent-login':
          message = 'Silakan login ulang untuk mengganti password';
          break;
        default:
          message = 'Gagal mengganti password: ${e.message}';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadCurrentUser(firebaseUser.uid);
        return _currentUser;
      }
      _currentUser = null;
      return null;
    });
  }
}
